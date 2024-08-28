//
//  TeamZoneApp.swift
//  TeamZone
//
//  Created by Devan Sabaratnam on 28/8/2024.
//

import SwiftUI

@main
struct TeamZoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
