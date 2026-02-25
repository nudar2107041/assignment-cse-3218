//
//  FirestoreManager.swift
//  2107041-lab-04
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var title: String
    var content: String
}

@MainActor
class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()
    @Published var notes = [Note]()
    private var listener: ListenerRegistration?

    // Create Note
    func addNote(uid: String, title: String, content: String) {
        let newNote = Note(uid: uid, title: title, content: content)
        do {
            _ = try db.collection("notes").addDocument(from: newNote)
        } catch {
            print("Error adding document: \(error)")
        }
    }

    // Read Notes — only for the currently signed-in user
    func getNotes() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user signed in, cannot fetch notes.")
            return
        }

        // Remove any previous listener before attaching a new one
        listener?.remove()

        listener = db.collection("notes")
            .whereField("uid", isEqualTo: uid)
            .order(by: "title")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting notes: \(error)")
                    return
                }

                guard let self = self else { return }
                let updatedNotes: [Note] = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Note.self)
                } ?? []

                // Ensure UI updates happen on the main actor
                self.notes = updatedNotes
            }
    }

    // Stop listening (call on sign-out)
    func stopListening() {
        listener?.remove()
        listener = nil
        self.notes = []
    }

    // Update Note
    func updateNote(note: Note) {
        guard let noteID = note.id else { return }
        do {
            try db.collection("notes").document(noteID).setData(from: note)
        } catch {
            print("Error updating note: \(error)")
        }
    }

    // Delete Note
    func deleteNote(note: Note) {
        guard let noteID = note.id else { return }
        db.collection("notes").document(noteID).delete { error in
            if let error = error {
                print("Error deleting note: \(error)")
            }
        }
    }
}

