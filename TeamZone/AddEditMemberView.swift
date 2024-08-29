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
    @State private var filteredCities: [City] = []

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

                    // Location field with autocomplete
                    ZStack(alignment: .topLeading) {
                        TextField("Location", text: $location)
                            .onChange(of: location) { newValue in
                                filteredCities = CityTimeZoneData.cities.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                                if let city = filteredCities.first(where: { $0.name.lowercased() == newValue.lowercased() }) {
                                    timeZone = city.timeZone
                                }
                            }

                        if !filteredCities.isEmpty && !location.isEmpty {
                            List(filteredCities) { city in
                                Text(city.name)
                                    .onTapGesture {
                                        location = city.name
                                        timeZone = city.timeZone
                                        filteredCities = []
                                    }
                            }
                            .frame(maxHeight: 100)
                            .offset(y: 20)
                        }
                    }

                    // Time Zone dropdown
                    Picker("Time Zone", selection: $timeZone) {
                        ForEach(CityTimeZoneData.allTimeZones, id: \.self) { timeZone in
                            Text(timeZone)
                        }
                    }

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
        .frame(width: 300, height: 350) // Increased height to accommodate the dropdown
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if case .edit(let member) = mode {
                name = member.name
                location = member.location
                timeZone = member.timeZone
                avatarURL = member.avatarURL
            }
        }
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
