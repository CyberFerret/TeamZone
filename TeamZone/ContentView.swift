import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel: TeamViewModel
    @StateObject var userSettings = UserSettings()
    let maxHeight: CGFloat

    init(context: NSManagedObjectContext, maxHeight: CGFloat) {
        let vm = TeamViewModel(context: context)
        _viewModel = StateObject(wrappedValue: vm)
        self.maxHeight = maxHeight
    }

    var body: some View {
        TeamListView(maxHeight: maxHeight)
            .environmentObject(viewModel)
            .environmentObject(userSettings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            context: PersistenceController.preview.container.viewContext,
            maxHeight: 600
        )
        .environmentObject(TeamViewModel(context: PersistenceController.preview.container.viewContext))
    }
}
