//
//  CapsLockManager.swift
//  CapsLockNoDelay
//
//  Created by Guy Kaplan on 31/10/2020.
//

import Foundation
import Cocoa
import Carbon

let changeLanguageKey = KeyCodes.F13

class CapsLockManager {
    static let instance = CapsLockManager()
    
    var sticky = false
    var alternativeInputSource: InputSource? = nil
    
    var capsLockDelay: Int {
        IOHIDServiceClient.getValue(key: kIOHIDKeyboardCapsLockDelayOverrideKey) as! Int
    }
    
    private init() {
        // no-op
    }

    static func requestAccess() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Access Not Enabled")
            return false
        }
        return true
    }
    
    static func initialize() {
        if debugUseCmd {
            KeyInterceptor.interceptEvents(eventTypes: [.keyDown, .keyUp, .flagsChanged], callback: handleSecondaryCommand)
            instance.registerSecondaryCommandEventListener()
        } else {
            // Keep handling caps lock with same logic, since:
            // 1. I tried to capture caps lock event with:
            //    CGEventType(rawValue: NSEvent.EventType.systemDefined)
            //    , but It also captures all mouse clicks, which might affect performance
            // 2. CapsLock isn't being consumed by returning nil, still activating actual caps lock feature
            instance.registerCapsLockEventListener()
        }
    }
    
    func registerCapsLockEventListener() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .systemDefined]) { (event) in
            self.handleCapsLockEvent(event: event)
        }
    }
    
    func registerSecondaryCommandEventListener() {
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { (event) in
            self.handleSecondaryCommandEvent(event: event)
        }
    }
    
    func handleCapsLockEvent(event: NSEvent) {
        guard self.filterCapsLockEvent(event: event) else {
            return
        }
        
        let isCapsLockEnabled = self.getCapsLockState()
        if isCapsLockEnabled {
            self.setCapsLockState(false)
            return
        }
        
        if self.sticky {
            self.setCapsLockState(!isCapsLockEnabled)
        } else {
            self.changeLanguage()
        }
    }
    
    func handleSecondaryCommandEvent(event: NSEvent) {
        guard self.filterSecondaryCommandEvent(event: event) else {
            return
        }
        
        self.changeLanguage()
    }
    
    func filterCapsLockEvent(event: NSEvent) -> Bool {
        guard event.type == .systemDefined, event.subtype.rawValue == 211, event.data1 == 1 else {
            return false
        }
        
        sticky = event.modifierFlags.contains(.shift)
        
        return true
    }
    
    func filterSecondaryCommandEvent(event: NSEvent) -> Bool {
        guard event.keyCode == changeLanguageKey.rawValue else {
            return false
        }
        
        return true
    }
    
    func changeLanguage() {
        guard let selectPreviousShort = Shortcut.selectPreviousInputSource else {
            return
        }
        
        switch InputSource.current {
        case .ABC:
            selectPreviousShort.post()
        default:
            InputSource.ABC.select()
        }
    }

    func setCapsLockState(_ state: Bool) {
        var ioConnect: io_connect_t = .init(0)
        let ioService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(kIOHIDSystemClass))
        IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)
        IOHIDSetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), state)
        IOServiceClose(ioConnect)
        
        StatusBar.instance.setStatusIcon(enabled: state)
    }

    func getCapsLockState() -> Bool {
        var ioConnect: io_connect_t = .init(0)
        let ioService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(kIOHIDSystemClass))
        IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)

        var modifierLockState = false
        IOHIDGetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), &modifierLockState)

        IOServiceClose(ioConnect)
        return modifierLockState;
    }
}

func handleSecondaryCommand(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let primaryCommandFlag: UInt64 = 1 << 3
    let secondaryCommandFlag: UInt64 = 1 << 4
    
    let isCmdOn = event.flags.rawValue & CGEventFlags.maskCommand.rawValue > 0
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    
    let isPrimaryCmdOn = isCmdOn && (event.flags.rawValue & primaryCommandFlag) > 0
    let isSecondaryCmdOn = isCmdOn && (event.flags.rawValue & secondaryCommandFlag) > 0
    let isSecondaryCmdDown = isSecondaryCmdOn && keyCode == KeyCodes.mod_secondary_command.rawValue
    
    let secondaryCommandFlagMask = CGEventFlags.maskCommand.rawValue | secondaryCommandFlag | CGEventFlags.maskNonCoalesced.rawValue
    let isExactlySecondaryCommand = event.flags.rawValue & ~secondaryCommandFlagMask == 0
    
    let hasNonCoalescedFlag = event.flags.rawValue & CGEventFlags.maskNonCoalesced.rawValue > 0
    
    if isSecondaryCmdDown && isExactlySecondaryCommand {
        event.setIntegerValueField(.keyboardEventKeycode, value: changeLanguageKey.rawValue)
    }
    
    var filteredRawFlags = event.flags.rawValue
    if isPrimaryCmdOn && isSecondaryCmdOn {
        filteredRawFlags &= ~secondaryCommandFlag
    } else if isPrimaryCmdOn {
        // no-op
    } else if isSecondaryCmdOn {
        filteredRawFlags &= ~secondaryCommandFlagMask
        if hasNonCoalescedFlag {
            filteredRawFlags |= CGEventFlags.maskNonCoalesced.rawValue
        }
    } else {
        // no-op
    }
    event.flags = CGEventFlags(rawValue: filteredRawFlags)
    
    return Unmanaged.passRetained(event)
}
