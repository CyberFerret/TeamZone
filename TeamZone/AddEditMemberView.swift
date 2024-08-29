import SwiftUI

enum AddEditMode: Equatable {
    case add
    case edit(TeamMember)

    static func == (lhs: AddEditMode, rhs: AddEditMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add):
            return true
        case let (.edit(lhsMember), .edit(rhsMember)):
            return lhsMember.id == rhsMember.id
        default:
            return false
        }
    }
}

struct AddEditMemberView: View {
    let mode: AddEditMode
    let onSave: (TeamMember) -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var timeZone: String = ""
    @State private var avatarURL: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            Text(titleText)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.2))

            // Form and buttons
            VStack {
                Form {
                    TextField("Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Time Zone", text: $timeZone)
                    TextField("Avatar URL", text: $avatarURL)
                }
                .padding()

                HStack {
                    Button("Save") {
                        let member = TeamMember(
                            id: (mode == .add) ? UUID() : getMemberId(),
                            name: name,
                            location: location,
                            timeZone: timeZone,
                            avatarURL: avatarURL
                        )
                        onSave(member)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || location.isEmpty || timeZone.isEmpty)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)

                    Spacer()

                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.primary)
                }
                .padding()
            }
        }
        .frame(width: 300, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var titleText: String {
        switch mode {
        case .add:
            return "Add Team Member"
        case .edit:
            return "Edit Team Member"
        }
    }

    private func getMemberId() -> UUID {
        if case .edit(let member) = mode {
            return member.id
        }
        return UUID()
    }
}
