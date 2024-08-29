import SwiftUI

struct TeamMemberRow: View {
    let member: TeamMember
    @State private var currentTime = Date()
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @State private var isHovering = false
    @EnvironmentObject var viewModel: TeamViewModel
    @EnvironmentObject var userSettings: UserSettings

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            // Avatar and member info
            HStack {
                AsyncImage(url: URL(string: member.avatarURL)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle")
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(member.name)
                        .font(.headline)
                    Text(member.location)
                        .font(.subheadline)
                }
            }

            Spacer()

            // Time
            Text(currentTimeString)
                .font(.system(size: 24, weight: .bold))
                .monospacedDigit()
                .frame(width: 100, alignment: .trailing) // Increased width
                .foregroundColor(.primary)

            // Space for Edit and Delete buttons
            HStack(spacing: 8) {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(BorderlessButtonStyle())
                .opacity(isHovering ? 1 : 0)

                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.red)
                .opacity(isHovering ? 1 : 0)
            }
            .frame(width: 60)
        }
        .padding(.vertical, 4)
        .background(Color.clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $isEditing) {
            AddEditMemberView(mode: .edit(member)) { updatedMember in
                viewModel.updateTeamMember(updatedMember)
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Team Member"),
                message: Text("Are you sure you want to delete \(member.name)?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteTeamMember(member)
                },
                secondaryButton: .cancel()
            )
        }
    }

    var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: member.timeZone)
        formatter.dateFormat = userSettings.use24HourTime ? "HH:mm" : "h:mm a"
        return formatter.string(from: currentTime)
    }
}
