//
//  CapsLockManager.swift
//  CapsLockNoDelay
//
//  Created by Guy Kaplan on 31/10/2020.
//

import Foundation
import Cocoa
import Carbon

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
        // TODO: Temporarily using boolean flag. Implement GUI option later.
        let useCmd = true
        if useCmd {
            KeyInterceptor.interceptEvents(eventTypes: [.keyDown, .keyUp, .flagsChanged], callback: handleSecondaryCommand)
        } else {
            // Keep handling caps lock with same logic, since:
            // 1. It also captures all mouse clicks, which might affect performance
            // 2. CapsLock isn't being consumed by returning nil, still activating actual caps lock feature
            instance.registerEventListener()
        }
    }
    
    func registerEventListener() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .systemDefined]) { (event) in
            guard self.handleEvent(event: event) else {
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
    }
    
    func handleEvent(event: NSEvent) -> Bool {
        guard event.type == .systemDefined, event.subtype.rawValue == 211, event.data1 == 1 else {
            return false
        }
        
        sticky = event.modifierFlags.contains(.shift)
        
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
        
        AppDelegate.setStatusIcon(enabled: state)
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
    
    let isCmdDown = event.flags.rawValue & CGEventFlags.maskCommand.rawValue > 0
    let isPrimaryCmd = isCmdDown && (event.flags.rawValue & primaryCommandFlag) > 0
    let isSecondaryCmd = isCmdDown && (event.flags.rawValue & secondaryCommandFlag) > 0

    let shouldConsume = isSecondaryCmd
    let shouldActivateMappedCommand = isCmdDown && isSecondaryCmd

    if shouldActivateMappedCommand {
        // FIX: Temporarily disabled due to quirky behavior.
//        CapsLockManager.instance.changeLanguage()
    }
    if isSecondaryCmd {
        let filteredRawFlags = event.flags.rawValue &
            (isPrimaryCmd
                ? ~secondaryCommandFlag
                : ~(CGEventFlags.maskCommand.rawValue | secondaryCommandFlag))
        event.flags = CGEventFlags(rawValue: filteredRawFlags)
    }

    return shouldConsume ? nil : Unmanaged.passRetained(event)
}
