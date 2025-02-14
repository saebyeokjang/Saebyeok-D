//
//  SaebyeokDApp.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

@main
struct SaebyeokDApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DDayEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
