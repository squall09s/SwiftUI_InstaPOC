//
// IRealAppApp.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import SwiftData

@main
struct IRealAppApp: App {
    

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Modèle simple pour un onglet
struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let image: Image
}

struct AnimatedTabBar: View {
    @Binding var selection: Int
    let tabs: [TabItem]

    /// Hauteur fixe de la barre
    let barHeight: CGFloat = 90
    /// Espacement entre les items
    let itemSpacing: CGFloat = 24
    /// Marge à gauche de l’ensemble
    let leadingPadding: CGFloat = 50

    var body: some View {
        HStack(alignment: .center, spacing: itemSpacing) {
            ForEach(Array(tabs.enumerated()), id: \.1.id) { idx, tab in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = idx
                    }
                }) {
                    HStack(spacing: 8) {
                        tab.image.resizable().frame(width: 24, height: 24)
                        if selection == idx {
                            Text(tab.title)
                                .font(.system(size: 18, weight: .bold))
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, selection == idx ? 12 : 0)
                    .padding(.vertical, 8)
                    .foregroundColor(selection == idx ? Color("appColorMain") : .black.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                // on ne force plus maxWidth
            }
        }
        .padding(.leading, leadingPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: barHeight)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        )
    }
}


// Exemple de ContentView qui utilise la barre
struct ContentView: View {
    
    @State private var selectedMedia: BackgroundMediaItem? = nil

    @State private var selectedTab = 0

    private let tabs = [
        
        TabItem( title: "iReal", image: Image("ic_tab_1")),
        TabItem(title: "Feed", image: Image("ic_tab_2")),
        TabItem(title: "Profil", image: Image("ic_tab_3")),
    ]

    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 0) {
                // Contenu principal
                ZStack {
                    switch selectedTab {
                    case 0: CameraView { media in selectedMedia = media }
                    case 1: StoryFeedView()
                    default: ProfileView(viewModel: ProfileViewModel())
                    }
                }

                // La barre custom
                AnimatedTabBar(selection: $selectedTab, tabs: tabs)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(item: $selectedMedia) { media in
            StoryEditorView(videoURL: media.videoURL)
        }
    }
}

#Preview {
    ContentView()
}
