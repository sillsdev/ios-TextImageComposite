//
//  CachedImageView.swift
//
//  Created by Jacob Bullock on 10/9/17.
//  Copyright © 2017 Eleven K, Inc. All rights reserved.
//

import Foundation
import UIKit

public class CachedImageView : UIImageView
{
    let imageCache = NSCache<NSString, AnyObject>()
    
    var imageURL: URL? {
        
        didSet {
            
            if let img = self.imageCache.object(forKey: NSString(string: (self.imageURL?.absoluteString)!) ) as? UIImage {
                //print("using cache:\(self.imageURLString)")
                self.image = img
            } else {
                self.image = nil
                guard let url = imageURL else {
                    return
                }
                URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
                    if error != nil {
                        self.image = nil
                        print("\(String(describing: error))")
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        [weak self] in
                        let img = UIImage(data: data!)
                        
                        self?.imageCache.setObject(img!, forKey: NSString(string: (self?.imageURL?.absoluteString)! ) )
                        
                        self?.image = img
                    })
                }.resume()
            }
        }
    }
    
    var imageURLString: String? {
        
        didSet {
            
            if  let url = URL(string: imageURLString!) {
                imageURL = url
            }
        }
    }
}
