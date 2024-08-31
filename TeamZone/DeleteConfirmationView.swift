import SwiftUI

struct DeleteConfirmationView: View {
    let memberName: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.yellow)

            Text("Delete Team Member")
                .font(.headline)

            Text("Are you sure you want to delete \(memberName)?")
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)

                Button("Delete") {
                    onDelete()
                }
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
