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
}
