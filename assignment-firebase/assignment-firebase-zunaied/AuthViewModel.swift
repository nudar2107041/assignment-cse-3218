//
//  AuthViewModel.swift
//  2107041-lab-04
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false

    var firestoreManager: FirestoreManager? {
        didSet {
            if isSignedIn {
                firestoreManager?.getNotes()
            }
        }
    }

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign Up Error: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.firestoreManager?.getNotes()
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign In Error: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.firestoreManager?.getNotes()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // Clear the listener and notes so the next user starts fresh
            firestoreManager?.stopListening()
            DispatchQueue.main.async {
                self.user = nil
                self.isSignedIn = false
            }
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
}
