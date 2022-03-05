//
//  KeyInterceptor.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/03/05.
//

import Foundation

class KeyInterceptor {
    
    static func interceptEvents(eventTypes: [CGEventType], callback: @escaping CGEventTapCallBack) {
        let eventMask = eventTypes.reduce(0) { accum, eventType in
            accum | (1 << eventType.rawValue)
        }
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: callback,
                                               userInfo: nil) else {
            print("failed to create event tap")
            exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
}
