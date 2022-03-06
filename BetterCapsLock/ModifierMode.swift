//
//  ModifierMode.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/03/06.
//

import Foundation

private let KEY_MODIFIER_MODE = "modifier_mode"

enum ModifierMode: String, CaseIterable {
    case CapsLock, SecondaryCommand
    
    static func getCurrent() -> Self {
        if let modifierMode = UserDefaults.standard.value(forKey: "modifier_mode") as? String {
            return ModifierMode(rawValue: modifierMode)!
        } else {
            return ModifierMode.CapsLock
        }
    }
    
    static func update(mode: Self) {
        UserDefaults.standard.setValue(mode.rawValue, forKey: KEY_MODIFIER_MODE)
    }
}
