//
//  AppDelegate.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (!CapsLockManager.requestAccess()) {
            exit(1)
        }
        StatusBar.instance.initialize()
        
        CapsLockManager.initialize()

        if ModifierMode.getCurrent() == .CapsLock && SecretMode.enabled {
            ShortcutManager.initialize()
        }
    }
}
