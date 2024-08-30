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

struct LocationInputView: View {
    @Binding var location: String
    @Binding var timeZone: String
    @State private var filteredCities: [CityData] = []
    @State private var isShowingSuggestions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Location", text: $location, onEditingChanged: { isEditing in
                isShowingSuggestions = isEditing && location.count >= 3
                if isEditing && location.count >= 3 {
                    updateFilteredCities()
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: location) { newValue in
                if newValue.count >= 3 {
                    updateFilteredCities()
                } else {
                    filteredCities = []
                    isShowingSuggestions = false
                }
            }

            if isShowingSuggestions && !filteredCities.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredCities, id: \.city) { city in
                            Text("\(city.city), \(city.country)")
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    location = city.city // Store only the city name
                                    timeZone = city.timezone
                                    isShowingSuggestions = false
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(Color(.textBackgroundColor))
                .cornerRadius(4)
                .shadow(radius: 2)
                .padding(.top, 2)
            }
        }
    }

    private func updateFilteredCities() {
        filteredCities = DatabaseManager.shared.searchCities(query: location)
        isShowingSuggestions = !filteredCities.isEmpty
    }
}

struct AddEditMemberView: View {
    let mode: AddEditMode
    let onSave: (TeamMember) -> Void
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var timeZone: String = TimeZone.current.identifier
    @State private var id: UUID = UUID()

    @State private var filteredCities: [CityData] = [] // Updated to use CityData struct
    @State private var isShowingSuggestions = false
    @State private var isEditingLocation = false

    init(mode: AddEditMode, onSave: @escaping (TeamMember) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let member) = mode {
            _name = State(initialValue: member.name)
            _location = State(initialValue: member.location)
            _timeZone = State(initialValue: member.timeZone)
            _id = State(initialValue: member.id)
        }
    }

    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)

                VStack(alignment: .leading) {
                    TextField("Location", text: $location, onEditingChanged: { isEditing in
                        isEditingLocation = isEditing
                        if isEditing {
                            updateFilteredCities()
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isShowingSuggestions = false
                            }
                        }
                    })
                    .onChange(of: location) { _ in
                        if isEditingLocation {
                            updateFilteredCities()
                        }
                    }

                    if isShowingSuggestions && !filteredCities.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(filteredCities, id: \.self) { city in
                                    Text("\(city.city), \(city.country)")
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            location = city.city
                                            timeZone = city.timezone
                                            isShowingSuggestions = false
                                        }
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }

                Picker("Time Zone", selection: $timeZone) {
                    ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { zone in
                        Text(zone).tag(zone)
                    }
                }
            }
            .padding()

            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Save") {
                    let member = TeamMember(id: id, name: name, location: location, timeZone: timeZone, avatarURL: "", order: 0)
                    onSave(member)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .frame(width: 300, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .environment(\.colorScheme, colorScheme)
    }

    private func updateFilteredCities() {
        if location.count >= 3 {
            filteredCities = DatabaseManager.shared.searchCities(query: location)
            isShowingSuggestions = !filteredCities.isEmpty
        } else {
            filteredCities = []
            isShowingSuggestions = false
        }
    }
}
