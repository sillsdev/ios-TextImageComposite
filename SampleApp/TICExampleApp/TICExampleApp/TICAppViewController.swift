//
//  ViewController.swift
//  TICExampleApp
//
//  Created by David Moore on 11/10/20.
//  Derived from original authored by Jacob Bullock
//

import UIKit
import TextImageComposite

class TICAppViewController: UIViewController, TICTextViewDelegate  {
    
    var firstTime = false
    @IBOutlet weak var watermarkSlider: UISwitch!
    @IBOutlet weak var videoSlider: UISwitch!
    @IBOutlet weak var noReferenceSlider: UISwitch!
    @IBOutlet weak var rtlTest: UISwitch!
    @IBOutlet weak var linkTest: UISwitch!
    @IBOutlet weak var weirdTextSwitch: UISwitch!
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
            TICConfig.instance.defaultFont = "Verdana"
            TICConfig.instance.locale = TICLocalization.us_en()
            TICConfig.instance.theme = TICTheme.defaultTheme()
        }
        if rtlTest.isOn {
            TICConfig.instance.text = "وْمْلِّي سْمَعْ الْمَلِكْ هِيرُودُسْ هَادْشِّي، خَافْ هُوَ وْݣَاعْ النَّاسْ اللِّي فْأُورْشَلِيمْ."
            TICConfig.instance.rtl = true
        } else if weirdTextSwitch.isOn {
            TICConfig.instance.text = "Chigaja Jesucristonga va attian'choma afe cuintsu Jesúsja tise semasundeccunga condaye. Junde tsoña\'chone condase\'cho tsu. Jesúsja tisema sefacconi\'su shondo\'suma moensi tsaja Juanga jipa attian."
        } else {
            TICConfig.instance.text = "In the beginning, God's created the heavens and the earth."
            //TICConfig.instance.text = "Zacarias yacj ũssawe\'shtyi dyuus yatte \n selpiwa\'j en ãjte\', na\'wẽc yuu: \" & < > ` "
            //TICConfig.instance.text = "Andy namicu Teófilo, indya\'s cjiyu\'jna fi\'jatstju cue\'sh ensu na\'wẽ yuuc tyã\'sna. Tyã\'sa\' tyã\'wẽ yũuya\' tacjetsíyna, Cristo yacj u\'jusawe\'sha\' ma\'wẽrrajne\'ta ew uy tyã\'wẽytyi tyãawe\'sha\' cue\'shtyi pta\'sh, atsa\' tyã\'sa\' maava tyã\'wẽyta ew pta\'shna fi\'jrra nviit wẽe. Tyãa pa\'ga andyva ma\'wẽrrajne\' yũu tyã\'sa\' wala ew jypa\'yacy paapẽjyrra indyna pta\'shna fi\'jatstju, cyaj isa yuj pta\'shi\'ne\'ta sũjũne\'nga."
            //TICConfig.instance.text = "After six days, Jesus took with him Peter, James, and John his brother, and brought them up into a high mountain by themselves.  He was changed before them. His face shone like the sun, and his garments became as white as the light. \nPeter answered, and said to Jesus, “Lord, it is good for us to be here. If you want, let’s make three tents here: one for you, one for Moses, and one for Elijah.” \nWhile he was still speaking, behold, a bright cloud overshadowed them. Behold, a voice came out of the cloud, saying, “This is my beloved Son, in whom I am well pleased. Listen to him.” \nAs they were coming down from the mountain, Jesus commanded them, saying, “Don’t tell anyone what you saw, until the Son of Man has risen from the dead. And even longer and longer.  This is a test of the emergency broadcasting system."
        }
         if noReferenceSlider.isOn {
            TICConfig.instance.reference = ""
        } else {
            if rtlTest.isOn {
                TICConfig.instance.reference = " إنجيل متّى ٢\u{200f}:٣"
            } else if weirdTextSwitch.isOn {
                TICConfig.instance.reference = "Canjaen'cho 1.1"
            } else {
                TICConfig.instance.reference = "Genesis 1:1"
            }

        }
        if watermarkSlider.isOn {
            if TICConfig.instance.watermarkImage == nil {
                TICConfig.instance.watermarkImage = TICWatermark.init(watermarkImage: UIImage.init(named: "watermark.png")!, alignment: TICWatermarkAlignment.BOTTOM_RIGHT, marginPercent: 5, widthPercent: 25)
            }
        } else {
            TICConfig.instance.watermarkImage = nil
        }
        if videoSlider.isOn {
            if (TICConfig.instance.sharingDelegate == nil) {
                TICConfig.instance.sharingDelegate = VideoGenerator()
            }
        } else {
            TICConfig.instance.sharingDelegate = nil
        }
        if linkTest.isOn {
            TICConfig.instance.link = "https://dwr8g.app.link?ref=C02/MAT.2.6"
        }
//        TICConfig.instance.originalOrientation = .portrait
//        TICConfig.instance.originalOrientationMask = .portrait
        TICConfig.instance.textViewDelegate = self
        TICConfig.instance.active = true
        let storyboard = UIStoryboard(name: TICConfig.instance.storyboardName, bundle: TICConfig.instance.bundle)
        let nvc = storyboard.instantiateViewController(withIdentifier: TICConfig.instance.viewControllerName) as! UINavigationController
        nvc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
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
    
    // MARK:- TICTextViewDelegate
    func getTextViewController() -> EditTextBaseViewController {
        let vc = ExampleAppTextViewController()
        return vc
    }
    func lockOrientation(mask: UIInterfaceOrientationMask, orientation: UIInterfaceOrientation? ) {
        if let unwrappedOrientation = orientation {
            AppUtility.lockOrientation(mask, andRotateTo: unwrappedOrientation)
        } else {
            AppUtility.lockOrientation(mask)
        }
    }
}

