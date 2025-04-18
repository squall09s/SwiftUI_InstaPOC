//
//  ProfileView.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI


// MARK: - View
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Username
                Text(viewModel.user.username)
                    .font(.title)
                    .fontWeight(.bold)

                // Profile image
                Image("user_ic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)

                
                // Bio
                Text(viewModel.user.bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Menu buttons
                VStack(spacing: 16) {
                    ProfileMenuButton(icon: "person.2.fill", title: "Friends") {
                        // action
                    }
                    ProfileMenuButton(icon: "gearshape.fill", title: "Settings") {
                        // action
                    }
                    ProfileMenuButton(icon: "arrowshape.turn.up.left.fill", title: "Logout") {
                        // action
                    }
                }
                .padding(.top, 16)

                Spacer()
            }
            .padding()
            
        }
    }
}


// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
