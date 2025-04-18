//
//  CameraViewModel.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import Foundation
import AVKit

final class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var captureCompletion: (BackgroundMediaItem) -> Void

    init(captureCompletion: @escaping (BackgroundMediaItem) -> Void) {
        self.captureCompletion = captureCompletion
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()
        // Input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        // Outputs
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        if session.canAddOutput(movieOutput) { session.addOutput(movieOutput) }
        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func startRecording() {
        
        print("startRecording")
        guard !isRecording else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempMovie.mov")
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try? FileManager.default.removeItem(at: tempURL)
        }
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording() {
        print("stopRecording")
        guard isRecording else { return }
        movieOutput.stopRecording()
        isRecording = false
    }
    
    func importImage(image : UIImage){
        
        
        DispatchQueue.main.async {
            
            image.normalized().toVideo { _urlVideo in
                guard let urlVideo = _urlVideo else { return }
                
                let media = BackgroundMediaItem(videoURL: urlVideo)
                self.captureCompletion(media)
                
            }
            
        }
    }
   
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
       
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
        image.normalized().toVideo { _urlVideo in
            
            guard let _urlVideo = _urlVideo else { return }
            
            let media = BackgroundMediaItem(videoURL: _urlVideo)
            
            DispatchQueue.main.async {
                self.captureCompletion(media)
            }
            
        }
        
       
         
         
    }
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let media = BackgroundMediaItem(videoURL: outputFileURL)
        DispatchQueue.main.async {
            self.captureCompletion(media)
        }
    }
}
