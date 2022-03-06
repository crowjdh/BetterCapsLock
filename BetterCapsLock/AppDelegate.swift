//
//  AppDelegate.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

// TODO: Implement options view for choosing between two modes
// Temporary flag for choosing between two modes.
let debugUseCmd = true

class AppDelegate: NSObject, NSApplicationDelegate {
    static var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (!CapsLockManager.requestAccess()) {
            exit(1)
        }
        AppDelegate.initStatusItem()
        AppDelegate.setStatusIcon()
        
        CapsLockManager.initialize()

        if !debugUseCmd || true {
            ShortcutManager.initialize()
        }
    }
    
    static func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.highlightMode = false
        statusItem.button?.setButtonType(.pushOnPushOff)
        
        let editMenuItem = NSMenuItem()
        editMenuItem.title = "Quit"
        editMenuItem.action = #selector(quit(_:))
        editMenuItem.target = self
        
        let menu = NSMenu()
        menu.addItem(editMenuItem)
        
        statusItem.menu = menu
    }
    
    static func setStatusIcon(enabled: Bool = false) {
        let icon = NSImage(named: NSImage.Name(enabled ? "StatusIconActive" : "StatusIcon"))
        icon?.size = NSSize(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        
        statusItem.button?.image = icon
    }
    
    @objc static func quit(_ sender: AnyObject?) {
        exit(0)
    }
}
