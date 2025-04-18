//
//  VideoTools.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import UIKit
import AVFoundation

extension UIImage {
    /// Exporte l'image en vidéo .mov de la durée spécifiée, et renvoie l'URL du fichier temporaire via le completion handler.
    /// - Parameters:
    ///   - duration: Durée de la vidéo en secondes (par défaut 5s).
    ///   - frameRate: Nombre d'images par seconde (par défaut 30fps).
    ///   - completion: Closure appelée avec l'URL du fichier vidéo en cas de succès, ou nil en cas d'erreur.
    func toVideo(duration: TimeInterval = 5.0,
                 frameRate: Int32 = 30,
                 completion: @escaping (URL?) -> Void) {
        // Création de l'URL temporaire
       
       
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(UUID().uuidString).mov"
        let outputURL = tempDir.appendingPathComponent(fileName)

        // Supprimer si existe déjà
        try? FileManager.default.removeItem(at: outputURL)

        // Configuration de l'AVAssetWriter
        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
            completion(nil)
            return
        }

        let size = CGSize(width: self.size.width * self.scale,
                          height: self.size.height * self.scale)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false

        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput,
                                                           sourcePixelBufferAttributes: sourceBufferAttributes)

        guard writer.canAdd(writerInput) else {
            completion(nil)
            return
        }
        writer.add(writerInput)

        // Démarrage de l'écriture
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let frameCount = Int(frameRate) * Int(duration)
        var frameNum = 0

        let queue = DispatchQueue(label: "imageToVideoQueue")
        writerInput.requestMediaDataWhenReady(on: queue) {
            while writerInput.isReadyForMoreMediaData && frameNum < frameCount {
                let presentationTime = CMTime(value: CMTimeValue(frameNum), timescale: frameRate)
                guard let pixelBuffer = self.newPixelBuffer(from: self, size: size, pixelBufferPool: adaptor.pixelBufferPool) else {
                    break
                }
                if !adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    break
                }
                frameNum += 1
            }
            if frameNum >= frameCount {
                writerInput.markAsFinished()
                writer.finishWriting {
                    DispatchQueue.main.async {
                        completion(outputURL)
                    }
                }
            }
        }
    }

    /// Crée un `CVPixelBuffer` à partir de l'image.
    private func newPixelBuffer(from image: UIImage,
                                size: CGSize,
                                pixelBufferPool: CVPixelBufferPool?) -> CVPixelBuffer? {
        guard let pool = pixelBufferPool else { return nil }
        var pixelBufferOut: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBufferOut)
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOut else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        if let cgImage = image.cgImage {
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer
    }
    
    /// Retourne une image redessinée avec orientation .up
    func normalized() -> UIImage {
           guard imageOrientation != .up else { return self }
           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           draw(in: CGRect(origin: .zero, size: size))
           let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           return normalizedImage
    }
    
    
}



