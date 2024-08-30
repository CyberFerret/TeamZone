import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        do {
            guard let dbPath = Bundle.main.path(forResource: "CityTimeZoneData", ofType: "db") else {
                print("Database file not found in bundle")
                return
            }

            print("Database path: \(dbPath)")

            if sqlite3_open(dbPath, &db) != SQLITE_OK {
                print("Error opening database")
            } else {
                print("Database opened successfully")
            }
        } catch {
            print("Error setting up database: \(error)")
        }
    }

    func searchCities(query: String) -> [(city: String, country: String, timezone: String)] {
        var results: [(city: String, country: String, timezone: String)] = []
        let queryString = "SELECT city, country, timezone FROM cities WHERE city LIKE ? LIMIT 10"
        var statement: OpaquePointer?

        print("Searching for: \(query)")

        if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, "%\(query)%", -1, nil)

            while sqlite3_step(statement) == SQLITE_ROW {
                let city = String(cString: sqlite3_column_text(statement, 0))
                let country = String(cString: sqlite3_column_text(statement, 1))
                let timezone = String(cString: sqlite3_column_text(statement, 2))
                results.append((city: city, country: country, timezone: timezone))
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        print("Found \(results.count) results")
        return results
    }

    deinit {
        sqlite3_close(db)
    }
}
