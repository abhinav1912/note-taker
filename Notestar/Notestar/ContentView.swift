//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var path = NavigationPath()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Note>
    @State var searchText = ""

    var body: some View {
        NavigationStack(path: $path) {
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
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .note(let note):
                    NoteView(note: note)
                }
            }
            .navigationDestination(for: String.self) { value in
                Text(value)
            }
        }
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

private extension ContentView {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
