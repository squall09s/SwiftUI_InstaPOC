//
//  StoryFeedView.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import Foundation

struct StoryFeedView: View {
    
    @StateObject var viewModel = StoryFeedViewModel()

    private var carouselStories: [Story] {
        return viewModel.stories
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(carouselStories) { story in
                    AsyncImage(url: URL(string: story.previewURL), scale: 1.0) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onAppear {
                        print("load \(story.id)")
                        if story.id == carouselStories.last?.id {
                            print("loading more")
                            viewModel.loadMockStories()
                        }
                    }
                }
            }
        }
        .refreshable {
            viewModel.reloadMockStories()
        }
        .onAppear {
            viewModel.loadMockStories()
        }
    }
}
