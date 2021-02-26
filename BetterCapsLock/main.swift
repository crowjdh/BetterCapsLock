//
//  main.swift
//  BetterCapsLock
//
//  Created by Donghyun Jung on 2021/02/26.
//

import Cocoa

// Create an app delegate without GUI.
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
