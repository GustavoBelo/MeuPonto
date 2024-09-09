//
//  MeuPontoApp.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import SwiftUI
import SwiftData

@main
struct MeuPontoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Settings {
            EmptyView() // Isso evita que uma janela principal seja criada
        }
    }
}