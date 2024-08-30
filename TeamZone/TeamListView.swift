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
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.teamMembers) { teamMember in
                        SwipeableTeamMemberRow(member: teamMember, onEdit: {
                            editingMember = teamMember
                        }, onDelete: {
                            deletingMember = teamMember
                        })
                    }
                    .onMove(perform: moveTeamMember)
                }
            }
            .padding(.top, 4) // Add a small padding to the top of the popup
            .padding(.horizontal, 4) // Add this line to add small left and right padding

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
            .padding(.horizontal)
            .padding(.vertical, 8) // Reduced vertical padding in the footer
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
        GeometryReader { geometry in
            HStack(spacing: 0) {
                TeamMemberRow(member: member)
                    .background(Color(NSColor.windowBackgroundColor))
                    .frame(width: geometry.size.width)

                HStack(spacing: 0) {
                    Button(action: {
                        onEdit()
                        withAnimation {
                            offset = 0
                            showingActions = false
                        }
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .frame(width: 60, height: geometry.size.height)
                            .background(Color.blue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        onDelete()
                        withAnimation {
                            offset = 0
                            showingActions = false
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 60, height: geometry.size.height)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 120)
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -120)
                        } else if offset < 0 {
                            offset = min(0, offset + value.translation.width)
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            if value.predictedEndTranslation.width < -geometry.size.width / 2 {
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
        .frame(height: 50) // Adjust this value to match your desired row height
    }
}
