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
    var sticky = false
    var alternativeInputSource: InputSource? = nil
    
    var capsLockDelay: Int {
        IOHIDServiceClient.getValue(key: kIOHIDKeyboardCapsLockDelayOverrideKey) as! Int
    }

    func requestAccess() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Access Not Enabled")
            return false
        }
        return true
    }
    
    func registerEventListener() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyUp, .systemDefined]) { (event) in
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
