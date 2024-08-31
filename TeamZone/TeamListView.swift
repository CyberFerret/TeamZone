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
    @State private var isDragModeEnabled = false
    @State private var draggingItem: TeamMemberEntity?

    let maxHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            // Top section (if any)
            VStack {
                // Add any top content here
            }
            .frame(height: 50) // Adjust this value as needed

            // Scrollable list of team members
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.teamMembers) { teamMember in
                        HStack(spacing: 0) {
                            if isDragModeEnabled {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                    .contentShape(Rectangle())
                            }

                            SwipeableTeamMemberRow(member: teamMember, onEdit: {
                                editingMember = teamMember
                            }, onDelete: {
                                deletingMember = teamMember
                            }, viewModel: viewModel)
                            .disabled(isDragModeEnabled) // Disable swipe when drag mode is on
                        }
                        .background(Color(NSColor.windowBackgroundColor))
                        .if(isDragModeEnabled) { view in
                            view.onDrag {
                                self.draggingItem = teamMember
                                return NSItemProvider(object: teamMember.objectID.uriRepresentation() as NSURL)
                            }
                            .onDrop(of: [.url], delegate: SimpleDragDelegate(item: teamMember, items: viewModel.teamMembers, draggedItem: $draggingItem) { from, to in
                                viewModel.moveTeamMember(from: from, to: to)
                            })
                        }
                    }
                }
            }

            // Bottom toolbar
            VStack {
                HStack {
                    Button(action: {
                        isShowingAddMemberView = true
                    }) {
                        Label("Add Team Member", systemImage: "plus")
                    }

                    Spacer()

                    Button(action: {
                        isDragModeEnabled.toggle()
                    }) {
                        Image(systemName: isDragModeEnabled ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                    }
                    .help(isDragModeEnabled ? "Exit Rearrange Mode" : "Enter Rearrange Mode")

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
                .padding(.vertical, 4)
            }
            .frame(height: 50) // Adjust this value as needed
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

struct SimpleDragDelegate: DropDelegate {
    let item: TeamMemberEntity
    let items: [TeamMemberEntity]
    @Binding var draggedItem: TeamMemberEntity?
    let moveAction: (IndexSet, Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem,
              let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: item) else {
            return false
        }

        if fromIndex != toIndex {
            moveAction(IndexSet(integer: fromIndex), toIndex)
        }

        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem,
              let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: item) else {
            return
        }

        if fromIndex != toIndex {
            moveAction(IndexSet(integer: fromIndex), toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
