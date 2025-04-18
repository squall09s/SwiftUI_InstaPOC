# SwiftUI_InstaPOC
iReal SwiftUI POC

This proof-of-concept project is designed to demonstrate a clean, modular architecture for an Instagram-like story editor app built with SwiftUI and MVVM.

🏗 Architecture Overview

1. MVVM Pattern

Models: Immutable data structures representing core entities.

Story: Represents a story session containing multiple layers.

StoryLayer: Enum differentiating between Image, Text, and Gif layers.

ViewModels: Handle business logic and state management.

StoryEditorViewModel: Manages story creation, adding layers, and background video URL.

StoryFeedViewModel: Fetches and provides mock story data for the feed.

Views: SwiftUI views bound to ViewModels via @StateObject or @ObservedObject.

ContentView: Entry point with TabView for Feed and Create screens.

CameraView: Wraps AVCaptureSession for live capture and passes media URL.

StoryEditorView: Displays background video, progress bar, and draggable layers.

StoryFeedView: Lists stories in a NavigationView.

2. Modular Components

PlayerView: UIViewControllerRepresentable wrapping AVPlayerViewController with controls disabled.

UIImage+Video Extension: Converts a static UIImage into a fixed-duration video using AVAssetWriter.

CameraPreview: UIViewRepresentable for AVCaptureVideoPreviewLayer.

3. Navigation and Presentation

TabView: Switches between the Feed and Create tabs.

Modal Presentation: Uses .sheet(item:) to present StoryEditorView when media is captured.

No Deep NavigationStack: Simplifies flow by avoiding complex navigation paths.

4. Data Flow

Capture or pick a video URL in CameraView.

Pass the URL to ContentView, which triggers the sheet.

StoryEditorViewModel initializes with the provided URL and sets up the looping player.

User adds layers via the + menu; ViewModel updates story.layers.

Save/Cancel actions finalize or discard the session.

📂 Project Structure

IRealApp/
├── Models/
│   ├── Story.swift
│   ├── StoryLayer.swift
│   └── ImageLayer.swift, TextLayer.swift, GifLayer.swift
├── ViewModels/
│   ├── StoryEditorViewModel.swift
│   └── StoryFeedViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── CameraView.swift
│   ├── StoryFeedView.swift
│   ├── StoryEditorView.swift
│   └── PlayerView.swift
├── Extensions/
│   └── UIImage+Video.swift
├── Utilities/
│   └── CameraPreview.swift
└── Resources/
    └── sample_video.mp4 (for SwiftUI previews)

⚙️ Requirements

Xcode 15+

Swift 5.8+

iOS 17+ deployment target

🚀 Getting Started

Clone the repository.

Open IRealApp.xcodeproj in Xcode.

Add a sample_video.mp4 to the Project for previews.

Run on Simulator or Device.

This POC focuses on clean separation of concerns, testable ViewModels, and reusable SwiftUI components, without backend integration or user authentication.