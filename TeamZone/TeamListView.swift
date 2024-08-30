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
    @State private var editingMember: TeamMember?
    @State private var deletingMember: TeamMember?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.teamMembers) { teamMember in
                    SwipeableTeamMemberRow(member: teamMember, onEdit: {
                        editingMember = teamMember
                    }, onDelete: {
                        deletingMember = teamMember
                    })
                }
                .onMove(perform: moveTeamMember)
            }
            .listStyle(PlainListStyle())

            // Bottom toolbar with custom slider toggle
            HStack {
                Button(action: {
                    isShowingAddMemberView = true
                }) {
                    Label("Add Team Member", systemImage: "plus")
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
            .padding()
        }
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
                message: Text("Are you sure you want to delete \(member.name)?"),
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

struct SwipeableTeamMemberRow: View {
    let member: TeamMember
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showingActions = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    onEdit()
                    withAnimation {
                        offset = 0
                        showingActions = false
                    }
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 50)
                        .background(Color.blue)
                }
                Button(action: {
                    onDelete()
                    withAnimation {
                        offset = 0
                        showingActions = false
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 50)
                        .background(Color.red)
                }
            }

            TeamMemberRow(member: member)
                .background(Color(NSColor.windowBackgroundColor))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -120)
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -50 {
                                    offset = -120
                                    showingActions = true
                                } else {
                                    offset = 0
                                    showingActions = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if showingActions {
                        withAnimation {
                            offset = 0
                            showingActions = false
                        }
                    }
                }
        }
    }
}
