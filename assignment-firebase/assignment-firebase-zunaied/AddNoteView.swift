//
//  AddNoteView.swift
//  2107041-lab-04
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var firestoreManager: FirestoreManager
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content)
                }

                Button("Save") {
                    guard !title.isEmpty else { return }
                    if let user = Auth.auth().currentUser {
                        firestoreManager.addNote(uid: user.uid, title: title, content: content)
                    } else {
                        print("No user is signed in")
                    }
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("Add Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
