//
//  TeamZoneApp.swift
//  TeamZone
//
//  Created by Devan Sabaratnam on 28/8/2024.
//

import SwiftUI
import AppKit

class ResizableWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    var initialFrame: NSRect?

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        guard let initialFrame = initialFrame else {
            self.initialFrame = frameRect
            return frameRect
        }

        var newFrame = frameRect
        newFrame.origin.x = initialFrame.origin.x
        newFrame.origin.y = initialFrame.origin.y
        newFrame.size.width = initialFrame.size.width

        // Constrain the height between minSize and maxSize
        let minHeight: CGFloat = 300
        let maxHeight = NSScreen.main!.visibleFrame.height / 2
        newFrame.size.height = max(minHeight, min(newFrame.size.height, maxHeight))

        return newFrame
    }

    override func mouseDragged(with event: NSEvent) {
        // Do nothing to prevent window dragging
    }
}

class ResizablePopoverViewController: NSViewController {
    var hostingController: NSHostingController<AnyView>?
    var userSettings: UserSettings

    init(rootView: AnyView, userSettings: UserSettings) {
        self.userSettings = userSettings
        super.init(nibName: nil, bundle: nil)
        self.hostingController = NSHostingController(rootView: rootView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
        if let hostView = hostingController?.view {
            hostView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(hostView)
            NSLayoutConstraint.activate([
                hostView.topAnchor.constraint(equalTo: self.view.topAnchor),
                hostView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                hostView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                hostView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let window = self.view.window as? ResizableWindow {
            window.minSize = NSSize(width: 400, height: 300)
            window.maxSize = NSSize(width: 400, height: NSScreen.main!.visibleFrame.height / 2)
            window.setContentSize(NSSize(width: 400, height: userSettings.windowHeight))
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popoverWindow: ResizableWindow?
    let persistenceController = PersistenceController.shared
    let viewModel: TeamViewModel
    @ObservedObject var userSettings = UserSettings()

    override init() {
        self.viewModel = TeamViewModel(context: persistenceController.container.viewContext)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let window = popoverWindow {
            UserDefaults.standard.set(window.frame.height, forKey: "windowHeight")
        }
    }

    func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Team Zone")
            button.action = #selector(togglePopover)
        }

        let rootView = ResizableView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(viewModel)
            .environmentObject(userSettings)
            .environment(\.colorScheme, .dark) // Force dark mode

        let contentViewController = ResizablePopoverViewController(rootView: AnyView(rootView), userSettings: userSettings)

        let savedHeight = UserDefaults.standard.double(forKey: "windowHeight")
        let initialHeight = savedHeight > 300 ? savedHeight : 450

        popoverWindow = ResizableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: initialHeight),
            styleMask: [.borderless, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        popoverWindow?.contentViewController = contentViewController
        popoverWindow?.isReleasedWhenClosed = false
        popoverWindow?.backgroundColor = NSColor(named: "backgroundColor") ?? .black

        // Ensure the window size is set correctly
        popoverWindow?.setContentSize(NSSize(width: 400, height: initialHeight))
    }

    @objc func togglePopover() {
        print("Toggle popover called")
        if let button = statusItem?.button {
            if popoverWindow?.isVisible == true {
                print("Closing popover")
                popoverWindow?.close()
            } else {
                print("Showing popover")
                if let window = popoverWindow, let screen = NSScreen.main {
                    button.highlight(true)

                    // Get the frame of the status item in screen coordinates
                    let buttonFrame = button.window?.convertToScreen(button.convert(button.bounds, to: nil)) ?? .zero

                    // Calculate the window position
                    let windowWidth: CGFloat = 400
                    let windowHeight = window.frame.height
                    let screenFrame = screen.visibleFrame

                    let xPosition = buttonFrame.midX - windowWidth / 2
                    let yPosition = buttonFrame.minY - windowHeight - 5 // 5 pixels gap

                    // Ensure the window is within the screen bounds
                    let adjustedXPosition = max(screenFrame.minX, min(xPosition, screenFrame.maxX - windowWidth))
                    let adjustedYPosition = max(screenFrame.minY, yPosition)

                    let newOrigin = NSPoint(x: adjustedXPosition, y: adjustedYPosition)
                    window.setFrameOrigin(newOrigin)
                    window.initialFrame = window.frame

                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
                button.highlight(false)
            }
        } else {
            print("Status item button not found")
        }
    }
}

struct ResizableView: View {
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        TeamListView()
            .frame(minHeight: 300, maxHeight: .infinity)
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
