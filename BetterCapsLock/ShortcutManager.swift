//
//  ShortcutManager.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2021/05/30.
//

import Foundation

let TARGET_METAS = [CGEventFlags.maskCommand, CGEventFlags.maskControl, CGEventFlags.maskAlternate, CGEventFlags.maskShift, CGEventFlags.maskSecondaryFn]
let RAW_TARGET_METAS = TARGET_METAS.reduce(0) { $0 | $1.rawValue }

struct KeyBinding {
    let metas: CGEventFlags?
    let keyCode: KeyCodes
}

enum KeyCodes: Int64, CaseIterable {
    case left = 123
    case right = 124
    case down = 125
    case up = 126
    
    case a = 0, s, d, f, h, g, z, x, c, v,
         b = 11, q, w, e, r, y, t,
         num_1, num_2, num_3, num_4, num_6, num_5, sym_equal, num_9, num_7, sym_minus, num_8, num_0,
         sym_braket_close, o, u, sym_braket_open, i, p, cmd_return, l, j, sym_quote, k, sym_semicolon, sym_backslask, sym_comma, sym_slash, n, m, sym_period, cmd_tab, space, sym_backtick, cmd_backspace, cmd_enter, cmd_escape,
         mod_secondary_command = 54, mod_command, mod_shift, mod_alternate = 58, mod_control, mod_fn = 63
    case sym_numpad_period = 65,
         sym_numpad_asterisk = 67,
         sym_numpad_plus = 69,
         sym_numpad_clear = 71,
         sym_numpad_slash = 75,
         sym_numpad_enter,
         sym_numpad_minus = 78,
         sym_numpad_equal = 81,
         sym_numpad_0 = 82, sym_numpad_1, sym_numpad_2, sym_numpad_3, sym_numpad_4, sym_numpad_5, sym_numpad_6, sym_numpad_7, sym_numpad_8 = 91, sym_numpad_9
    case F5 = 96, F6, F7, F3, F8, F9,
         F11 = 103,
         F13 = 105,
         F14 = 107,
         F10 = 109,
         F12 = 111,
         F15 = 113,
         cmd_help = 114,
         cmd_home = 115,
         cmd_pgup = 116,
         cmd_delete = 117,
         F4 = 118,
         cmd_end = 119,
         F2 = 120,
         cmd_pgdn = 121,
         F1 = 122
}

let keyBindings = [
    CGEventFlags.maskAlternate.rawValue: [
        KeyCodes.h: KeyBinding(metas: nil, keyCode: .left),
        KeyCodes.l: KeyBinding(metas: nil, keyCode: .right),
        KeyCodes.k: KeyBinding(metas: nil, keyCode: .up),
        KeyCodes.j: KeyBinding(metas: nil, keyCode: .down),
        KeyCodes.p: KeyBinding(metas: nil, keyCode: .up),
        KeyCodes.n: KeyBinding(metas: nil, keyCode: .down),
        KeyCodes.q: KeyBinding(metas: .maskLeftAlternate, keyCode: .left),
        KeyCodes.w: KeyBinding(metas: .maskLeftAlternate, keyCode: .right),
        KeyCodes.b: KeyBinding(metas: .maskLeftAlternate, keyCode: .left),
        KeyCodes.f: KeyBinding(metas: .maskLeftAlternate, keyCode: .right),
        KeyCodes.i: KeyBinding(metas: .maskLeftAlternate, keyCode: .left),
        KeyCodes.o: KeyBinding(metas: .maskLeftAlternate, keyCode: .right),
        KeyCodes.a: KeyBinding(metas: .maskLeftCommand, keyCode: .left),
        KeyCodes.e: KeyBinding(metas: .maskLeftCommand, keyCode: .right),
        KeyCodes.sym_equal: KeyBinding(metas: .maskLeftCommand, keyCode: .up),
        KeyCodes.sym_minus: KeyBinding(metas: .maskLeftCommand, keyCode: .down),
    ],
    CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue: [
        KeyCodes.h: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .left),
        KeyCodes.l: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .right),
        KeyCodes.k: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .up),
        KeyCodes.j: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .down),
        KeyCodes.p: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .up),
        KeyCodes.n: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftShift.rawValue), keyCode: .down),
        KeyCodes.q: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .left),
        KeyCodes.w: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .right),
        KeyCodes.b: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .left),
        KeyCodes.f: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .right),
        KeyCodes.i: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .left),
        KeyCodes.o: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftAlternate.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .right),
        KeyCodes.a: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftCommand.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .left),
        KeyCodes.e: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftCommand.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .right),
        KeyCodes.sym_equal: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftCommand.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .up),
        KeyCodes.sym_minus: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskLeftCommand.rawValue | CGEventFlags.maskLeftShift.rawValue), keyCode: .down),
    ],
    CGEventFlags.maskSecondaryFn.rawValue: [
        KeyCodes.cmd_home: KeyBinding(metas: .maskLeftCommand, keyCode: .left),
        KeyCodes.cmd_end: KeyBinding(metas: .maskLeftCommand, keyCode: .right),
    ],
]

class ShortcutManager {
    
    static func initialize() {
        KeyInterceptor.interceptEvents(eventTypes: [.keyDown, .keyUp], callback: keyEventCallback)
    }
}

func keyEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard [.keyDown , .keyUp].contains(type) else {
        return Unmanaged.passRetained(event)
    }
    
    // XXX: Debug message
    if type == .keyDown {
        print("<<<<")
        print("Original event:")
        pringKeyboardEventDetails(event: event)
        print()
    }
    
    let lrudClearMask = CGEventFlags.maskNumericPad.union(CGEventFlags.maskSecondaryFn)
    let lrudClear = Set<KeyCodes>(arrayLiteral: .left, .right, .up, .down, .sym_numpad_clear)
    
    let rawKeyCode = event.getIntegerValueField(.keyboardEventKeycode)
    let rawMeta = event.flags.rawValue & RAW_TARGET_METAS

    if let keyBindingsPerMeta = keyBindings[rawMeta],
       let keyCode = KeyCodes(rawValue: rawKeyCode),
       let keyBinding = keyBindingsPerMeta[keyCode] {
        event.flags = CGEventFlags(rawValue: CGEventFlags.maskNonCoalesced.rawValue | (keyBinding.metas?.rawValue ?? 0))
        event.setIntegerValueField(.keyboardEventKeycode, value: keyBinding.keyCode.rawValue)
        
        if lrudClear.contains(keyBinding.keyCode) {
            event.flags.insert(lrudClearMask)
        }
    }
    
    // XXX: Debug message
    if type == .keyDown {
        print("Updated event:")
        pringKeyboardEventDetails(event: event)
        print(">>>>")
        print()
        print()
    }
    return Unmanaged.passRetained(event)
}

func pringKeyboardEventDetails(event: CGEvent) {
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    
    let modifiers: [String?] = [
        event.flags.contains(.maskLeftShift) ? "⇧_L" : nil,
        event.flags.contains(.maskRightShift) ? "⇧_R" : nil,
        event.flags.contains(.maskLeftControl) ? "^_L" : nil,
        event.flags.contains(.maskRightControl) ? "^_R" : nil,
        event.flags.contains(.maskLeftAlternate) ? "⌥_L" : nil,
        event.flags.contains(.maskRightAlternate) ? "⌥_R" : nil,
        event.flags.contains(.maskLeftCommand) ? "⌘_L" : nil,
        event.flags.contains(.maskRightCommand) ? "⌘_R" : nil,
    ]

    let otherFalgs: [String?] = [
        event.flags.contains(.maskAlphaShift) ? "AlphaShift" : nil,
        event.flags.contains(.maskHelp) ? "Help" : nil,
        event.flags.contains(.maskSecondaryFn) ? "SecondaryFn" : nil,
        event.flags.contains(.maskNumericPad) ? "NumericPad" : nil,
        event.flags.contains(.maskNonCoalesced) ? "NonCoalesced" : nil,
    ]

    let flagsMessage = "\(modifiers.compactMap({$0 != nil ? $0! : nil}).joined(separator: " + "))(\(otherFalgs.compactMap({$0 != nil ? $0! : nil}).joined(separator: " + ")))"
    print(KeyCodes.init(rawValue: keyCode) ?? keyCode)
    print(flagsMessage)
    print(toSplittedBinaryRepr(event.flags.rawValue))
}

func printLog<T>(tag: String, log: T) where T: BinaryInteger {
    printLog(tag: tag, log: "\(toBinaryRepr(log))", rawValue: log)
}

func printLog<T>(tag: String, log: String, rawValue: T) where T: BinaryInteger {
    if true {
        return
    }
    print("\(pad(string: tag, toSize: 20, with: " ", prepend: false)): \(pad(string: log, toSize: 32))(\(rawValue))")
}

func toSplittedBinaryRepr<T>(_ value: T) -> String where T: BinaryInteger {
    return String(toBinaryRepr(value).reversed().enumerated().map { (index, elem) -> String in
        return index > 0 && index % 4 == 0 ? "\(elem) " : "\(elem)"
    }.reversed().reduce(into: "", { $0 += $1 }))
}

func toBinaryRepr<T>(_ value: T) -> String where T: BinaryInteger {
    return String(value, radix: 2)
}

func pad(string: String, toSize: Int, with: String = "0", prepend: Bool = true) -> String {
    var padded = string
    for _ in 0..<(toSize - string.count) {
        padded = prepend ? with + padded : padded + with
    }
    return padded
}

extension CGEventFlags {
    static var maskLeftShift: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue | (1 << 1))
    }
    static var maskRightShift: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue | (1 << 2))
    }
    static var maskLeftControl: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskControl.rawValue | (1 << 0))
    }
    static var maskRightControl: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskControl.rawValue | (1 << 13))
    }
    static var maskLeftAlternate: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | (1 << 5))
    }
    static var maskRightAlternate: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | (1 << 6))
    }
    static var maskLeftCommand: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | (1 << 3))
    }
    static var maskRightCommand: CGEventFlags {
      CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | (1 << 4))
    }
}
