//
//  AppDelegate.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let capsLockManager = CapsLockManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (!capsLockManager.requestAccess()) {
            exit(1)
        }
        
        capsLockManager.registerEventListener()
        
        ShortcutManager.initialize()
    }
}
