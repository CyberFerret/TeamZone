import Foundation

class UserSettings: ObservableObject {
    @Published var use24HourTime: Bool {
        didSet {
            UserDefaults.standard.set(use24HourTime, forKey: "use24HourTime")
        }
    }

    init() {
        self.use24HourTime = UserDefaults.standard.bool(forKey: "use24HourTime")
    }
}
