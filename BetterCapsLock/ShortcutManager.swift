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
         mod_command = 55, mod_shift, mod_alternate = 58, mod_control, mod_fn = 63
    case sym_numpad_period = 65,
         sym_numpad_asterisk = 67,
         sym_numpad_plus = 69,
         sym_numpad_clear = 71,
         sym_numpad_slash = 75,
         sym_numpad_enter,
         sym_numpad_minus = 78,
         sym_numpad_equal = 81,
         sym_numpad_0 = 82, sym_numpad_1, sym_numpad_2, sym_numpad_3, sym_numpad_4, sym_numpad_5, sym_numpad_6, sym_numpad_7, sym_numpad_8, sym_numpad_9
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
        KeyCodes.q: KeyBinding(metas: .maskAlternate, keyCode: .left),
        KeyCodes.w: KeyBinding(metas: .maskAlternate, keyCode: .right),
        KeyCodes.b: KeyBinding(metas: .maskAlternate, keyCode: .left),
        KeyCodes.f: KeyBinding(metas: .maskAlternate, keyCode: .right),
        KeyCodes.i: KeyBinding(metas: .maskAlternate, keyCode: .left),
        KeyCodes.o: KeyBinding(metas: .maskAlternate, keyCode: .right),
        KeyCodes.a: KeyBinding(metas: .maskCommand, keyCode: .left),
        KeyCodes.e: KeyBinding(metas: .maskCommand, keyCode: .right),
        KeyCodes.sym_equal: KeyBinding(metas: .maskCommand, keyCode: .up),
        KeyCodes.sym_minus: KeyBinding(metas: .maskCommand, keyCode: .down),
    ],
    CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue: [
        KeyCodes.h: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .left),
        KeyCodes.l: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .right),
        KeyCodes.k: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .up),
        KeyCodes.j: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .down),
        KeyCodes.p: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .up),
        KeyCodes.n: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue), keyCode: .down),
        KeyCodes.q: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .left),
        KeyCodes.w: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .right),
        KeyCodes.b: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .left),
        KeyCodes.f: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .right),
        KeyCodes.i: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .left),
        KeyCodes.o: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .right),
        KeyCodes.a: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .left),
        KeyCodes.e: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .right),
        KeyCodes.sym_equal: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .up),
        KeyCodes.sym_minus: KeyBinding(metas: CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue), keyCode: .down),
    ],
    CGEventFlags.maskSecondaryFn.rawValue: [
        KeyCodes.cmd_home: KeyBinding(metas: .maskCommand, keyCode: .left),
        KeyCodes.cmd_end: KeyBinding(metas: .maskCommand, keyCode: .right),
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
    
    let rawKeyCode = event.getIntegerValueField(.keyboardEventKeycode)
    let rawMeta = event.flags.rawValue & (RAW_TARGET_METAS)
    
    if let keyBindingsPerMeta = keyBindings[rawMeta],
       let keyCode = KeyCodes(rawValue: rawKeyCode),
       let keyBinding = keyBindingsPerMeta[keyCode] {
        
        event.flags = keyBinding.metas ?? CGEventFlags.maskNonCoalesced
        event.setIntegerValueField(.keyboardEventKeycode, value: keyBinding.keyCode.rawValue)
    }
    return Unmanaged.passRetained(event)
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
