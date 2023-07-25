//

import SwiftUI
import CoreData

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding private var path: NavigationPath
    private let folder: Folder

    init(folder: Folder, path: Binding<NavigationPath>) {
        self.folder = folder
        self._path = path
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Note>
    @State var searchText = ""

    var body: some View {
        if items.count == .zero {
            addButtonOnEmptyView
        }
        noteList
        .searchable(text: searchQuery)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .onAppear {
            clearNullNotes()
            items.nsPredicate = NSPredicate(format: "parentFolder = %@", folder)
        }
        .navigationTitle(folder.title ?? "New Folder")
    }

    var addButtonOnEmptyView: some View {
        Button(action: addItem, label: {
            Label("Add Item", systemImage: "plus")
        })
    }

    var noteList: some View {
        List {
            ForEach(items) { item in
                NavigationLink(item.title ?? "New Note", value: NavigationDestination.note(item))
            }
            .onDelete(perform: deleteItems)
        }
    }
}

private extension NotesListView {
    var searchQuery: Binding<String> {
        Binding {
            searchText
        } set: { newVal in
            searchText = newVal
            if newVal.isEmpty {
                items.nsPredicate = NSPredicate(value: true)
            } else {
                items.nsPredicate = NSPredicate(format: "title CONTAINS[cd] %@", newVal)
            }
        }
    }

    func addItem() {
        withAnimation {
            let newItem = Note(context: viewContext)
            newItem.timestamp = Date()
            newItem.id = UUID()
            path.append(NavigationDestination.note(newItem))
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func clearNullNotes() {
        withAnimation {
            items.filter({ $0.isNull() }).forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Failed to delete nil items: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct NotesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotesListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
