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
            titleField
            Divider()
            summaryField
            Divider()
            contentField
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    var titleField: some View {
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
    }

    var summaryField: some View {
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
    }

    var contentField: some View {
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

    private func saveNote() {
        do {
            if let context, context.hasChanges {
                if !note.isNull() && note.title == nil {
                    note.title = "New Note \(getCurrentDate())"
                }
                note.timestamp = Date.now
                try context.save()
            } else {
                print("No context found for saving note.")
            }
        } catch {
            print("Error while saving note: \(error)")
        }
    }

    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: Date.now)
    }
}
