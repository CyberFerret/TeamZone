import SwiftUI

struct NoCaretMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .menuIndicator(.hidden)
    }
}

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
        HStack(spacing: 8) {
            // Avatar
            AsyncImage(url: URL(string: member.avatarURL)) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.circle")
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            // Member info
            VStack(alignment: .leading) {
                Text(member.name)
                    .font(.headline)
                Text(member.location)
                    .font(.subheadline)
            }

            Spacer()

            // Day and Time
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(dayOfWeek)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.secondary)

                Text(currentTimeString)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .monospacedDigit()
            }
            .frame(width: 120, alignment: .trailing)
            .lineLimit(1)
            .minimumScaleFactor(0.5)

            // Ellipsis menu
            Menu {
                Button("Edit") {
                    isEditing = true
                }
                Button("Delete") {
                    showingDeleteConfirmation = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .menuStyle(NoCaretMenuStyle())
            .frame(width: 20)
            .opacity(isHovering ? 1 : 0)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
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

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: member.timeZone)
        formatter.dateFormat = "EEE"
        return formatter.string(from: currentTime).uppercased()
    }
}
