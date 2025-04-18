//
//  StoryFeedViewModel.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import Foundation

private let mockURLString = "https://run.mocky.io/v3/9ad613f7-1e39-4e2e-8f87-f6051a137510"

final class StoryFeedViewModel: ObservableObject {
    
    @Published var stories: [Story] = []
    @Published var currentPage: Int = 0
    
    func reloadMockStories() {
        guard let url = URL(string: mockURLString) else {
            print("Invalid URL: \(mockURLString)")
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder()
                    .decode(APIStoryResponse.self, from: data)
                await MainActor.run {
                    self.stories = decoded.stories.compactMap({ _story in
                        return _story.toDomainStory()
                    })
                    self.currentPage = decoded.pagination.page
                }
            } catch {
                print("Failed to load stories: \(error)")
            }
        }
    }
    
    func loadMockStories() {
        guard let url = URL(string: mockURLString) else {
            print("Invalid URL: \(mockURLString)")
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder()
                    .decode(APIStoryResponse.self, from: data)
                await MainActor.run {
                    self.stories.append(contentsOf: decoded.stories.compactMap({ _story in
                        return _story.toDomainStory()
                    }))
                    self.currentPage = decoded.pagination.page
                }
            } catch {
                print("Failed to load stories: \(error)")
            }
        }
    }
}
