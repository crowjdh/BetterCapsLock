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
        initMenu()
        setStatusIcon()
    }

    func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.highlightMode = false
        statusItem.button?.setButtonType(.pushOnPushOff)
    }
    
    func initMenu() {
        let modifierMenuItem = NSMenuItem()
        modifierMenuItem.title = "Switch mode"
        let modifierMenu = NSMenu()
        modifierMenuItem.submenu = modifierMenu
        
        let currMode = ModifierMode.getCurrent()
        for (index, modifierMode) in ModifierMode.allCases.enumerated() {
            let isCurrentMode = modifierMode == currMode
            let asdf = NSMenuItem(title: "\(modifierMode.rawValue)(\(isCurrentMode ? "On" : "Off"))", action: #selector(selectModifierMode(_:)), keyEquivalent: "")
            asdf.target = self
            asdf.tag = index
            modifierMenu.addItem(asdf)
        }
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "")
        quitMenuItem.target = self
        
        let menu = NSMenu()
        menu.addItem(modifierMenuItem)
        menu.addItem(quitMenuItem)
        
        statusItem.menu = menu
    }

    func setStatusIcon(enabled: Bool = false) {
        let icon = NSImage(named: NSImage.Name(enabled ? "StatusIconActive" : "StatusIcon"))
        icon?.size = NSSize(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        
        statusItem.button?.image = icon
    }
    
    @objc func selectModifierMode(_ sender: NSMenuItem) {
        let mode = ModifierMode.allCases[sender.tag]
        ModifierMode.update(mode: mode)
        
        initMenu()
    }

    @objc func quit(_ sender: AnyObject?) {
        exit(0)
    }
}
