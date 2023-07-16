//

import Foundation
import SwiftUI
import CoreData

struct NoteView: View {
    private var note: Note
    @State private var summary: String
    @State private var content: String
    @State private var title: String

    init(note: Note) {
        self.note = note
        self.summary = note.summary ?? ""
        self.content = note.body ?? ""
        self.title = note.title ?? ""
    }

    var body: some View {
        VStack {
            TextField("New Note", text: self.$title)
                .font(.title)
                .fontWeight(.bold)
            Divider()
            TextField("Add a summary", text: self.$summary)
                .padding(.top, 8)
            Divider()
            TextField("Add the note!", text: self.$content)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
