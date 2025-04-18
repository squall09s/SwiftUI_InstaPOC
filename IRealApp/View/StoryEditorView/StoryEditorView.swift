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

/// A UIViewControllerRepresentable wrapper for AVPlayer without controls
struct PlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.view.backgroundColor = .black
        return controller
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct StoryEditorView: View {
    @StateObject private var viewModel: StoryEditorViewModel
    @State private var player: AVQueuePlayer? = nil
    @State private var looper: AVPlayerLooper? = nil
    @State private var progress: Double = 0.0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddMenu = false

    
    init(videoURL: URL) {
        _viewModel = StateObject(wrappedValue: StoryEditorViewModel(backgroundVideoURL: videoURL))
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
                            guard player == nil else { return }
                            let queuePlayer = AVQueuePlayer()
                            let item = AVPlayerItem(url: viewModel.backgroundVideoURL)
                            looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                            queuePlayer.play()
                            player = queuePlayer
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
                }
                .overlay(
                    
                    VStack {
                        // Top bar with Cancel and + menu
                        HStack {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.white)

                            Spacer()
                            // Updated + button and expanding menu
                            ZStack {
                                // Main + button
                                Button(action: {
                                    withAnimation {
                                        showAddMenu.toggle()
                                    }
                                }) {
                                    Image(systemName: showAddMenu ? "xmark.circle.fill" : "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 44, height: 44)

                                
                            }
                        }.background(Color.clear)

                        // Expanding menu slides in from the right
                        if showAddMenu {
                            HStack{
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    Button("Text") {
                                        showAddMenu.toggle()
                                        viewModel.addTextLayer("Example Text")
                                    }
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    
                                    Button("Image") {
                                        showAddMenu.toggle()
                                        // TODO: present image picker
                                    }
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    
                                    Button("Gif") {
                                        showAddMenu.toggle()
                                        // TODO: present GIF picker
                                    }
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .background(Color.clear)
                                
                                
                            }.transition(.move(edge: .trailing).combined(with: .opacity))
                                .offset(x: -10, y: 10) // adjust vertical offset to appear below +
                        }
                        
                        Spacer()

                        // Bottom bar with Save
                        HStack {
                            Spacer()
                            Button("Save") {
                                // TODO: implement save action
                            }
                            .foregroundColor(.white)
                            
                        }.background(Color.clear)
                    }
                    .padding()
                )
            }
            .onReceive(timer) { _ in
                guard let player = player,
                      let currentItem = player.currentItem,
                      currentItem.duration.seconds > 0 else { return }
                progress = currentItem.currentTime().seconds / currentItem.duration.seconds
            }
        }
        .navigationTitle("Édition Story")
        .onDisappear {
            // Stop playback and release resources
            player?.pause()
            player = nil
            looper = nil
            // Cancel the timer to avoid retain cycles
            timer.upstream.connect().cancel()
            
            print("StoryEditorView cleaned up")
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
    StoryEditorView(videoURL: url)
}
