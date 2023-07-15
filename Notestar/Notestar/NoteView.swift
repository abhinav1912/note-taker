//

import Foundation
import SwiftUI
import CoreData

struct NoteView: View {
    private var note: Note

    init(note: Note) {
        self.note = note
    }

    var body: some View {
        Text(note.title ?? "New Note!")
    }
}
