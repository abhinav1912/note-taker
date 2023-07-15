//

import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Notestar")
        container.loadPersistentStores { description, error in
            if let error {
                print("Error while loading container: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error while saving context: \(error)")
            }
        }
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = Note(context: viewContext)
            newItem.id = UUID()
            newItem.title = "Note \(i)"
            newItem.timestamp = Date.now
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
