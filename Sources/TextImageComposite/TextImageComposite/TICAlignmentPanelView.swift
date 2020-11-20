//
//  TICAlignmentPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICAlignmentPanelView : TICFormatPanelView
{
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let btn = viewWithTag(101) as? UIButton {
            self.handleSelectableButtonTap(btn)
        }
    }
    
    @IBAction func handleJustificationButtonTap(_ sender: UIButton) {
        
        self.delegate.setStyle(.textAlign, (Alignment(rawValue: sender.tag)?.stringValue())!, .both )
    }
    
    @IBAction func handleMarginsButtonTap(_ sender: UIButton) {
        
        self.delegate.showMargins()
    }
}

public class TICMarginsPanelView : TICFormatPanelView {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet var sliders : [UISlider]!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        for slider : UISlider in sliders
        {
            TICConfig.instance.theme.formatControl(slider)
        }
        
        topLabel.text = TICConfig.instance.locale.top
        leftLabel.text = TICConfig.instance.locale.left
        rightLabel.text = TICConfig.instance.locale.right
        
        TICConfig.instance.theme.formatLabel(topLabel)
        TICConfig.instance.theme.formatLabel(leftLabel)
        TICConfig.instance.theme.formatLabel(rightLabel)
    }
    
    @IBAction func handleTopSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setBodyStyle(.marginTop, String(Int(300 * sender.value))+"px" )
    }
    
    @IBAction func handleLeftSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setBodyStyle(.marginLeft, String(Int(300 * sender.value))+"px" )
    }
    
    @IBAction func handleRightSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setBodyStyle(.marginRight, String(Int(300 * sender.value))+"px" )
    }
}
