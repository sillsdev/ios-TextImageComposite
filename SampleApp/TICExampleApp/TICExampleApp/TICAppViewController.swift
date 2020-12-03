//
//  ViewController.swift
//  TICExampleApp
//
//  Created by David Moore on 11/10/20.
//  Derived from original authored by Jacob Bullock
//

import UIKit
import TextImageComposite

class TICAppViewController: UIViewController {
    func fonts() -> [TICFont] {
        
        var list : [TICFont] = []
        
        //Custom font added through Info.plist
        list.append(TICFont.init(title : "Andika", fontFamily: "Andika New Basic"))
        
        //system fonts
        list.append(TICFont.init(title : "Arial", fontFamily: "Arial"))
        list.append(TICFont.init(title : "Helvetica", fontFamily: "Helvetica"))
        list.append(TICFont.init(title : "Verdana", fontFamily: "Verdana"))
        list.append(TICFont.init(title : "Chalkboard", fontFamily: "Chalkboard SE"))
        list.append(TICFont.init(title : "Avenir", fontFamily: "Avenir"))
        list.append(TICFont.init(title : "Courier New", fontFamily: "Courier New"))
        
        return list
    }
    func images() -> [TICImage] {
        let textureImageUrls : [TICImage] = [TICImage.init(imageName: "texture_1.jpg", thumbName: "thumb_texture_1.jpg"),
                                                           TICImage.init(imageName: "texture_2.jpg", thumbName: "thumb_texture_2.jpg"),
                                                           TICImage.init(imageName: "texture_3.jpg", thumbName: "thumb_texture_3.jpg"),
                                                           TICImage.init(imageName: "texture_4.jpg", thumbName: "thumb_texture_4.jpg"),
                                                           TICImage.init(imageName: "texture_5.jpg", thumbName: "thumb_texture_5.jpg"),
                                                           TICImage.init(imageName: "texture_6.jpg", thumbName: "thumb_texture_6.jpg"),
                                                           TICImage.init(imageName: "texture_7.jpg", thumbName: "thumb_texture_7.jpg"),]
        
        let natureImageUrls : [TICImage] = [TICImage.init(imageName: "nature_1.jpg", thumbName: "thumb_nature_1.jpg"),
                                                          TICImage.init(imageName: "nature_2.jpg", thumbName: "thumb_nature_2.jpg"),
                                                          TICImage.init(imageName: "nature_3.jpg", thumbName: "thumb_nature_3.jpg"),
                                                          TICImage.init(imageName: "nature_4.jpg", thumbName: "thumb_nature_4.jpg"),
                                                          TICImage.init(imageName: "nature_5.jpg", thumbName: "thumb_nature_5.jpg"),
                                                          TICImage.init(imageName: "nature_6.jpg", thumbName: "thumb_nature_6.jpg"),
                                                          TICImage.init(imageName: "nature_7.jpg", thumbName: "thumb_nature_7.jpg"),
                                                          TICImage.init(imageName: "nature_8.jpg", thumbName: "thumb_nature_8.jpg"),
                                                          TICImage.init(imageName: "ocean.jpg", thumbName: "thumb_ocean.jpg")]
        
        return textureImageUrls + natureImageUrls
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func promptPressed(_ sender: Any) {
        TICConfig.instance.text = "In the beginning, God created the heavens and the earth."
        TICConfig.instance.reference = "Genesis 1:1"
        TICConfig.instance.images = images()
        TICConfig.instance.fonts = fonts()
        TICConfig.instance.locale = TICLocalization.us_en()
        TICConfig.instance.theme = TICTheme.defaultTheme()
        //UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        let storyboard = UIStoryboard(name: TICConfig.instance.storyboardName, bundle: TICConfig.instance.bundle)
        let nvc = storyboard.instantiateViewController(withIdentifier: TICConfig.instance.viewControllerName) as! UINavigationController
        nvc.modalPresentationStyle = .fullScreen
        present(nvc, animated: true, completion: nil)
    }
/*    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if TICConfig.instance.active {
            return .portrait
        } else {
            return .all
        }
    }
  
    public override var shouldAutorotate: Bool {
        if TICConfig.instance.active {
            return false
        } else {
            return true
        }
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }*/
}

