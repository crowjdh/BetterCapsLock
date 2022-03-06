//
//  AppDelegate.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

// TODO: Implement options view for choosing between two modes
// Temporary flag for choosing between two modes.
let debugUseCmd = false

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (!CapsLockManager.requestAccess()) {
            exit(1)
        }
        StatusBar.instance.initialize()
        
        CapsLockManager.initialize()

        if !debugUseCmd {
            ShortcutManager.initialize()
        }
    }
}
