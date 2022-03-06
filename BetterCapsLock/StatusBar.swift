//
//  StatusBar.swift
//  BetterCapsLock
//
//  Created by DongHyun Jung on 2022/03/06.
//

import Cocoa

class StatusBar {
    
    static let instance = StatusBar()
    
    var statusItem: NSStatusItem!
    
    private init() {
    }
    
    func initialize() {
        initStatusItem()
        setStatusIcon()
    }

    func initStatusItem() {
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

    func setStatusIcon(enabled: Bool = false) {
        let icon = NSImage(named: NSImage.Name(enabled ? "StatusIconActive" : "StatusIcon"))
        icon?.size = NSSize(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        
        statusItem.button?.image = icon
    }

    @objc func quit(_ sender: AnyObject?) {
        exit(0)
    }
}
