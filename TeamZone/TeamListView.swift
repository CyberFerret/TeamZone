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
    @State private var isShowingAddEditMemberView = false
    @State private var addEditMode: AddEditMode = .add
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.teamMembers) { teamMember in
                    TeamMemberRow(member: teamMember)
                        .onTapGesture {
                            addEditMode = .edit(teamMember)
                            isShowingAddEditMemberView = true
                        }
                }
                .onMove(perform: moveTeamMember)
                .onDelete(perform: deleteTeamMember)
            }
            .listStyle(PlainListStyle())

            // Bottom toolbar with custom slider toggle
            HStack {
                Button(action: {
                    addEditMode = .add
                    isShowingAddEditMemberView = true
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
        .sheet(isPresented: $isShowingAddEditMemberView) {
            AddEditMemberView(mode: addEditMode, onSave: { updatedMember in
                if case .add = addEditMode {
                    viewModel.addTeamMember(updatedMember)
                } else if case .edit = addEditMode {
                    viewModel.updateTeamMember(updatedMember)
                }
                isShowingAddEditMemberView = false
            })
            .environment(\.colorScheme, colorScheme)
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        AddEditMemberView(mode: mode, onSave: onSave)
            .preferredColorScheme(colorScheme)
    }
}
