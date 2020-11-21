//
//  TICTextShadowPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 11/20/20.
//

import UIKit

class TICTextShadowPanelView : TICFormatPanelView {

    @IBOutlet weak var resizeIcon: UIImageView!
    @IBOutlet weak var resizeSlider: UISlider!
    override public func layoutSubviews() {
        super.layoutSubviews()
        resizeSlider.value = 1
        TICConfig.instance.theme.formatControl(resizeSlider)
        TICConfig.instance.theme.formatImage(resizeIcon)
        if let btn = viewWithTag(100) as? UIButton {
            // Set No Shadow as default
            self.handleSelectableButtonTap(btn)
        }

    }
    @IBAction func resizeSliderValueChanged(_ sender: UISlider) {
        let selectedTag = selectedButton!.tag
        if selectedTag == 101 {
            setShadow()
        } else if selectedTag == 102 {
            setGlow()
        }
    }
    @IBAction func noShadowButtonPressed(_ sender: Any) {
        setNoShadow()
    }
    @IBAction func shadowButtonPressed(_ sender: Any) {
        setShadow()
    }
    @IBAction func glowButtonPressed(_ sender: Any) {
        setGlow()
    }
    func setShadow() {
        let sliderValue = String(Int(resizeSlider.value))
        let shadowValue = sliderValue + "px " + sliderValue + "px " + sliderValue + "px #111111"
        self.delegate.setStyle(.textShadow, shadowValue, .both)
    }
    func setNoShadow() {
        let shadowValue = "0px 0px 0px #333333"
        self.delegate.setStyle(.textShadow, shadowValue, .both)
    }
    func setGlow() {
        let sliderValue = String(Int(resizeSlider.value))
        let shadowValue = "0px 0px " + sliderValue + "px #111111"
        self.delegate.setStyle(.textShadow, shadowValue, .both)
    }
}
