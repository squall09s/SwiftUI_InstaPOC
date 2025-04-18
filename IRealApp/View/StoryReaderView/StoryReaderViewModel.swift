//
//  StoryEditorViewModel.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import UIKit


final class StoryReaderViewModel: ObservableObject {
    
    @Published var story : Story

    init(story : Story) {
        self.story = story
    }
    
   
}
