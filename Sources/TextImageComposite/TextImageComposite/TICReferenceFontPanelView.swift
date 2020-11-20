//
//  TICReferenceFontPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/20/20.
//

import UIKit

class TICReferenceFontPanelView : TICFormatPanelView {

    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicsButton: UIButton!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var sizeIcon: UIImageView!

    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(fontSizeSlider)
        fontSizeSlider.value = 15
        TICConfig.instance.theme.formatImage(sizeIcon)
    }
    
    @IBAction func boldButtonPressed(_ sender: Any) {
        flipButtonSelected(button: boldButton, attribute: .fontWeight, selectedValue: "bold", unselectedValue: "normal", section: .reference)
    }
    @IBAction func italicsButtonPressed(_ sender: Any) {
        flipButtonSelected(button: italicsButton, attribute: .fontStyle, selectedValue: "italic", unselectedValue: "normal", section: .reference)
    }
    @IBAction func textSizeChanged(_ sender: UISlider) {
        let pointSize = String(Int(sender.value)) + "pt"
        self.delegate.setStyle(.fontSize, pointSize, .reference)
    }
}
