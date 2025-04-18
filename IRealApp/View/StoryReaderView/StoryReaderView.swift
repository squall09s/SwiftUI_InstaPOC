//
//  StoryEditorView.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import Foundation
import PhotosUI
import AVKit
import UIKit
import AVKit


struct StoryReaderView: View {
    
    @ObservedObject var likeStore = LikeStore.shared
    
    @State private var isLiked = false
    
    @StateObject private var viewModel: StoryReaderViewModel
    @State private var player: AVQueuePlayer? = nil
    @State private var looper: AVPlayerLooper? = nil
    @State private var progress: Double = 0.0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss
    
    
    init(story: Story) {
        _viewModel = StateObject(wrappedValue: StoryReaderViewModel(story: story))
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // Progress bar representing video playback
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.3))
                    Rectangle().fill(Color.yellow)
                        .frame(width: proxy.size.width * progress)
                }
                .frame(height: 4)
                
                // Video and layers
                ZStack {
                    // Fullscreen looping background video
                    PlayerView(player: player)
                        .ignoresSafeArea()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .onAppear {
                            
                            guard let videoURL = viewModel.story.videoURL else {
                                return
                            }
                            
                            let asset = AVURLAsset(url: videoURL)
                            asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                                var error: NSError? = nil
                                let status = asset.statusOfValue(forKey: "playable", error: &error)

                                if status == .loaded {
                                    DispatchQueue.main.async {
                                        let item = AVPlayerItem(asset: asset)
                                        let queuePlayer = AVQueuePlayer()
                                        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                                        queuePlayer.play()
                                        player = queuePlayer
                                    }
                                } else {
                                    print("Asset not playable: \(error?.localizedDescription ?? "Unknown error")")
                                }
                            }
                        }
                    
                    // Overlay layers
                    ForEach(viewModel.story.layers.indices, id: \.self) { idx in
                        let layer = viewModel.story.layers[idx]
                        layerContent(layer)
                            .gesture(
                                DragGesture().onChanged { value in
                                    switch layer {
                                    case .image(var img):
                                        img.position = value.location
                                        viewModel.story.layers[idx] = .image(img)
                                    case .text(var txt):
                                        txt.position = value.location
                                        viewModel.story.layers[idx] = .text(txt)
                                    case .gif(var gf):
                                        gf.position = value.location
                                        viewModel.story.layers[idx] = .gif(gf)
                                    }
                                }
                            )
                    }
                    
                    // Like button en bas à droite
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            LikeButtonView(
                                isLiked: Binding(
                                    get: { likeStore.isLiked(viewModel.story.id) },
                                    set: { _ in likeStore.toggle(viewModel.story.id) }
                                )
                            )
                            .padding()
                            
                        }
                    }
                }.contentShape(Rectangle()) // Permet de capter le gesture sur tout le ZStack
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded {
                                withAnimation {
                                    likeStore.toggle(viewModel.story.id)
                                }
                            }
                    )
            }
            .onReceive(timer) { _ in
                guard let player = player,
                      let currentItem = player.currentItem,
                      currentItem.duration.seconds > 0 else { return }
                progress = currentItem.currentTime().seconds / currentItem.duration.seconds
            }
        }
        .onDisappear {
            // Stop playback and release resources
            player?.pause()
            player = nil
            looper = nil
            // Cancel the timer to avoid retain cycles
            timer.upstream.connect().cancel()
            
            print("StoryPlayerView cleaned up")
        }
    }

    @ViewBuilder
    private func layerContent(_ layer: StoryLayer) -> some View {
        switch layer {
        case .image(let img):
            Image(uiImage: img.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(img.scale)
                .position(img.position)

        case .text(let txt):
            Text(txt.text)
                .font(Font.system(size: 12))
                .position(txt.position)

        case .gif(let gf):
            VideoPlayer(player: AVPlayer(url: gf.url))
                .frame(width: 100, height: 100)
                .scaleEffect(gf.scale)
                .position(gf.position)
        
        }
    }
}


#Preview {
    let url = Bundle.main.url(forResource: "sample_video", withExtension: "mp4")!
    StoryReaderView(story: Story(id: "1", user: "", layers: [], videoURL: url, previewURL: ""))
}
