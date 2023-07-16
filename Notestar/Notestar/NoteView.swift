//

import Foundation
import SwiftUI
import CoreData

struct NoteView: View {
    private var note: Note
    @State private var summary: String
    @State private var content: String
    @State private var title: String
    private var context: NSManagedObjectContext?

    init(note: Note) {
        self.note = note
        self.summary = note.summary ?? ""
        self.content = note.body ?? ""
        self.title = note.title ?? ""
        self.context = note.managedObjectContext
    }

    var body: some View {
        VStack {
            TextField(
                "New Note",
                text: self.$title,
                onEditingChanged: { isEditing in
                    if !isEditing && (note.title ?? "" != self.title) {
                        note.title = self.title
                        saveNote()
                    }
                })
                .font(.title)
                .fontWeight(.bold)
            Divider()
            TextField(
                "Add a summary",
                text: self.$summary,
                onEditingChanged: { isEditing in
                    if !isEditing && (note.summary ?? "" != self.summary) {
                        note.summary = self.summary
                        saveNote()
                    }
                }
            )
                .padding(.top, 8)
            Divider()
            TextField(
                "Add the note!",
                text: self.$content,
                onEditingChanged: { isEditing in
                    if !isEditing && (note.body ?? "" != self.content) {
                        note.body = self.content
                        saveNote()
                    }
                }
            )
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func saveNote() {
        do {
            if let context {
                if context.hasChanges {
                    try context.save()
                }
            } else {
                print("No context found for saving note.")
            }
        } catch {
            print("Error while saving note: \(error)")
        }
    }
}
