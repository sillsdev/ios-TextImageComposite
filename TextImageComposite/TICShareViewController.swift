//
//  TICShareViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 10/19/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

class TextProvider: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == .postToTwitter || activityType == .postToFacebook {
            return ""
        }
        return nil
    }
}

class ImageProvider: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "check_black")!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return UIImage(named:"check_black")
    }
}

class TICShareViewController : UIViewController
{
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    public var compositeImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.compositeImage
        textView.text = ""
        shareButton.title = TICConfig.instance.locale.share
    }
    
    @IBAction func handleShareButtonTap(_ sender : UIBarButtonItem)
    {
        if let img = self.compositeImage
        {
            let activityItems : [Any] = [img] //[ImageProvider(), TextProvider()]
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            self.present(vc, animated: true, completion: nil)
        }
        
    }
}
