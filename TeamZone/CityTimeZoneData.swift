import Foundation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let timeZone: String
}

class CityTimeZoneData {
    static let cities = [
        City(name: "New York", timeZone: "America/New_York"),
        City(name: "Los Angeles", timeZone: "America/Los_Angeles"),
        City(name: "London", timeZone: "Europe/London"),
        City(name: "Paris", timeZone: "Europe/Paris"),
        City(name: "Tokyo", timeZone: "Asia/Tokyo"),
        City(name: "Sydney", timeZone: "Australia/Sydney"),
        // Add more cities as needed
    ]

    static let allTimeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
}
