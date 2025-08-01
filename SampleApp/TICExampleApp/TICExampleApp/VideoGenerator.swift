//
//  VideoGenerator.swift
//  TICExampleApp
//
//  Created by hubbard on 1/25/21.
//

import Foundation
import UIKit
import TextImageComposite
import ffmpegkit
@preconcurrency import AVFoundation

class VideoGenerator: SharingDelegate, @unchecked Sendable  {
    class CompletionBoxTIC: @unchecked Sendable {
        let call: TICShareCompletionHandlerType
        init(_ call: @escaping TICShareCompletionHandlerType) {
            self.call = call
        }
    }
    final class AVAssetExportSessionBox: @unchecked Sendable {
        let session: AVAssetExportSession
        init(_ pool: AVAssetExportSession) { self.session = pool }
    }
    func createVideo(config: TICConfig, image: UIImage, completionHandler: @escaping TICShareCompletionHandlerType) -> Bool {
        let completionBox = CompletionBoxTIC(completionHandler)
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let data = image.jpegData(compressionQuality: 1.0) {
                let imageURL = getCreateSupportDirectory("audio", excludeFromBackup: true)!.appendingPathComponent("image.png")
                try? data.write(to: imageURL)
                self.generateVideo(TICConfig.instance, imageURL, completionHandler: completionBox.call)
            } else {
                completionBox.call(false, nil)
            }
        }
        return true
    }
    
    func generateVideo(_ config: TICConfig, _ imageURL: URL, completionHandler: @escaping TICShareCompletionHandlerType) {
        let completionBox = CompletionBoxTIC(completionHandler)
        let imageFilename = imageURL.path
        let outputFilename = "Genesis-1-1.mp4"
        let finalVideoURL = getCreateSupportDirectory("video", excludeFromBackup:true)!.appendingPathComponent(outputFilename)
        let videoOnlyURL = getCreateSupportDirectory("video", excludeFromBackup:true)!.appendingPathComponent("tmp\(outputFilename)")
        let audioURL = Bundle.main.url(forResource: "Genesis-1.1.mp3", withExtension: "")!
        NSLog("Audio URL \(audioURL.path) imageFilename: \(imageFilename)")
        let duration = getAudioDuration(url: audioURL)
        deleteIfPresent(finalVideoURL)
        deleteIfPresent(videoOnlyURL)
        Task {
            do {
                let videoURL = try await createVideoFromImage(imageURL: imageURL, duration: duration, outputURL: videoOnlyURL)
                do {
                    let finalURL = try await self.mergeAudioWithVideo(videoURL: videoURL, audioURL: audioURL, outputURL: finalVideoURL)
                    NSLog("Successful creation of: \(finalURL.path)")
                    await MainActor.run {
                        completionBox.call(true, finalURL);
                    }
                } catch {
                    await MainActor.run {
                        completionBox.call(false, nil)
                    }
                }
            }
            catch {
                NSLog("Unsuccessful creation of video from image: \(error)")
                await MainActor.run {
                    completionBox.call(false, nil);
                }
            }
        }
    }
    func mergeAudioWithVideo(videoURL: URL, audioURL: URL, outputURL: URL) async throws -> URL {
        let composition = AVMutableComposition()
        
        // Add video track
        let videoAsset = AVAsset(url: videoURL)
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            throw NSError(domain: "mergeAudioWithVideo", code: 1, userInfo: [NSLocalizedDescriptionKey: "No video track found"])
        }
        
        let videoCompositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )!
        
        try videoCompositionTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: videoAsset.duration),
            of: videoTrack,
            at: .zero
        )
        
        // Add audio track
        let audioAsset = AVAsset(url: audioURL)
        if let audioTrack = audioAsset.tracks(withMediaType: .audio).first {
            let audioCompositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )!
            
            try audioCompositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: audioTrack,
                at: .zero
            )
        }

        // Prepare exporter
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw NSError(domain: "mergeAudioWithVideo", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession"])
        }

        let exportSessionBox = AVAssetExportSessionBox(exportSession)
        exportSessionBox.session.outputURL = outputURL
        exportSessionBox.session.outputFileType = .mp4

        // Await export completion
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSessionBox.session.status {
                case .completed:
                    continuation.resume(returning: outputURL)
                case .failed, .cancelled:
                    let error = exportSessionBox.session.error ?? NSError(
                        domain: "mergeAudioWithVideo",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Export failed without specific error"]
                    )
                    continuation.resume(throwing: error)
                default:
                    break // Should not happen, but don't resume in .waiting or .exporting
                }
            }
        }
    }
    func createVideoFromImage(imageURL: URL, duration: CMTime, outputURL: URL) async throws -> URL {
        guard let image = UIImage(contentsOfFile: imageURL.path), let cgImage = image.cgImage else {
            throw NSError(domain: "InvalidImage", code: -1, userInfo: nil)
        }

        // Get original image size
        let width = cgImage.width
        let height = cgImage.height
        let size = CGSize(width: width, height: height)

        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height
        ])

        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let frameDuration = CMTime(value: 1, timescale: 30)  // 30 FPS
        let frameCount = Int(duration.seconds * 30)
        let createPixelBuffer = self.createPixelBuffer

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                guard let cgImage = UIImage(contentsOfFile: imageURL.path)?.cgImage,
                      let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool,
                      let buffer = createPixelBuffer(cgImage, pixelBufferPool, size)
                else {
                    continuation.resume(throwing: NSError(domain: "PixelBufferCreationFailed", code: -2, userInfo: nil))
                    return
                }

                for frame in 0..<frameCount {
                    while !writerInput.isReadyForMoreMediaData {
                        usleep(10_000)
                    }
                    let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frame))
                    pixelBufferAdaptor.append(buffer, withPresentationTime: presentationTime)
                }

                writerInput.markAsFinished()
                writer.finishWriting {
                    if writer.status == .completed {
                        continuation.resume(returning: outputURL)
                    } else {
                        continuation.resume(throwing: writer.error ?? NSError(domain: "UnknownWriterError", code: -3, userInfo: nil))
                    }
                }
            }
        }
    }
    // Helper function to create a pixel buffer from an image
    func createPixelBuffer(from image: CGImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )

        context?.draw(image, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
    func getAudioDuration(url: URL) -> CMTime {
        let asset = AVAsset(url: url)
        return asset.duration
    }
    func convertToJPEG(imageURL: URL) -> URL? {
        guard let image = UIImage(contentsOfFile: imageURL.path),
              let jpegData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        let newURL = imageURL.deletingPathExtension().appendingPathExtension("jpg")
        try? jpegData.write(to: newURL)
        return newURL
    }
    func convertMP3ToM4A(inputURL: URL, outputURL: URL) async throws {
        let asset = AVAsset(url: inputURL)

        guard let assetReader = try? AVAssetReader(asset: asset),
              let assetTrack = asset.tracks(withMediaType: .audio).first else {
            throw NSError(domain: "convertMP3ToM4A", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read input asset"])
        }

        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM, // Change to kAudioFormatMPEG4AAC for AAC/M4A
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]

        let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: outputSettings)
        assetReader.add(assetReaderOutput)

        // Create Asset Writer
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .m4a) else {
            throw NSError(domain: "MP3Converter", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetWriter"])
        }
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 128000
        ]

        let assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        assetWriterInput.expectsMediaDataInRealTime = false
        assetWriter.add(assetWriterInput)

        let processingQueue = DispatchQueue(label: "AudioConversionQueue")

        guard assetReader.startReading(), assetWriter.startWriting() else {
            throw NSError(domain: "Conversion", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to start reading/writing"])
        }

        assetWriter.startSession(atSourceTime: .zero)

        try await withCheckedThrowingContinuation { continuation in
            assetWriterInput.requestMediaDataWhenReady(on: processingQueue) {
                while assetWriterInput.isReadyForMoreMediaData {
                    if let sampleBuffer = assetReaderOutput.copyNextSampleBuffer() {
                        assetWriterInput.append(sampleBuffer)
                    } else {
                        assetWriterInput.markAsFinished()

                        assetWriter.finishWriting {
                            if assetWriter.status == .completed {
                                continuation.resume()
                            } else {
                                assetReader.cancelReading()
                                continuation.resume(throwing: assetWriter.error ?? NSError(domain: "Conversion", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unknown writing error"]))
                            }
                        }

                        break
                    }
                }
            }
        }
    }
}
