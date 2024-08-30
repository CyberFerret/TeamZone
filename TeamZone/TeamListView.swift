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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.teamMembers) { teamMember in
                    TeamMemberRow(member: teamMember)
                        .onTapGesture {
                            editingMember = teamMember
                        }
                }
                .onMove(perform: moveTeamMember)
                .onDelete(perform: deleteTeamMember)
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
    }

    private func moveTeamMember(from source: IndexSet, to destination: Int) {
        viewModel.moveTeamMember(from: source, to: destination)
    }

    private func deleteTeamMember(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTeamMember(viewModel.teamMembers[index])
        }
    }
}

struct AddEditMemberViewWrapper: View {
    let mode: AddEditMode
    let onSave: (TeamMember) -> Void
    let colorScheme: ColorScheme

    var body: some View {
        AddEditMemberView(mode: mode, onSave: onSave)
            .environment(\.colorScheme, colorScheme)
            .preferredColorScheme(colorScheme)
    }
}
