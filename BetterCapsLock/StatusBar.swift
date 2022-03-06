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
        let modifierMenuItem = createModifierMenuItem()
        let secretMenuItem = createSecretMenuItem()
        let quitMenuItem = createQuitMenuItem()
        
        let menu = NSMenu()
        menu.addItem(modifierMenuItem)
        menu.addItem(secretMenuItem)
        menu.addItem(quitMenuItem)
        
        statusItem.menu = menu
    }
    
    func createModifierMenuItem() -> NSMenuItem {
        let modifierMenuItem = NSMenuItem()
        modifierMenuItem.title = "Switch mode"
        modifierMenuItem.submenu = NSMenu()
        
        for (index, modifierMode) in ModifierMode.allCases.enumerated() {
            modifierMenuItem.submenu!.addItem(createModeMenu(index: index, modifierMode: modifierMode))
        }
        
        return modifierMenuItem
    }
    
    func createSecretMenuItem() -> NSMenuItem {
        let secretMenuItem = NSMenuItem(title: SecretMode.enabled ? "Back to normal" : "You don't want this.", action: #selector(toggleSecretMode(_:)), keyEquivalent: "")
        secretMenuItem.target = self
        secretMenuItem.isAlternate = true
        secretMenuItem.keyEquivalentModifierMask = [.option]
        
        return secretMenuItem
    }
    
    func createQuitMenuItem() -> NSMenuItem {
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "")
        quitMenuItem.target = self
        
        return quitMenuItem
    }
    
    func createModeMenu(index: Int, modifierMode: ModifierMode) -> NSMenuItem {
        let currMode = ModifierMode.getCurrent()
        let isCurrentMode = modifierMode == currMode
        
        let modeMenuItem = NSMenuItem(title: "\(modifierMode.rawValue)(\(isCurrentMode ? "On" : "Off"))", action: #selector(selectModifierMode(_:)), keyEquivalent: "")
        modeMenuItem.target = self
        modeMenuItem.tag = index
        
        return modeMenuItem
    }

    func setStatusIcon(enabled: Bool = false) {
        let icon = NSImage(named: NSImage.Name(enabled ? "StatusIconActive" : "StatusIcon"))
        icon?.size = NSSize(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        
        statusItem.button?.image = icon
    }
    
    @objc func toggleSecretMode(_ sender: AnyObject?) {
        SecretMode.toggle()
        
        relaunch()
    }
    
    @objc func selectModifierMode(_ sender: NSMenuItem) {
        let mode = ModifierMode.allCases[sender.tag]
        ModifierMode.update(mode: mode)
        
        relaunch()
    }

    @objc func quit(_ sender: AnyObject?) {
        exit(0)
    }
    
    func relaunch() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
}

class SecretMode {
    
    static let KEY_SECRET_MODE_ENABLED = "isSecretModeEnabled"
    
    static var enabled: Bool {
        return UserDefaults.standard.bool(forKey: KEY_SECRET_MODE_ENABLED)
    }
    
    static func toggle() {
        UserDefaults.standard.setValue(!enabled, forKey: KEY_SECRET_MODE_ENABLED)
    }
}
