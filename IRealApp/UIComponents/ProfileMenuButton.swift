//
//  ProfileMenuButton.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI

// MARK: - Menu Button Style
struct ProfileMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding()
            .background(.black)
            .foregroundColor(Color("appColorMain", bundle: nil))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
