//
//  UIImageExtension.swift
//  TextImageComposite
//
//  Created by David Moore on 1/27/21.
//

import Foundation
import UIKit

extension UIImage {
    func scaledTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img!
    }
    func rotatedLeft90() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.height,
                                                            height: size.width))
        return renderer.image { context in
            let cgContext = context.cgContext
            // Move origin to the center of the new image
            cgContext.translateBy(x: size.height / 2, y: size.width / 2)
            // Rotate 90° counterclockwise
            cgContext.rotate(by: -.pi / 2)
            // Draw the original image centered
            draw(in: CGRect(x: -size.width / 2,
                            y: -size.height / 2,
                            width: size.width,
                            height: size.height))
        }
    }
}
