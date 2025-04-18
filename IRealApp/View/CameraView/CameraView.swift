//
//  CameraView.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import AVKit
import PhotosUI

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

struct CameraView: View {
    
    @StateObject private var viewModel: CameraViewModel
    
    @State private var libraryItem: PhotosPickerItem? = nil
    
    init(onCapture: @escaping (BackgroundMediaItem) -> Void) {
        _viewModel = StateObject(wrappedValue: CameraViewModel(captureCompletion: onCapture))
    }
    
    var body: some View {
        ZStack {
            
            CameraPreview(session: viewModel.session).background(Color.red.opacity(0.1))
                .ignoresSafeArea()
            
            Rectangle()
                .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.0),   // 100% opaque en haut
                                Color.black.opacity(0.2)    //  10% opaque en bas
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    ).ignoresSafeArea()
            
            VStack {
                
                Spacer()
               
                HStack(spacing : 0) {
                        
                        PhotosPicker(
                            selection: $libraryItem,
                            matching: .any(of: [.images]),
                            photoLibrary: .shared()) {
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .imageScale(.medium)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                        
                        RoundLongPressButton(
                            actionCourte: {
                                print("Clic rapide")
                                viewModel.capturePhoto()
                            },
                            actionLongueStarted: {
                                print("Long press démarrée")
                                viewModel.startRecording()
                            },
                            actionLongueFinish: { durée in
                                print("Long press terminée après \(durée)s")
                                viewModel.stopRecording()
                            }
                        ).frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    }
                .frame(height: 80)
                .background(Color.clear)
                    .padding(.bottom, 50)
                    .padding(.horizontal, 20)
                
                
                
            }
        }
        .onAppear { viewModel.startSession() }
        .onDisappear { viewModel.stopSession() }
        .onChange(of: libraryItem) { newItem in
            Task {
                guard let item = newItem else { return }
                
                // 1. Essayer de charger une image
                if let data: Data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.importImage(image: uiImage)
                }
                
            }
        }
    }
}


#Preview {
    CameraView { _ in
        
    }
}
