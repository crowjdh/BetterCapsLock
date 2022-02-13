//
//  CGEventFlags+KeyCodes.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/02/13.
//

import Foundation

let KeyCodeMap = [
    CGEventFlags.maskCommand.rawValue: KeyCodes.mod_command,
    CGEventFlags.maskShift.rawValue: KeyCodes.mod_shift,
    CGEventFlags.maskControl.rawValue: KeyCodes.mod_control,
    CGEventFlags.maskAlternate.rawValue: KeyCodes.mod_alternate,
    CGEventFlags.maskSecondaryFn.rawValue: KeyCodes.mod_fn,
]

extension CGEventFlags {
    var keyCode: KeyCodes? {
        KeyCodeMap[self.rawValue]
    }
}
