import Foundation

class UserSettings: ObservableObject {
    @Published var use24HourTime: Bool {
        didSet {
            UserDefaults.standard.set(use24HourTime, forKey: "use24HourTime")
        }
    }

    @Published var windowHeight: CGFloat {
        didSet {
            UserDefaults.standard.set(windowHeight, forKey: "windowHeight")
        }
    }

    init() {
        self.use24HourTime = UserDefaults.standard.bool(forKey: "use24HourTime")
        self.windowHeight = UserDefaults.standard.double(forKey: "windowHeight")

        if self.windowHeight < 300 {
            self.windowHeight = 450 // Default height
        }
    }
}
