//
//  TICFontAttributesPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/18/20.
//

import UIKit

class TICFontAttributesPanelView : TICBasePanelView {

    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicsButton: UIButton!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var letterSpacingSlider: UISlider!
    
    let fontSliderMinimum: Float = 5
    let fontSliderMaximum: Float = 40
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        boldButton.isSelected = true
        boldButton.tintColor = TICConfig.instance.theme.tintColor
        TICConfig.instance.theme.formatControl(fontSizeSlider)
        fontSizeSlider.value = 20
        fontSizeSlider.minimumValue = fontSliderMinimum
        fontSizeSlider.maximumValue = fontSliderMaximum
        TICConfig.instance.theme.formatControl(letterSpacingSlider)
    }
    @IBAction func italicsButtonPressed(_ sender: Any) {
        flipButtonSelected(button: italicsButton, attribute: .fontStyle, selectedValue: "italic", unselectedValue: "normal", section: .text)
    }
    @IBAction func boldButtonPressed(_ sender: Any) {
        flipButtonSelected(button: boldButton, attribute: .fontWeight, selectedValue: "bold", unselectedValue: "normal", section: .text)
    }
    @IBAction func fontSizeValueChanged(_ sender: UISlider) {
        changeFontSize(size: sender.value)
    }
    
    @IBAction func letterSpacingValueChanged(_ sender: UISlider) {
        let letterSpacing = Int(sender.value)
        let ls = String(letterSpacing) + "px"
        self.delegate.setStyle(.letterSpacing, ls, .both)
    }
    func changeFontSize(size: Float) {
        let pointSize = String(Int(size)) + "pt"
        self.delegate.setStyle(.fontSize, pointSize, .text)
        self.fontDelegate?.setLineHeightFromFontSize(Int(size))

    }
}
extension TICFontAttributesPanelView: SBFontSizeDelegate {
    func getFontSizeMaximum() -> Float {
        return fontSliderMaximum
    }
    
    func getFontSizeMinimum() -> Float {
        return fontSliderMinimum
    }
    
    func getFontSize() -> Float {
        return fontSizeSlider.value
    }
    
    func setFontSize(newSize: Float) {
        fontSizeSlider.value = newSize
        changeFontSize(size: newSize)
    }
}
