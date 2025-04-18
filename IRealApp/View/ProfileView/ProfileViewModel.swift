//
//  ProfileViewModel.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI

// MARK: - Model
struct User: Identifiable {
    let id = UUID()
    let username: String
    let bio: String
    let profileImageName: String  // Asset name or systemName
}

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var user: User

    init() {
        // Fake user data
        self.user = User(
            username: "Nicolas LAURENT",
            bio: "iOS Developer\nLoves Swift & Coffee ☕️",
            profileImageName: "person.crop.circle.fill"  // SF Symbol as placeholder
        )
    }
}
