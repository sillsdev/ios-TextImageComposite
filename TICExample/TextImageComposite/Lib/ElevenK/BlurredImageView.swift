//
//  BlurredImageView.swift
//
//  Created by Jacob Bullock on 10/10/17.
//  Copyright © 2017 Eleven K, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension UIImage {
    convenience init(view: UIView) {
        
        //have to use the drawHierarchy method for the Blur to work
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        //view.layer.render(in: UIGraphicsGetCurrentContext()!)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

//I didn't get it to work using this method, so i used the BlurredImageView
extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        
        // set boundry and alpha
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha
        
        self.addSubview(effectView)
    }
}

class BlurredImageView: CachedImageView
{
    var effect : UIBlurEffect? = nil
    var effectView : UIVisualEffectView? = nil

    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect
        if(effect == nil)
        {
            effect = UIBlurEffect(style: .light)
            effectView = UIVisualEffectView(effect: effect)
            
            
            // set boundry and alpha
            effectView?.frame = self.bounds
            effectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            //effectView?.alpha = alpha
            
            self.addSubview(effectView!)
        }
        
        effectView?.alpha = alpha
    }
}
