//
//  TICColorFilterPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/24/20.
//

import UIKit

class TICColorFilterPanelView : TICBasePanelView {

    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        delegate.setImageBrightness(sender.value)
    }
    @IBAction func contrastSliderValueChanged(_ sender: UISlider) {
        // To make the base value (1) the middle when contrast range goes from 0 to 3
        var value = sender.value
/*        if value > 1 {
            value = 1 + ((value - 1) * 2)
        } else if value < 1 {
            value = 1 - ((1 - value) / 4)
        } */
        delegate.setImageContrast(value)
    }
    @IBAction func saturationSliderValueChanged(_ sender: UISlider) {
        var value = sender.value
        if value > 1 {
            value = 1 + ((value - 1) * 9)
        }
        delegate.setImageSaturation(value)
    }
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(brightnessSlider)
        TICConfig.instance.theme.formatControl(contrastSlider)
        TICConfig.instance.theme.formatControl(saturationSlider)
        
        brightnessSlider.minimumValue = -0.25
        brightnessSlider.maximumValue = 0.25
        brightnessSlider.value = 0
        
        contrastSlider.minimumValue = 0.75
        contrastSlider.maximumValue = 1.25
        contrastSlider.value = 1
        
        saturationSlider.minimumValue = 0
        saturationSlider.maximumValue = 2
        saturationSlider.value = 1

    }
}
