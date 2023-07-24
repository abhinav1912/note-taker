//

import SwiftUI

@main
struct NotestarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            FoldersListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
