//
//  Shortcut.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/02/13.
//

import Foundation

class Shortcut {
    let keyCode: CGKeyCode
    let eventFlags: CGEventFlags
    var eventSourceStateID: CGEventSourceStateID = .hidSystemState
    var eventTapLocation: CGEventTapLocation = .cghidEventTap
    
    var eventSource: CGEventSource? {
        CGEventSource(stateID: eventSourceStateID)
    }
    
    init(keyCode: CGKeyCode, eventFlags: CGEventFlags) {
        self.keyCode = keyCode
        self.eventFlags = eventFlags
    }
    
    static var selectPreviousInputSource: Shortcut? {
        guard let dict = UserDefaults.standard.persistentDomain(forName: "com.apple.symbolichotkeys"),
              let symbolichotkeys = dict["AppleSymbolicHotKeys"] as! NSDictionary?,
              // "60" refers to "previous input source" shortcut
              let symbolichotkey = symbolichotkeys["60"] as! NSDictionary?,
              (symbolichotkey["enabled"] as! NSNumber).intValue == 1,
              let value = symbolichotkey["value"] as! NSDictionary?,
              let parameters = value["parameters"] as! NSArray? else {
            return nil
        }
        let rawKeyCode = (parameters[1] as! NSNumber).intValue
        let rawFlags = (parameters[2] as! NSNumber).uint64Value
        
        return Shortcut(keyCode: CGKeyCode(rawKeyCode), eventFlags: CGEventFlags(rawValue: rawFlags))
    }
    
    func post() {
        postEventFlags(keyDown: true)
        postKeyCode()
        postEventFlags(keyDown: false)
    }
    
    private func postKeyCode() {
        let down = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false)
        down?.flags = eventFlags
        up?.flags = eventFlags
        
        down?.post(tap: eventTapLocation)
        up?.post(tap: eventTapLocation)
    }
    
    private func postEventFlags(keyDown: Bool) {
        let metas = TARGET_METAS.filter { $0.rawValue & eventFlags.rawValue > 0 }
        let metaKeyCodes = metas.compactMap { $0.keyCode }
        
        metaKeyCodes.forEach { metaKeyCode in
            let metaDown = CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(metaKeyCode.rawValue), keyDown: keyDown)
            metaDown?.post(tap: eventTapLocation)
        }
    }
}
