//
//  LikeStore.swift
//  IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import Foundation
import Combine

final class LikeStore: ObservableObject {
    static let shared = LikeStore()

    @Published private(set) var liked: [String: Bool] = [:]
    private let likedStoriesKey = "liked_stories_ids"

    private init() {
        loadLikes()
    }

    func isLiked(_ id: String) -> Bool {
        liked[id] ?? false
    }

    func toggle(_ id: String) {
        let newValue = !(liked[id] ?? false)
        liked[id] = newValue
        saveLikes()
    }

    private func saveLikes() {
        let likedIDs = liked.filter { $0.value }.map { $0.key }
        UserDefaults.standard.set(likedIDs, forKey: likedStoriesKey)
    }

    private func loadLikes() {
        if let array = UserDefaults.standard.array(forKey: likedStoriesKey) as? [String] {
            liked = Dictionary(uniqueKeysWithValues: array.map { ($0, true) })
        }
    }
}
