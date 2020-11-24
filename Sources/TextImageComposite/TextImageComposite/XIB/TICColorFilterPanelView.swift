//
//  TICColorFilterPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/24/20.
//

import UIKit

class TICColorFilterPanelView : TICFormatPanelView {

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
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(brightnessSlider)
        TICConfig.instance.theme.formatControl(contrastSlider)
        TICConfig.instance.theme.formatControl(saturationSlider)

    }
}
