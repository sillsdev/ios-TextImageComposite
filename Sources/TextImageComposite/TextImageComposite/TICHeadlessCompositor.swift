//
//  TICHeadlessCompositor.swift
//  TextImageComposite
//
//  Provides a headless (no UI) interface for generating a composite image from
//  the first image in TICConfig, overlaid with caller-supplied text and reference.
//  The visual TICCustomizeViewController interface is left fully intact.
//

import Foundation
import UIKit

/// Headless compositor – generates a composite image without presenting any UI.
///
/// **Typical usage**
/// ```swift
/// // 1. Configure TICConfig as usual
/// TICConfig.instance.images = [TICImage(imageName: "background.jpg")]
/// TICConfig.instance.fonts  = [TICFont(title: "MyFont", fontFamily: "MyFont")]
/// TICConfig.instance.defaultFont = "MyFont"
///
/// // 2. Choose an output path
/// let outputURL = FileManager.default
///     .urls(for: .documentDirectory, in: .userDomainMask)[0]
///     .appendingPathComponent("output.jpg")
///
/// // 3. Generate
/// TICHeadlessCompositor.generateImage(
///     text: "In the beginning…",
///     reference: "Genesis 1:1",
///     outputURL: outputURL
/// ) { success, error in
///     if success { print("Saved to \(outputURL)") }
/// }
/// ```
public class TICHeadlessCompositor {

    // MARK: - Error type

    public enum CompositorError: Error {
        /// No images are present in `TICConfig.instance.images`.
        case noImagesConfigured
        /// The image file at the configured URL could not be loaded.
        case imageLoadFailed
        /// Core Graphics failed to produce a rendered image.
        case renderingFailed
        /// The JPEG/PNG data could not be written to the requested URL.
        case saveFailed(underlying: Error)
    }

    // MARK: - Output format

    public enum OutputFormat {
        /// JPEG with the given compression quality (0.0 – 1.0, default 0.9).
        case jpeg(quality: CGFloat)
        /// PNG (lossless).
        case png

        /// Derives a sensible format from a file-URL extension; falls back to JPEG.
        public static func inferred(from url: URL) -> OutputFormat {
            switch url.pathExtension.lowercased() {
            case "png":  return .png
            default:     return .jpeg(quality: 0.9)
            }
        }
    }

    // MARK: - Public API

    /// Generates a composite image and writes it to `outputURL`.
    ///
    /// - Parameters:
    ///   - outputURL:   Destination file URL.  The output format is inferred from
    ///                  the path extension (`.png` → PNG, everything else → JPEG).
    ///   - format:      Override the output format.  When `nil` the format is
    ///                  inferred from `outputURL`'s path extension.
    ///   - completion:  Called on the **main thread** with `(true, nil)` on
    ///                  success or `(false, error)` on failure.
    public static func generateImage(
        outputURL: URL,
        format: OutputFormat? = nil,
        completion: @escaping (_ success: Bool, _ error: Error?) -> Void
    ) {
        // All UIKit drawing must happen on the main thread.
        let work = {
            do {
                let image = try render()
                let resolvedFormat = format ?? OutputFormat.inferred(from: outputURL)
                try write(image: image, to: outputURL, format: resolvedFormat)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }

        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async { work() }
        }
    }

    /// Synchronous variant – **must** be called on the main thread.
    ///
    /// Returns the composite `UIImage` without saving to disk, giving callers
    /// full control over how the image is persisted or displayed.
    ///
    /// - Parameters:
    ///   - text:      The main body text to overlay on the image.
    ///   - reference: Optional reference / caption text.
    /// - Throws: `CompositorError` on failure.
    /// - Returns: The composited `UIImage`.
    public static func renderImage(text: String, reference: String) throws -> UIImage {
        return try render()
    }

    // MARK: - Private helpers

    private static func render() throws -> UIImage {
        let config = TICConfig.instance

        // ── 1. Load base image ────────────────────────────────────────────────
        guard !config.images.isEmpty else {
            throw CompositorError.noImagesConfigured
        }

        guard var baseImage = UIImage(contentsOfFile: config.images[0].imageURL.path) else {
            throw CompositorError.imageLoadFailed
        }

        let text = config.text
        let reference = config.reference
        
        // ── 2. Apply watermark (mirrors TICCustomizeViewController.setupImage) ─
        if let watermark = config.watermarkImage,
           let watermarkImg = watermark.watermarkImage {
            let w = Int(baseImage.size.width)
            let h = Int(baseImage.size.height)
            let origin = watermark.getXY(w, h)
            UIGraphicsBeginImageContextWithOptions(baseImage.size, false, 0.0)
            baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
            watermarkImg.draw(in: CGRect(
                x: origin.x,
                y: origin.y,
                width: watermark.getWatermarkWidth(w),
                height: watermark.getWatermarkHeight(h)
            ))
            if let stamped = UIGraphicsGetImageFromCurrentImageContext() {
                baseImage = stamped
            }
            UIGraphicsEndImageContext()
        }

        // ── 3. Resolve font ───────────────────────────────────────────────────
        let fontFamily = !config.defaultFont.isEmpty
            ? config.defaultFont
            : (config.fonts.first?.fontFamily ?? "Helvetica")

        let imageWidth  = baseImage.size.width
        let imageHeight = baseImage.size.height

        // Font sizes mirror the web-view heuristic (body width / 9 for the max).
        let mainFontSize: CGFloat  = imageWidth / 12.0
        let refFontSize:  CGFloat  = mainFontSize * 0.65

        let mainFont = UIFont(name: fontFamily, size: mainFontSize)
            ?? UIFont.boldSystemFont(ofSize: mainFontSize)
        let refFont  = UIFont(name: fontFamily, size: refFontSize)
            ?? UIFont.systemFont(ofSize: refFontSize)

        // ── 4. Build attributed strings ───────────────────────────────────────
        let paragraphStyle      = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Shadow for legibility (matches typical usage in the visual interface).
        let shadow          = NSShadow()
        shadow.shadowColor  = UIColor.black.withAlphaComponent(0.6)
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        shadow.shadowBlurRadius = 4

        let mainAttributes: [NSAttributedString.Key: Any] = [
            .font:            mainFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle:  paragraphStyle,
            .shadow:          shadow
        ]
        let refAttributes: [NSAttributedString.Key: Any] = [
            .font:            refFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle:  paragraphStyle,
            .shadow:          shadow
        ]

        // ── 5. Measure text blocks ────────────────────────────────────────────
        // Text block width = 75 % of image width (matches alignment panel default).
        let blockWidth: CGFloat = imageWidth * 0.75
        let measureSize = CGSize(width: blockWidth, height: imageHeight)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let mainRect = (text as NSString)
            .boundingRect(with: measureSize, options: options,
                          attributes: mainAttributes, context: nil)

        let refRect: CGRect = reference.isEmpty ? .zero
            : (reference as NSString)
                .boundingRect(with: measureSize, options: options,
                              attributes: refAttributes, context: nil)

        let interSpacing: CGFloat = mainFontSize * 0.4
        let blockHeight: CGFloat  = mainRect.height
            + (reference.isEmpty ? 0 : interSpacing + refRect.height)

        // ── 6. Draw ───────────────────────────────────────────────────────────
        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale)
        defer { UIGraphicsEndImageContext() }

        // Background image
        baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))

        // Centre the block vertically.
        let blockX: CGFloat = (imageWidth  - blockWidth)  / 2.0
        let blockY: CGFloat = (imageHeight - blockHeight) / 2.0

        let mainDrawRect = CGRect(x: blockX, y: blockY,
                                  width: blockWidth, height: mainRect.height)
        (text as NSString).draw(in: mainDrawRect, withAttributes: mainAttributes)

        if !reference.isEmpty {
            let refY = blockY + mainRect.height + interSpacing
            let refDrawRect = CGRect(x: blockX, y: refY,
                                     width: blockWidth, height: refRect.height)
            (reference as NSString).draw(in: refDrawRect, withAttributes: refAttributes)
        }

        guard let compositeImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw CompositorError.renderingFailed
        }
        return compositeImage
    }

    private static func write(image: UIImage, to url: URL, format: OutputFormat) throws {
        let data: Data?
        switch format {
        case .jpeg(let quality):
            data = image.jpegData(compressionQuality: quality)
        case .png:
            data = image.pngData()
        }

        guard let imageData = data else {
            throw CompositorError.renderingFailed
        }

        // Create intermediate directories if needed.
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory,
                                                withIntermediateDirectories: true)

        do {
            try imageData.write(to: url, options: .atomic)
        } catch {
            throw CompositorError.saveFailed(underlying: error)
        }
    }
}
