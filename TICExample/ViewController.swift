//
//  ViewController.swift
//  TICExample
//
//  Created by Jacob Bullock on 10/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func fonts() -> [TICFont]
    {
        var list : [TICFont] = []
        list.append(TICFonts.andikaFont)
        list.append(TICFont.init(title : "Arial", fontFamily: "Arial"))
        list.append(TICFont.init(title : "Helvetica", fontFamily: "Helvetica"))
        list.append(TICFont.init(title : "Verdana", fontFamily: "Verdana"))
        list.append(TICFont.init(title : "Chalkboard", fontFamily: "Chalkboard SE"))
        list.append(TICFont.init(title : "Avenir", fontFamily: "Avenir"))
        list.append(TICFont.init(title : "Courier New", fontFamily: "Courier New"))
        
        return list
    }
    
    @IBAction func handlePromptEditorButtonTap(_ sender: Any)
    {
        TICConfig.instance.text = "In the beginning, God created the heavens and the earth."
        TICConfig.instance.reference = "Genesis 1:1"
        TICConfig.instance.images = TICImages.allImages
        TICConfig.instance.fonts = fonts()
        TICConfig.instance.locale = TICLocalization.us_en()
        TICConfig.instance.theme = TICTheme.defaultTheme()
        
        let storyboard = UIStoryboard(name: "TIC", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "TICNavController") as! UINavigationController
        
        present(nvc, animated: true, completion: nil)
    }
}

