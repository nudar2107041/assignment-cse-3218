//
//  assignment_firebase_zunaiedApp.swift
//  assignment-firebase-zunaied
//
//

import SwiftUI
import SwiftData
import Firebase

@main
struct assignment_firebase_zunaiedApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
