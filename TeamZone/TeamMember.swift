import Foundation

struct TeamMember: Identifiable {
    let id: UUID
    var name: String
    var location: String
    var timeZone: String
    var order: Int16

    init(id: UUID = UUID(), name: String, location: String, timeZone: String, order: Int16 = 0) {
        self.id = id
        self.name = name
        self.location = location
        self.timeZone = timeZone
        self.order = order
    }
}

// Extension to convert TeamMemberEntity to TeamMember
extension TeamMember {
    static func fromEntity(_ entity: TeamMemberEntity) -> TeamMember {
        TeamMember(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            location: entity.location ?? "",
            timeZone: entity.timeZone ?? "",
            order: entity.order
        )
    }
}

// Extension to update TeamMemberEntity from TeamMember
extension TeamMemberEntity {
    func updateFromModel(_ model: TeamMember) {
        self.id = model.id
        self.name = model.name
        self.location = model.location
        self.timeZone = model.timeZone
        self.order = model.order
    }
}
