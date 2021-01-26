//
//  TICShareViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 10/19/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TextProvider: NSObject, UIActivityItemSource {
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        
        return NSObject()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == .postToTwitter || activityType == .postToFacebook {
            return ""
        }
        return nil
    }
}

public class ImageProvider: NSObject, UIActivityItemSource {
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "ic_check_black")!
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return UIImage(named:"ic_check_black")
    }
}

public class TICShareViewController : UIViewController
{
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    public var compositeImage : UIImage?
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.imageView.image = self.compositeImage
        doneButton.title = TICConfig.instance.locale.done
        shareButton.setTitle(TICConfig.instance.locale.share, for: .normal)
        shareButton.tintColor = TICConfig.instance.theme.tintColor
        shareButton.layer.borderColor = TICConfig.instance.theme.tintColor.cgColor
        shareButton.layer.borderWidth = 1
        
    }
    
    @IBAction func handleShareButtonTap(_ sender: Any) {
        
        if let img = self.compositeImage {
            
            var activityItems : [Any] = [img]
            if TICConfig.instance.sharingDelegate != nil {
                if let videoURL = TICConfig.instance.sharingDelegate!.createVideo(TICConfig.instance, img) {
                    activityItems = [videoURL]
                }
            } 

            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = self.shareButton
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
