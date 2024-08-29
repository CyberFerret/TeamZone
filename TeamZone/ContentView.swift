import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TeamViewModel

    var body: some View {
        TeamListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TeamViewModel(context: PersistenceController.shared.container.viewContext))
    }
}
