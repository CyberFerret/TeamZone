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

        do {
            let sql = """
                SELECT DISTINCT city, country, timezone
                FROM cities
                WHERE (city LIKE ? OR country LIKE ?)
                AND city != ''
                AND country != ''
                ORDER BY
                    CASE
                        WHEN city LIKE ? THEN 0
                        WHEN country LIKE ? THEN 1
                        ELSE 2
                    END,
                    country COLLATE NOCASE,
                    city COLLATE NOCASE
                LIMIT 100
            """

            let queryPattern = "%\(query)%"
            let results = try db.prepare(sql, queryPattern, queryPattern, queryPattern, queryPattern)

            let cityData = results.map { row in
                CityData(city: row[0] as! String, country: row[1] as! String, timezone: row[2] as! String)
            }

            return cityData
        } catch {
            print("Error searching cities: \(error)")
            return []
        }
    }
}
