import Foundation
import CoreData

struct TeamMember: Identifiable {
    let id: UUID
    var name: String
    var location: String
    var timeZone: String
    var avatarURL: String

    init(id: UUID = UUID(), name: String, location: String, timeZone: String, avatarURL: String) {
        self.id = id
        self.name = name
        self.location = location
        self.timeZone = timeZone
        self.avatarURL = avatarURL
    }

    init(entity: TeamMemberEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.location = entity.location ?? ""
        self.timeZone = entity.timeZone ?? ""
        self.avatarURL = entity.avatarURL ?? ""
    }
}

extension TeamMemberEntity {
    func update(from teamMember: TeamMember) {
        self.id = teamMember.id
        self.name = teamMember.name
        self.location = teamMember.location
        self.timeZone = teamMember.timeZone
        self.avatarURL = teamMember.avatarURL
    }
}
