import Foundation
import CoreData
import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teamMembers: [TeamMemberEntity] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTeamMembers()
    }

    func fetchTeamMembers() {
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TeamMemberEntity.order, ascending: true)]

        do {
            teamMembers = try context.fetch(request)
        } catch {
            print("Error fetching team members: \(error)")
        }
    }

    func addTeamMember(_ member: TeamMemberEntity) {
        member.order = Int16(teamMembers.count)
        teamMembers.append(member)
        saveContext()
    }

    func updateTeamMember(_ member: TeamMemberEntity) {
        if let index = teamMembers.firstIndex(where: { $0.id == member.id }) {
            teamMembers[index] = member
            saveContext()
        }
    }

    func deleteTeamMember(_ member: TeamMemberEntity) {
        if let index = teamMembers.firstIndex(where: { $0.id == member.id }) {
            teamMembers.remove(at: index)
            context.delete(member)
            saveContext()
        }
    }

    func moveTeamMember(from source: IndexSet, to destination: Int) {
        teamMembers.move(fromOffsets: source, toOffset: destination)

        // Update the order of team members
        for (index, member) in teamMembers.enumerated() {
            member.order = Int16(index)
        }

        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
