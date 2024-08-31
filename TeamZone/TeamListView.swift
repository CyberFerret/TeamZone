import SwiftUI
import CoreData

struct CustomSliderToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .frame(width: 30, height: 16)
                .foregroundColor(.clear)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                )

            Circle()
                .frame(width: 14, height: 14)
                .foregroundColor(Color.gray.opacity(0.7))
                .padding(1)
        }
        .frame(width: 30, height: 16)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isOn.toggle()
            }
        }
    }
}

struct TeamListView: View {
    @EnvironmentObject var viewModel: TeamViewModel
    @EnvironmentObject var userSettings: UserSettings
    @State private var isShowingAddMemberView = false
    @State private var editingMember: TeamMemberEntity?
    @State private var deletingMember: TeamMemberEntity?
    @Environment(\.colorScheme) var colorScheme
    @State private var draggedItem: TeamMemberEntity?

    let maxHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.teamMembers) { teamMember in
                        SwipeableTeamMemberRow(member: teamMember, onEdit: {
                            editingMember = teamMember
                        }, onDelete: {
                            deletingMember = teamMember
                        }, viewModel: viewModel)  // We've added viewModel here
                        .onDrag {
                            self.draggedItem = teamMember
                            return NSItemProvider(object: teamMember.objectID.uriRepresentation() as NSURL)
                        }
                        .onDrop(of: [.url], delegate: DropViewDelegate(item: teamMember, items: $viewModel.teamMembers, draggedItem: $draggedItem, viewModel: viewModel))
                    }
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, 4)

            // Bottom toolbar
            HStack {
                Button(action: {
                    isShowingAddMemberView = true
                }) {
                    Label("Add", systemImage: "plus")
                }

                Spacer()

                HStack {
                    Text("12hr")
                        .foregroundColor(userSettings.use24HourTime ? Color.gray.opacity(0.5) : Color.gray.opacity(0.8))
                    CustomSliderToggle(isOn: $userSettings.use24HourTime)
                    Text("24hr")
                        .foregroundColor(userSettings.use24HourTime ? Color.gray.opacity(0.8) : Color.gray.opacity(0.5))
                }
                .font(.footnote)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(maxHeight: maxHeight)
        .sheet(isPresented: $isShowingAddMemberView) {
            AddEditMemberView(mode: .add, onSave: { newMember in
                viewModel.addTeamMember(newMember)
                isShowingAddMemberView = false
            })
            .environment(\.colorScheme, colorScheme)
        }
        .sheet(item: $editingMember) { member in
            AddEditMemberView(mode: .edit(member), onSave: { updatedMember in
                viewModel.updateTeamMember(updatedMember)
                editingMember = nil
            })
            .environment(\.colorScheme, colorScheme)
            .id(member.id) // Force view recreation when editing different members
        }
        .alert(item: $deletingMember) { member in
            Alert(
                title: Text("Delete Team Member"),
                message: Text("Are you sure you want to delete \(member.name ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteTeamMember(member)
                    deletingMember = nil
                },
                secondaryButton: .cancel {
                    deletingMember = nil
                }
            )
        }
    }

    private func moveTeamMember(from source: IndexSet, to destination: Int) {
        viewModel.moveTeamMember(from: source, to: destination)
    }
}


struct DropViewDelegate: DropDelegate {
    let item: TeamMemberEntity
    @Binding var items: [TeamMemberEntity]
    @Binding var draggedItem: TeamMemberEntity?
    let viewModel: TeamViewModel

    func performDrop(info: DropInfo) -> Bool {
        viewModel.updateOrder()
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            if items[to] != draggedItem {
                withAnimation {
                    items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                }
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
