import Foundation
import CoreData

extension TeamMemberEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMemberEntity> {
        return NSFetchRequest<TeamMemberEntity>(entityName: "TeamMemberEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var location: String?
    @NSManaged public var timeZone: String?
    @NSManaged public var order: Int16
}

extension TeamMemberEntity : Identifiable {
}
