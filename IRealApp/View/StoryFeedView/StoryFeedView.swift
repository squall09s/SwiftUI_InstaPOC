//
//  StoryFeedView.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import Foundation

struct StoryFeedView: View {
    
    @ObservedObject var likeStore = LikeStore.shared
    
    
    @StateObject var viewModel = StoryFeedViewModel()
    @State private var selectedStory: Story?

    private var carouselStories: [Story] {
        return viewModel.stories
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(carouselStories) { story in
                    
                    ZStack(alignment: .topTrailing) {
                        
                        
                        Button {
                            selectedStory = story
                        } label: {
                            
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
                            
                            
                            
                        }
                        
                        
                        LikeButtonView(
                            isLiked: Binding(
                                get: { likeStore.isLiked(story.id) },
                                set: { _ in } // Lecture seule ici
                            )
                        )
                        .padding(.trailing, 38)
                        .padding(.top, 12)
                        .frame(width: 50, height: 50)
                        .allowsHitTesting(false)
                        
                       
                        
                    }.onAppear {
                        print("load \(story.id)")
                        if story.id == carouselStories.last?.id {
                            print("loading more")
                            viewModel.loadMoreStories()
                        }
                    }
                }
            }
        }
        .refreshable {
            viewModel.loadFirstStories()
        }
        .onAppear {
            if viewModel.stories.isEmpty {
                viewModel.loadFirstStories()
            }
            
        }
        .sheet(item: $selectedStory) { story in
            StoryReaderView(story: story)
        }
    }
}
