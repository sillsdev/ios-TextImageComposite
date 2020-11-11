//
//  TICExtrasPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICExtrasPanelView : TICFormatPanelView
{
    @IBOutlet weak var blurLabel: UILabel!
    @IBOutlet weak var blurSlider: UISlider!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatLabel(blurLabel)
        TICConfig.instance.theme.formatControl(blurSlider)
        blurLabel.text = TICConfig.instance.locale.blur
    }
    
    @IBAction func handleBlurSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setImageBlur(CGFloat(sender.value))
    }
}
