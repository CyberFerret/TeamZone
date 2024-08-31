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

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .fullSizeContentView], backing: backingStoreType, defer: flag)

        // Disable standard resize behavior
        self.styleMask.remove(.resizable)

        // Set the window to be non-movable
        self.isMovable = false

        // Set a fixed width
        self.minSize = NSSize(width: 400, height: 300)
        self.maxSize = NSSize(width: 400, height: NSScreen.main!.visibleFrame.height / 2)
    }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        guard let initialFrame = initialFrame else {
            self.initialFrame = frameRect
            return frameRect
        }

        var newFrame = frameRect
        newFrame.origin.x = initialFrame.origin.x
        newFrame.size.width = initialFrame.size.width

        // Constrain the height between minSize and maxSize
        let minHeight: CGFloat = 300
        let maxHeight = NSScreen.main!.visibleFrame.height / 2
        newFrame.size.height = max(minHeight, min(newFrame.size.height, maxHeight))

        // Ensure the top of the window stays in place
        newFrame.origin.y = initialFrame.maxY - newFrame.size.height

        return newFrame
    }

    override func mouseDragged(with event: NSEvent) {
        // Do nothing to prevent window dragging
    }
}

class ResizablePopoverViewController: NSViewController {
    var hostingController: NSHostingController<AnyView>?
    var userSettings: UserSettings
    private var resizeHandle: NSView!
    private var lastHeight: CGFloat = 0
    private var isResizing = false

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

        // Add a resize handle to the bottom of the view
        resizeHandle = NSView()
        resizeHandle.wantsLayer = true
        resizeHandle.layer?.backgroundColor = NSColor.clear.cgColor

        self.view.addSubview(resizeHandle)
        resizeHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resizeHandle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            resizeHandle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            resizeHandle.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            resizeHandle.heightAnchor.constraint(equalToConstant: 10)
        ])

        let resizeHandleTrackingArea = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        resizeHandle.addTrackingArea(resizeHandleTrackingArea)

        resizeHandle.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(handleResize(_:))))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let window = self.view.window as? ResizableWindow {
            window.minSize = NSSize(width: 400, height: 300)
            window.maxSize = NSSize(width: 400, height: NSScreen.main!.visibleFrame.height / 2)
            window.setContentSize(NSSize(width: 400, height: userSettings.windowHeight))
            lastHeight = userSettings.windowHeight
        }
    }

    override func mouseEntered(with event: NSEvent) {
        if event.trackingArea?.owner as? NSView == resizeHandle {
            NSCursor.resizeUpDown.set()
        }
    }

    override func mouseExited(with event: NSEvent) {
        if event.trackingArea?.owner as? NSView == resizeHandle {
            NSCursor.arrow.set()
        }
    }

    @objc func handleResize(_ gestureRecognizer: NSPanGestureRecognizer) {
        guard let window = self.view.window as? ResizableWindow else { return }

        switch gestureRecognizer.state {
        case .began:
            isResizing = true
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            var newFrame = window.frame
            newFrame.size.height -= translation.y

            // Constrain the height between minSize and maxSize
            let minHeight: CGFloat = 300
            let maxHeight = NSScreen.main!.visibleFrame.height / 2
            newFrame.size.height = max(minHeight, min(newFrame.size.height, maxHeight))

            // Adjust the origin to keep the top of the window in place
            newFrame.origin.y = window.frame.maxY - newFrame.size.height

            window.setFrame(newFrame, display: true, animate: false)
            gestureRecognizer.setTranslation(.zero, in: self.view)
        case .ended:
            isResizing = false
            userSettings.windowHeight = window.frame.height
        default:
            break
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

        let maxHeight = min(NSScreen.main!.visibleFrame.height * 0.5, 600)
        let rootView = ResizableView(maxHeight: maxHeight)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(viewModel)
            .environmentObject(userSettings)
            .environment(\.colorScheme, .dark) // Force dark mode

        let contentViewController = ResizablePopoverViewController(rootView: AnyView(rootView), userSettings: userSettings)

        let savedHeight = UserDefaults.standard.double(forKey: "windowHeight")
        let initialHeight = savedHeight > 300 ? savedHeight : 450

        popoverWindow = ResizableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: initialHeight),
            styleMask: [.borderless, .fullSizeContentView],
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

                    let maxHeight = min(screen.frame.height * 0.5, 600)
                    window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: maxHeight)

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
    let maxHeight: CGFloat

    var body: some View {
        TeamListView(maxHeight: maxHeight)
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
