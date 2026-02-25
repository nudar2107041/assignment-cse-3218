//
//  FContentView.swift
//  2107041-lab-04
//

import Foundation
import SwiftUI

struct FContentView: View {
    @ObservedObject var firestoreManager: FirestoreManager
    @State private var showingAddNote = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(firestoreManager.notes) { note in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(note.title).font(.headline)
                            Text(note.content).font(.subheadline)
                        }
                        Spacer()
                        Button("Delete") {
                            firestoreManager.deleteNote(note: note)
                        }
                        .foregroundColor(.red)
                    }
                    .swipeActions {
                        Button("Edit") {
                            showingAddNote = true
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                firestoreManager.getNotes()
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(firestoreManager: firestoreManager)
            }

            Button(action: {
                authViewModel.signOut()
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
