//
//  TeamZoneApp.swift
//  TeamZone
//
//  Created by Devan Sabaratnam on 28/8/2024.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let persistenceController = PersistenceController.shared
    let viewModel: TeamViewModel
    let userSettings = UserSettings()

    override init() {
        self.viewModel = TeamViewModel(context: persistenceController.container.viewContext)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        setupMenuBarItem()
    }

    func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Team Zone")
            button.action = #selector(togglePopover)
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 450) // Increased width to 400
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: TeamListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
                .environmentObject(userSettings)
        )
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

@main
struct TeamZoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
