//
//  TICReferenceFontPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/20/20.
//

import UIKit

class TICReferenceFontPanelView : TICBasePanelView {

    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicsButton: UIButton!
    @IBOutlet weak var fontSizeSlider: UISlider!

    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(fontSizeSlider)
        fontSizeSlider.value = 15
    }
    
    @IBAction func boldButtonPressed(_ sender: Any) {
        flipButtonSelected(button: boldButton, attribute: .fontWeight, selectedValue: "bold", unselectedValue: "normal", section: .reference)
    }
    @IBAction func italicsButtonPressed(_ sender: Any) {
        flipButtonSelected(button: italicsButton, attribute: .fontStyle, selectedValue: "italic", unselectedValue: "normal", section: .reference)
    }
    @IBAction func textSizeChanged(_ sender: UISlider) {
        changeFontSize(size: fontSizeSlider.value)
    }
    func changeFontSize(size: Float) {
        let pointSize = String(Int(size)) + "pt"
        self.delegate.setStyle(.fontSize, pointSize, .reference)
    }
}
extension TICReferenceFontPanelView: SBFontSizeDelegate {
    func getFontSize() -> Float {
        return fontSizeSlider.value
    }
    
    func setFontSize(newSize: Float) {
        fontSizeSlider.value = newSize
        changeFontSize(size: newSize)
    }
}
