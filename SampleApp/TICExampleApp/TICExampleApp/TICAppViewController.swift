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
    var firstTime = false
    var testWatermark = true
    func fonts() -> [TICFont] {
        
        var list : [TICFont] = []
        TICConfig.instance.fontBaseURL = Bundle.main.resourceURL!
        
        //Custom font added through Info.plist
        list.append(TICFont.init(title : "Andika", fontFamily: "Andika New Basic", fileName: "AndikaNewBasic-R.ttf"))
        
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
        let textureImageUrls : [TICImage] = [TICImage.init(imageName: "texture_1.jpg"),
                                                           TICImage.init(imageName: "texture_2.jpg"),
                                                           TICImage.init(imageName: "texture_3.jpg"),
                                                           TICImage.init(imageName: "texture_4.jpg"),
                                                           TICImage.init(imageName: "texture_5.jpg"),
                                                           TICImage.init(imageName: "texture_6.jpg"),
                                                           TICImage.init(imageName: "texture_7.jpg"),]
        
        let natureImageUrls : [TICImage] = [TICImage.init(imageName: "ray-hennessy-HlJ7U9WHRR8-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "cross-66700_1920-pixabay-1080.jpg"),
                                                          TICImage.init(imageName: "aaron-burden-6jYoil2GhVk-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "aaron-burden-BxmJUeJrlp4-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "bady-qb-MDgRcuGYu58-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "damian-patkowski-T-LfvX-7IVg-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "desert-790640_1920-pixabay-1080.jpg"),
                                                          TICImage.init(imageName: "ryan-schroeder-Gg7uKdHFb_c-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "wheat-3241114_1920-pixabay-1080.jpg"),
                                                          TICImage.init(imageName: "sam-ueGaQiHV86o-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "chris-gallimore-f9fJ6nxndoo-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "desert-1731660-pexels-1080.jpg"),
                                                          TICImage.init(imageName: "gabriel-garcia-marengo-kOqBCFsGTs8-unsplash-1080.jpg"),
                                                          TICImage.init(imageName: "jeremy-bishop-QHZn3-0bbEM-unsplash-1080.jpg")]
        
        return natureImageUrls
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func promptPressed(_ sender: Any) {
        if !firstTime {
            firstTime = true
            TICConfig.instance.images = images()
            TICConfig.instance.fonts = fonts()
            TICConfig.instance.locale = TICLocalization.us_en()
            TICConfig.instance.theme = TICTheme.defaultTheme()

        }
        TICConfig.instance.text = "In the beginning, God created the heavens and the earth."
        TICConfig.instance.reference = "Genesis 1:1"
        if testWatermark {
            TICConfig.instance.watermarkImage = TICWatermark.init(watermarkImage: UIImage.init(named: "watermark.png")!, alignment: .BOTTOM_RIGHT, marginPercent: 5, widthPercent: 25)
        }
        TICConfig.instance.active = true
        let storyboard = UIStoryboard(name: TICConfig.instance.storyboardName, bundle: TICConfig.instance.bundle)
        let nvc = storyboard.instantiateViewController(withIdentifier: TICConfig.instance.viewControllerName) as! UINavigationController
        nvc.modalPresentationStyle = .fullScreen
        present(nvc, animated: true, completion: nil)
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if TICConfig.instance.active {
                return .portrait
            } else {
                return .all
            }
        }
    }
  
    public override var shouldAutorotate: Bool {
        if TICConfig.instance.active {
            return true
        } else {
            return true
        }
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

