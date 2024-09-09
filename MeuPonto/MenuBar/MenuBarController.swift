//
//  MenuBarController.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import SwiftUI

class MenuBarController {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    init() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "App de Ponto")
            button.action = #selector(AppDelegate.shared.menuBarClicked)
        }
    }
}
