import SwiftUI

struct SwipeableTeamMemberRow: View {
    let member: TeamMemberEntity
    let onEdit: () -> Void
    let onDelete: () -> Void
    let viewModel: TeamViewModel

    @State private var offset: CGFloat = 0
    @State private var showingActions = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                HStack {
                    TeamMemberRow(member: member)
                }
                .background(Color(NSColor.windowBackgroundColor))
                .frame(width: geometry.size.width)

                HStack(spacing: 0) {
                    Button(action: {
                        onEdit()
                        withAnimation {
                            offset = 0
                            showingActions = false
                        }
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .frame(width: 60, height: geometry.size.height)
                            .background(Color.blue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        onDelete()
                        withAnimation {
                            offset = 0
                            showingActions = false
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 60, height: geometry.size.height)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 120)
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -120)
                        } else if offset < 0 {
                            offset = min(0, offset + value.translation.width)
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            if value.predictedEndTranslation.width < -geometry.size.width / 2 {
                                offset = -120
                                showingActions = true
                            } else {
                                offset = 0
                                showingActions = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if showingActions {
                    withAnimation {
                        offset = 0
                        showingActions = false
                    }
                }
            }
        }
        .frame(height: 50) // Adjust this value to match your desired row height
    }
}
