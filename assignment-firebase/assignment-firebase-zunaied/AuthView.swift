//
//  AuthView.swift
//  2107041-lab-04
//

import Foundation
import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var firestoreManager = FirestoreManager()

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        if viewModel.isSignedIn {
            // Pass the shared firestoreManager into the content view
            FContentView(firestoreManager: firestoreManager)
                .environmentObject(viewModel)
                .onAppear {
                    // Wire up so sign-out can clear the listener
                    viewModel.firestoreManager = firestoreManager
                }
        } else {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack {
                    Button("Sign In") {
                        viewModel.signIn(email: email, password: password)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Sign Up") {
                        viewModel.signUp(email: email, password: password)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}
