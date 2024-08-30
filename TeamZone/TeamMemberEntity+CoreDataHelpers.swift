import Foundation

extension TeamMemberEntity {
    var wrappedId: UUID {
        id ?? UUID()
    }

    var wrappedName: String {
        name ?? ""
    }

    var wrappedLocation: String {
        location ?? ""
    }

    var wrappedTimeZone: String {
        timeZone ?? ""
    }

    var wrappedAvatarURL: String {
        avatarURL ?? ""
    }

    func update(from teamMember: TeamMember) {
        self.id = teamMember.id
        self.name = teamMember.name
        self.location = teamMember.location
        self.timeZone = teamMember.timeZone
        self.avatarURL = teamMember.avatarURL
        self.order = teamMember.order
    }
}

extension TeamMember {
    init(entity: TeamMemberEntity) {
        self.id = entity.wrappedId
        self.name = entity.wrappedName
        self.location = entity.wrappedLocation
        self.timeZone = entity.wrappedTimeZone
        self.avatarURL = entity.wrappedAvatarURL
        self.order = entity.order
    }
}
