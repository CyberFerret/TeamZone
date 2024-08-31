import SwiftUI
import AppKit

enum AddEditMode: Equatable {
    case add
    case edit(TeamMemberEntity)

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
    @Environment(\.managedObjectContext) private var viewContext
    let mode: AddEditMode
    let onSave: (TeamMemberEntity) -> Void

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var timeZone: String = TimeZone.current.identifier
    @State private var isEditingLocation = false
    @State private var isShowingSuggestions = false
    @State private var filteredCities: [CityData] = []
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var avatarImage: NSImage?
    @State private var isShowingImagePicker = false

    init(mode: AddEditMode, onSave: @escaping (TeamMemberEntity) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let member) = mode {
            _name = State(initialValue: member.name ?? "")
            _location = State(initialValue: member.location ?? "")
            _timeZone = State(initialValue: member.timeZone ?? TimeZone.current.identifier)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(mode == .add ? "Add Team Member" : "Edit Team Member")
                .font(.headline)
                .padding(.vertical, 16)

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
                                ForEach(filteredCities, id: \.city) { city in
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

                Section(header: Text("Avatar")) {
                    if let avatar = avatarImage {
                        Image(nsImage: avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }

                    Button(action: selectAvatar) {
                        Text(avatarImage == nil ? "Add Avatar" : "Change Avatar")
                    }

                    if avatarImage != nil {
                        Button("Remove Avatar") {
                            avatarImage = nil
                        }
                    }
                }

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
                            ForEach(filteredCities, id: \.city) { city in
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
            .padding([.horizontal, .bottom])

            HStack {
                Button(action: {
                    let member: TeamMemberEntity
                    if case .edit(let existingMember) = mode {
                        member = existingMember
                    } else {
                        member = TeamMemberEntity(context: viewContext)
                        member.id = UUID()
                    }

                    member.name = name
                    member.location = location
                    member.timeZone = timeZone

                    if let avatar = avatarImage {
                        let resizedAvatar = avatar.resized(to: NSSize(width: 100, height: 100))
                        member.avatarData = resizedAvatar.tiffRepresentation
                    } else {
                        member.avatarData = nil
                    }

                    onSave(member)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .frame(minWidth: 60)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(minWidth: 60)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 16)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .frame(width: 300, height: 280)
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

    private func selectAvatar() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                if let image = NSImage(contentsOf: url) {
                    self.avatarImage = image.resized(to: NSSize(width: 100, height: 100))
                }
            }
        }
    }
}

