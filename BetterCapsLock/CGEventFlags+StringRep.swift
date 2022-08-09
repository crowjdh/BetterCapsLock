//
//  CGEventFlags+StringRep.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/08/09.
//

import Foundation

let FlagsMap = [
    CGEventFlags.maskShift.rawValue: [
        CGEventFlags.bitsLeftShift: "⇧_L",
        CGEventFlags.bitsRightShift: "⇧_R",
    ],
    CGEventFlags.maskControl.rawValue: [
        CGEventFlags.bitsLeftControl: "^_L",
        CGEventFlags.bitsRightControl: "^_R",
    ],
    CGEventFlags.maskAlternate.rawValue: [
        CGEventFlags.bitsLeftAlternate: "⌥_L",
        CGEventFlags.bitsRightAlternate: "⌥_R",
    ],
    CGEventFlags.maskCommand.rawValue: [
        CGEventFlags.bitsLeftCommand: "⌘_L",
        CGEventFlags.bitsRightCommand: "⌘_R",
    ],
]

let OtherFlagsMap = [
    CGEventFlags.maskAlphaShift.rawValue: "AlphaShift",
    CGEventFlags.maskHelp.rawValue: "Help",
    CGEventFlags.maskSecondaryFn.rawValue: "SecondaryFn",
    CGEventFlags.maskNumericPad.rawValue: "NumericPad",
    CGEventFlags.maskNonCoalesced.rawValue: "NonCoalesced",
]

extension CGEventFlags {
    var stringRepresentation: String {
        let flagReprs: [[String]] = FlagsMap.compactMap { rawValue, locBits in
            if self.rawValue & rawValue == 0 {
                return nil
            }
            return locBits.compactMap { (bits, repr) -> String? in
                return self.rawValue & bits > 0 ? repr : nil
            }
        }
        
        let otherFlagReprs = OtherFlagsMap.compactMap { rawValue, repr in
            return self.rawValue & rawValue > 0 ? repr : nil
        }
        let reprs = flagReprs.flatMap { $0 } + otherFlagReprs
        
        return reprs.joined(separator: "|")
    }
}
