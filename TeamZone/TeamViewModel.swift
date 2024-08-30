import Foundation
import CoreData
import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teamMembers: [TeamMember] = []
    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTeamMembers()
    }

    func fetchTeamMembers() {
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TeamMemberEntity.order, ascending: true)]

        do {
            let entities = try viewContext.fetch(request)
            teamMembers = entities.map { TeamMember.fromEntity($0) }
        } catch {
            print("Error fetching team members: \(error)")
        }
    }

    func addTeamMember(_ member: TeamMember) {
        let newMember = TeamMemberEntity(context: viewContext)
        newMember.updateFromModel(member)
        newMember.order = Int16(teamMembers.count)

        saveContext()
        fetchTeamMembers()
    }

    func updateTeamMember(_ member: TeamMember) {
        if let entity = try? viewContext.fetch(TeamMemberEntity.fetchRequest()).first(where: { $0.id == member.id }) {
            entity.updateFromModel(member)
            saveContext()
            fetchTeamMembers()
        }
    }

    func deleteTeamMember(_ member: TeamMember) {
        if let entity = try? viewContext.fetch(TeamMemberEntity.fetchRequest()).first(where: { $0.id == member.id }) {
            viewContext.delete(entity)
            saveContext()
            fetchTeamMembers()
        }
    }

    func moveTeamMember(from source: IndexSet, to destination: Int) {
        var revisedItems: [TeamMember] = teamMembers

        revisedItems.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }

        teamMembers = revisedItems

        // Update Core Data entities
        let request: NSFetchRequest<TeamMemberEntity> = TeamMemberEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TeamMemberEntity.order, ascending: true)]

        do {
            let entities = try viewContext.fetch(request)
            for (index, entity) in entities.enumerated() {
                entity.order = Int16(index)
            }
            saveContext()
        } catch {
            print("Error updating team member order: \(error)")
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
