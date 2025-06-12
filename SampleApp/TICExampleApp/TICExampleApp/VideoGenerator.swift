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
import AVFoundation

class VideoGenerator: SharingDelegate {
    func createVideo(config: TICConfig, image: UIImage, completionHandler: @escaping TICShareCompletionHandlerType) -> Bool {
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let data = image.jpegData(compressionQuality: 1.0) {
                let imageURL = getCreateSupportDirectory("audio", excludeFromBackup: true)!.appendingPathComponent("image.png")
                try? data.write(to: imageURL)
                self.generateVideo(TICConfig.instance, imageURL, completionHandler: completionHandler)
            } else {
                completionHandler(false, nil)
            }
        }
        return true
    }
    
    func generateVideo(_ config: TICConfig, _ imageURL: URL, completionHandler: @escaping TICShareCompletionHandlerType) {
        let imageFilename = imageURL.path
        let outputFilename = "Genesis-1-1.mp4"
        let finalVideoURL = getCreateSupportDirectory("video", excludeFromBackup:true)!.appendingPathComponent(outputFilename)
        let videoOnlyURL = getCreateSupportDirectory("video", excludeFromBackup:true)!.appendingPathComponent("tmp\(outputFilename)")
        let audioURL = Bundle.main.url(forResource: "Genesis-1.1.mp3", withExtension: "")!
        NSLog("Audio URL \(audioURL.path) imageFilename: \(imageFilename)")
        let duration = getAudioDuration(url: audioURL)
        deleteIfPresent(finalVideoURL)
        deleteIfPresent(videoOnlyURL)
        self.createVideoFromImage(imageURL: imageURL, duration: duration, outputURL: videoOnlyURL) {result in
            switch result {
            case .success(let videoURL):
                self.mergeAudioWithVideo(videoURL: videoURL, audioURL: audioURL, outputURL: finalVideoURL) {finalResult in
                    switch finalResult{
                    case .success(let finalURL):
                        NSLog("Successful creation of: \(finalURL.path)")
                        completionHandler(true, finalURL);
                    case .failure(let error):
                        NSLog("Error merging video and audio: \(error)")
                        completionHandler(false, nil);
                    }
                }
            case .failure(let error):
                NSLog("Unsuccessful creation of video from image: \(error)")
                completionHandler(false, nil);
            }
        }
        return
    }
    func mergeAudioWithVideo(videoURL: URL, audioURL: URL, outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let composition = AVMutableComposition()

        // Add video track
        let videoAsset = AVAsset(url: videoURL)
        let videoTrack = videoAsset.tracks(withMediaType: .video).first!
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try! videoCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)

        // Add audio track
        let audioAsset = AVAsset(url: audioURL)
        if let audioTrack = audioAsset.tracks(withMediaType: .audio).first {
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            try! audioCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: audioTrack, at: .zero)
        }

        // Export final video
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4

        exporter.exportAsynchronously { [weak exporter] in
            guard let exporter = exporter else { return }
            if let error = exporter.error {
                completion(.failure(error))
            } else {
                completion(.success(outputURL))
            }
        }
    }
    func createVideoFromImage(imageURL: URL, duration: CMTime, outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let image = UIImage(contentsOfFile: imageURL.path), let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "InvalidImage", code: -1, userInfo: nil)))
            return
        }

        // Get original image size
        let width = cgImage.width
        let height = cgImage.height
        let size = CGSize(width: width, height: height)

        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mp4)
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

        let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool!
        let frameDuration = CMTime(value: 1, timescale: 30)  // 30 FPS

        DispatchQueue.global().async {
            let image = UIImage(contentsOfFile: imageURL.path)!.cgImage!
            let buffer = self.createPixelBuffer(from: image, pixelBufferPool: pixelBufferPool, size: size)!

            for frame in 0..<Int(duration.seconds * 30) {
                while !writerInput.isReadyForMoreMediaData { usleep(10_000) }
                pixelBufferAdaptor.append(buffer, withPresentationTime: CMTimeMultiply(frameDuration, multiplier: Int32(frame)))
            }

            writerInput.markAsFinished()
            writer.finishWriting {
                completion(.success(outputURL))
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
    func convertMP3ToM4A(inputURL: URL, outputURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        
        // Create Asset Reader
        guard let assetReader = try? AVAssetReader(asset: asset) else {
            completion(false, NSError(domain: "MP3Converter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetReader"]))
            return
        }
        
        // Get audio track
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            completion(false, NSError(domain: "MP3Converter", code: -2, userInfo: [NSLocalizedDescriptionKey: "No audio track found"]))
            return
        }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM, // Change to kAudioFormatMPEG4AAC for AAC/M4A
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        // Create Asset Reader Output
        let assetReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        assetReader.add(assetReaderOutput)
        
        // Create Asset Writer
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .m4a) else {
            completion(false, NSError(domain: "MP3Converter", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetWriter"]))
            return
        }
        
        let inputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 128000
        ]
        
        let assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: inputSettings)
        assetWriterInput.expectsMediaDataInRealTime = false
        
        // Add input to writer
        assetWriter.add(assetWriterInput)
        
        // Start Reading & Writing
        assetReader.startReading()
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        let processingQueue = DispatchQueue(label: "audioProcessingQueue")
        
        assetWriterInput.requestMediaDataWhenReady(on: processingQueue) {
            while assetWriterInput.isReadyForMoreMediaData {
                if let sampleBuffer = assetReaderOutput.copyNextSampleBuffer() {
                    assetWriterInput.append(sampleBuffer)
                } else {
                    assetWriterInput.markAsFinished()
                    assetWriter.finishWriting {
                        assetReader.cancelReading()
                        completion(true, nil)
                    }
                    break
                }
            }
        }
    }
}
