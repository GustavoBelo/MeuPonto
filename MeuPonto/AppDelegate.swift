//
//  AppDelegate.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import Cocoa
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var menuBarController: MenuBarController?
    var window: NSWindow?

    static var shared: AppDelegate {
        return NSApp.delegate as! AppDelegate
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ocultar o ícone do dock
        NSApp.setActivationPolicy(.accessory)
        
        // Inicializa o controlador da barra de menu
        menuBarController = MenuBarController()

        // Solicita permissão para notificações
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão para notificações: \(error.localizedDescription)")
            } else if granted {
                print("Permissão para notificações concedida")
            } else {
                print("Permissão para notificações negada")
            }
        }
    }

    @objc func menuBarClicked() {
        // Abrir a janela SwiftUI quando o botão da barra de menu for clicado
        if window == nil {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            window?.isReleasedWhenClosed = false
            window?.center()
            window?.title = "Registrar Ponto"
            
            let hostingController = NSHostingController(rootView: ContentView())
            window?.contentView = hostingController.view
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // Traz o aplicativo para frente
    }

    // Exemplo de como lidar com uma notificação recebida enquanto o app está em execução
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // Exibe a notificação com alerta e som
    }
}
