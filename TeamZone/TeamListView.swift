import SwiftUI

struct TeamListView: View {
    @EnvironmentObject var viewModel: TeamViewModel
    @EnvironmentObject var userSettings: UserSettings
    @State private var isAddingMember = false

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.teamMembers) { member in
                    TeamMemberRow(member: member)
                }
            }
            .frame(height: 300)
            .listStyle(PlainListStyle())

            Divider()

            HStack {
                Button(action: {
                    isAddingMember = true
                }) {
                    Text("Add Team Member")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)

                Spacer()

                HStack {
                    Text("12hr")
                        .foregroundColor(userSettings.use24HourTime ? .secondary : .primary)
                    Toggle("", isOn: $userSettings.use24HourTime)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                    Text("24hr")
                        .foregroundColor(userSettings.use24HourTime ? .primary : .secondary)
                }
                .padding(.horizontal)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(width: 400) // Increased width
        .padding(.vertical)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $isAddingMember) {
            AddEditMemberView(mode: .add) { newMember in
                viewModel.addTeamMember(newMember)
            }
        }
    }
}
