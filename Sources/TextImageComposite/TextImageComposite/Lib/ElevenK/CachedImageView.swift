//
//  CachedImageView.swift
//
//  Created by Jacob Bullock on 10/9/17.
//  Copyright © 2017 Eleven K, Inc. All rights reserved.
//

import Foundation
import UIKit

@MainActor
public class CachedImageView : UIImageView
{
    
    var imageURL: URL? {
        
        didSet {
            
            if let img = TICConfig.instance.imageCache.object(forKey: NSString(string: (self.imageURL?.absoluteString)!) ) as? UIImage {
                //print("using cache:\(self.imageURLString)")
                self.image = img
            } else {
                self.image = nil
                guard let url = imageURL else {
                    return
                }
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    Task {
                        if let error = error {
                            await MainActor.run {
                                self.image = nil
                            }
                            print("Error: \(error)")
                            return
                        }

                        if let data = data, let img = UIImage(data: data) {
                            await TICConfig.instance.imageCache.setObject(img, forKey: NSString(string: self.imageURL?.absoluteString ?? ""))
                            await MainActor.run {
                                self.image = img
                            }
                        } else {
                            await MainActor.run {
                                self.image = nil
                            }
                        }
                    }
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
