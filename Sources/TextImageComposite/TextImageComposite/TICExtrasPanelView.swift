//
//  TICExtrasPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICExtrasPanelView : TICBasePanelView
{
    @IBOutlet weak var blurSlider: UISlider!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(blurSlider)
    }
    
    @IBAction func handleBlurSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setImageBlur(Float(sender.value))
    }
}
