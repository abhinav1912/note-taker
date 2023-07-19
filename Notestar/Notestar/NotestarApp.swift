//

import SwiftUI

@main
struct NotestarApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject private var navigationCoordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationCoordinator.navigationPath) {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .note(let note):
                            NoteView(note: note)
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
        }
    }
}

final class NavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
}
