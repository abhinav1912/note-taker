//

import SwiftUI
import CoreData

struct FoldersListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var path = NavigationPath()
    @State private var folderName = ""
    @State private var isAddingNewFolder = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Folder>
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
                    Button(action: showFolderAdditionAlert) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .alert("Create new folder", isPresented: $isAddingNewFolder) {
                TextField("Enter title", text: $folderName)
                Button("Create", action: {
                    self.saveFolder(withTitle: self.folderName)
                })
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .note(let note):
                    NoteView(note: note)
                case .folder(let folder):
                    NotesListView(folder: folder, path: $path)
                }
            }
        }
    }

    var addButtonOnEmptyView: some View {
        Button(action: showFolderAdditionAlert, label: {
            Label("Create a new folder", systemImage: "plus")
        })
    }

    var noteList: some View {
        List {
            ForEach(items) { item in
                NavigationLink(item.title ?? "New Note", value: NavigationDestination.folder(item))
            }
            .onDelete(perform: deleteItems)
        }
    }
}

private extension FoldersListView {
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

    func showFolderAdditionAlert() {
        self.isAddingNewFolder.toggle()
    }

    func saveFolder(withTitle title: String) {
        withAnimation {
            let folder = Folder(context: viewContext)
            folder.title = title
            folder.timestamp = Date.now
            folder.id = UUID()
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Failed to create folder: \(nsError), \(nsError.userInfo)")
            }
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
}

struct FoldersListView_Previews: PreviewProvider {
    static var previews: some View {
        FoldersListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
