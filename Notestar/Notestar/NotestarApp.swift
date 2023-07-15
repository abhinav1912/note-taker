//

import SwiftUI

@main
struct NotestarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .note(let note):
                            NoteView(note: note)
                        }
                    }
            }
        }
    }
}
