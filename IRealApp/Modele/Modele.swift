//
//  Item.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

// MARK: - Models

import SwiftUI
import PhotosUI
import AVFoundation
import AVKit


// MARK: - API Models

struct Pagination : Codable {
    
    let page : Int
    let per_page : Int
    let total_items : Int
    let total_pages : Int
    let next_page : Int
    let prev_page : Int?
       
}


/// Represents the user in API responses
struct APIUser: Codable {
    let id: String
    let username: String
}

/// Represents a story from the API
struct APIStory: Codable, Identifiable {
    
    let id: String
    let user: APIUser
    let createdAt: String?
    let imageUrl: String
    let videoUrl: String
    let likes: Int
    let views: Int
    let emojiReactions: [String]
    let tags: [String]
    let filter: String

    /// Map API model to UI domain model
    func toDomainStory() -> Story {
        // For now create a basic Story with image or video layer
        let story = Story(
            id: UUID().uuidString, // évitons de récupérer l'ID du mock url pour pouvoir fake le scrool infini
            user: user.username,
            layers: [],
            audioURL: URL(string: videoUrl),
            previewURL: imageUrl,
            creationDate: createdAt
        )
        return story
    }
}

struct APIStoryResponse: Codable {
  let pagination: Pagination
  let stories: [APIStory]
}



// MARK: - Models

struct Story: Identifiable {
    let id: String
    var user: String
    var layers: [StoryLayer]
    var audioURL: URL?
    var previewURL: String
    var creationDate: String?
}

enum StoryLayer: Identifiable {
    case image(ImageLayer)
    case gif(GifLayer)
    case text(TextLayer)

    var id: UUID {
        switch self {
        case .image(let l): return l.id
        case .gif(let l): return l.id
        case .text(let l): return l.id
        }
    }
}

struct ImageLayer: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
    var scale: CGFloat
}

struct GifLayer: Identifiable {
    let id = UUID()
    var url: URL
    var position: CGPoint
    var scale: CGFloat
}

struct TextLayer: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
}


struct VideoLayer: Identifiable {
    let id = UUID()
    var url: URL
    var position: CGPoint
    var scale: CGFloat
}

// Wrapper for navigation
struct BackgroundMediaItem: Identifiable, Hashable {
    
    let id = UUID()
    let videoURL: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: BackgroundMediaItem, rhs: BackgroundMediaItem) -> Bool {
        lhs.id == rhs.id
    }
}
