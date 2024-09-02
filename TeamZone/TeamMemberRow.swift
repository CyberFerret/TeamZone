import SwiftUI

struct NoCaretMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .menuIndicator(.hidden)
    }
}

struct TeamMemberRow: View {
    let member: TeamMemberEntity
    @State private var currentTime = Date()
    @State private var isEditing = false
    @State private var isHovering = false
    @EnvironmentObject var viewModel: TeamViewModel
    @EnvironmentObject var userSettings: UserSettings

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {
            // Avatar
            if let avatarData = member.avatarData, let nsImage = NSImage(data: avatarData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }

            // Member info
            VStack(alignment: .leading) {
                Text(member.name ?? "Unknown")
                    .font(.headline)
                Text(member.location ?? "Unknown")
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
    }

    var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: member.timeZone ?? "UTC")
        formatter.dateFormat = userSettings.use24HourTime ? "HH:mm" : "h:mm a"
        return formatter.string(from: currentTime)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: member.timeZone ?? "UTC")
        formatter.dateFormat = "EEE"
        return formatter.string(from: currentTime).uppercased()
    }
}
