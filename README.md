# 🚀 SwiftUI InstaPOC – Story Editor App

A polished SwiftUI proof-of-concept mimicking core features of Instagram Stories, built with modern architecture and delightful UI.

## 🏗 Architecture Overview

### 🧠 1. MVVM Pattern
- **Models**: Immutable data structures representing core entities (e.g. `Story`, `StoryLayer`).
- **ViewModels**: Handle business logic and state (e.g. `StoryEditorViewModel`, `StoryFeedViewModel`).
- **Views**: SwiftUI views connected to their ViewModels via `@StateObject` / `@ObservedObject`.

### 🧩 2. Modular Components
- `PlayerView`: Embeds AVPlayer for video playback.
- `UIImage+Video`: Turns an image into a short video segment.
- `CameraPreview`: Live camera feed using `AVCaptureVideoPreviewLayer`.

### 🧭 3. Navigation and Presentation
- `TabView`: Navigates between Create tabs, Feed and profil.
- `Modal Sheets`: Displays the Story Editor after capture.
- Streamlined user flow without deep navigation stacks.

### 🔄 4. Data Flow
1. Capture or pick a video.
2. Pass it to `ContentView` via a sheet.
3. Initialize the editor and preview the looping video.
4. Add overlays (text, image, gif).
5. Save or discard the story session.

## 📁 Project Structure

```text
IRealApp/
├── Models/               # Data definitions (Story, Layers)
├── ViewModels/           # Business logic for editor and feed
├── Views/                # SwiftUI screens
├── Extensions/           # UIKit helpers
├── Utilities/            # Camera-related utilities
└── Resources/            # Preview video & static assets
```

## ✨ Highlights

- Built 100% in SwiftUI with iOS 17 APIs
- Fully modular MVVM design
- Reusable animated components (like/heart)
- Story layer system (GIFs, text, images over video)
- No backend: everything runs locally
- Media loaded via URLs but stored directly in repo (Resources/)

## ✅ Requirements

- Xcode 15+
- Swift 5.8+
- iOS 17+

## 🛠 Getting Started

```bash
git clone https://github.com/your-username/SwiftUI_InstaPOC.git
open IRealApp.xcodeproj
```

Then run it in the simulator or on a real device 🚀

