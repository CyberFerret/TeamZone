import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private init() {
        do {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("CityTimeZoneData.db").path

            // Check if the database file exists in the Documents directory
            if !fileManager.fileExists(atPath: dbPath) {
                // If not, copy it from the app bundle
                guard let bundleDbPath = Bundle.main.path(forResource: "CityTimeZoneData", ofType: "db") else {
                    print("Error: Database file not found in app bundle")
                    print("Bundle resource paths:")
                    for path in Bundle.main.paths(forResourcesOfType: "db", inDirectory: nil) {
                        print(path)
                    }
                    return
                }

                do {
                    try fileManager.copyItem(atPath: bundleDbPath, toPath: dbPath)
                    print("Database copied successfully to: \(dbPath)")
                } catch {
                    print("Error copying database file: \(error)")
                    return
                }
            }

            // Open the database connection
            db = try Connection(dbPath)
            print("Database opened successfully at: \(dbPath)")
        } catch {
            print("Error initializing database: \(error)")
        }
    }

    func searchCities(query: String) -> [CityData] {
        guard let db = db else { return [] }

        let cities = Table("cities")
        let cityColumn = Expression<String>("city")
        let countryColumn = Expression<String>("country")
        let timezoneColumn = Expression<String>("timezone")

        do {
            let results = try db.prepare(cities
                .filter(cityColumn.like("%\(query)%"))
                .filter(cityColumn != "")
                .filter(countryColumn != "")
                .order(countryColumn.collate(.nocase), cityColumn.collate(.nocase))
                .limit(50))

            let cityData = results.map { row in
                CityData(city: row[cityColumn], country: row[countryColumn], timezone: row[timezoneColumn])
            }

            let uniqueResults = Array(Set(cityData)).sorted {
                if $0.country.lowercased() == $1.country.lowercased() {
                    return $0.city.lowercased() < $1.city.lowercased()
                }
                return $0.country.lowercased() < $1.country.lowercased()
            }

            return Array(uniqueResults.prefix(10))
        } catch {
            print("Error searching cities: \(error)")
            return []
        }
    }
}
