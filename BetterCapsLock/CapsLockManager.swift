//
//  CapsLockManager.swift
//  CapsLockNoDelay
//
//  Created by Guy Kaplan on 31/10/2020.
//

import Foundation
import Cocoa
import Carbon

enum Language: String, CaseIterable {
    case ABC, Hiragana, Korean="2-Set Korean"
    
    var order: Int! {
        switch self {
        case .ABC:
            return 0
        case .Hiragana:
            return 1
        case .Korean:
            return 2
        }
    }
    
    static var current: Language! {
        let curLangName = TISCopyCurrentKeyboardInputSource().takeUnretainedValue().name
        return Language(rawValue: curLangName)
    }
    
    var next: Language {
        switch self {
        case .ABC:
            return .Korean
        case .Korean:
            return .Hiragana
        case .Hiragana:
            return .ABC
        }
    }
    
    func distance(toLanguage target: Language) -> Int {
        let src = self.order!
        let dest = target.order!
        
        let diff = dest - src
        switch diff {
        case let d where d > 0:
            return d
        case let d where d < 0:
            return d + Language.allCases.count
        case let d where d == 0:
            return 0
        default:
            // Won't ever occur
            return -1
        }
    }
}

class CapsLockManager {
    var sticky = false
    var alternativeLanguage: Language? = nil
    
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
        guard let currentLanguage = Language.current else {
             return
        }
        var targetLanguage: Language!
        switch currentLanguage {
        case .ABC:
            if self.alternativeLanguage == nil {
                self.alternativeLanguage = currentLanguage.next
            }
            targetLanguage = self.alternativeLanguage
        default:
            self.alternativeLanguage = currentLanguage
            targetLanguage = Language.ABC
        }
        
        guard targetLanguage != nil else {
            return
        }
        changeLanguage(distance: currentLanguage.distance(toLanguage: targetLanguage))
    }
    
    func changeLanguage(distance: Int) {
        let eventSource = CGEventSource(stateID: .hidSystemState)

        let cmdDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x38, keyDown: true)
        let cmdUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x38, keyDown: false)
        let spaceDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x31, keyDown: true)
        let spaceUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x31, keyDown: false)

        spaceDown?.flags = .maskCommand
        spaceUp?.flags = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        for _ in 0..<distance {
            spaceDown?.post(tap: .cghidEventTap)
            spaceUp?.post(tap: .cghidEventTap)
        }
        cmdUp?.post(tap: .cghidEventTap)
    }

    func setCapsLockState(_ state: Bool) {
        var ioConnect: io_connect_t = .init(0)
        let ioService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(kIOHIDSystemClass))
        IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)
        IOHIDSetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), state)
        IOServiceClose(ioConnect)
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
