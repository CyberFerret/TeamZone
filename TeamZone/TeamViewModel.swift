import Foundation
import CoreData
import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teamMembers: [TeamMember] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTeamMembers()
    }

    func fetchTeamMembers() {
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            teamMembers = results.map { TeamMember(entity: $0) }
        } catch {
            print("Error fetching team members: \(error)")
        }
    }

    func addTeamMember(_ member: TeamMember) {
        let newMember = TeamMemberEntity(context: context)
        newMember.update(from: member)

        saveContext()
        fetchTeamMembers()
    }

    func updateTeamMember(_ member: TeamMember) {
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", member.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let existingMember = results.first {
                existingMember.update(from: member)

                saveContext()
                fetchTeamMembers()
            }
        } catch {
            print("Error updating team member: \(error)")
        }
    }

    func deleteTeamMember(_ member: TeamMember) {
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", member.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let memberToDelete = results.first {
                context.delete(memberToDelete)
                saveContext()
                fetchTeamMembers()
            }
        } catch {
            print("Error deleting team member: \(error)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
