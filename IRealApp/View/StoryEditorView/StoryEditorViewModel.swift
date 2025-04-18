//
//  StoryEditorViewModel.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import UIKit


final class StoryEditorViewModel: ObservableObject {
    
   // @Published var story = Story(id: "", user: "me", layers: [], audioURL: nil, previewURL: "",  creationDate: "")

    func loadInitialMedia(_ media: BackgroundMediaItem) {
        print("loadInitialMedia")
        addBackgroundVideo(media.videoURL)
    }

    init(backgroundVideoURL : URL) {
        self.backgroundVideoURL = backgroundVideoURL
    }
    
    // background video is separate from overlay layers
    @Published var backgroundVideoURL: URL
    
    private func addBackgroundVideo(_ url: URL) {
        backgroundVideoURL = url
    }

    func addImageLayer(_ image: UIImage) {
       // let layer = ImageLayer(image: image, position: CGPoint(x: 100, y: 100), scale: 1.0)
       // story.layers.append(.image(layer))
    }
    
    func addTextLayer(_ text: String) {
        //let layer = TextLayer(text: text, position: CGPoint(x: 150, y: 150), fontSize: 13)
        //story.layers.append(.text(layer))
    }
 
}
