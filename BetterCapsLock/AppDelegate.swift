//
//  AppDelegate.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    static var statusItem: NSStatusItem!
    
    let capsLockManager = CapsLockManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (!capsLockManager.requestAccess()) {
            exit(1)
        }
        AppDelegate.initStatusItem()
        AppDelegate.setStatusIcon()
        
        capsLockManager.registerEventListener()

        ShortcutManager.initialize()
    }
    
    static func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.highlightMode = false
    }
    
    static func setStatusIcon(enabled: Bool = false) {
        let icon = NSImage(named: NSImage.Name(enabled ? "StatusIconActive" : "StatusIcon"))
        icon?.size = NSSize(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        icon?.backgroundColor = .red
        
        statusItem.button?.image = icon
    }
}
