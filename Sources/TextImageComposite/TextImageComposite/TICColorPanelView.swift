//
//  TICColorPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICColorPanelView : TICBasePanelView, SBColorFormatDelegate
{
    @IBOutlet weak var whiteButton : UIButton!
    @IBOutlet weak var blackButton : UIButton!
    @IBOutlet weak var customColorButton : UIButton!
    @IBOutlet weak var opacitySlider : UISlider!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        self.whiteButton.isSelected = true
        TICConfig.instance.theme.formatControl(opacitySlider)
        whiteButton.layer.borderColor = UIColor.darkGray.cgColor
        whiteButton.layer.borderWidth = 1
        
        customColorButton.backgroundColor = .clear
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = customColorButton.layer.bounds;
        gradientLayer.colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange].map { $0.cgColor }
        gradientLayer.locations = [0.0,0.25,0.5,0.75,1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.1)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.9)
        gradientLayer.cornerRadius = customColorButton.layer.cornerRadius;
        customColorButton.layer.addSublayer(gradientLayer)
    }
    
    @IBAction func handleBlackButtonTap(_ sender: UIButton) {
        
        self.delegate.setStyle(.color, "black", .both)
        sender.isSelected = true
        whiteButton.isSelected = false
        customColorButton.isSelected = false
    }
    
    @IBAction func handleWhiteButtonTap(_ sender: UIButton) {
        
        self.delegate.setStyle(.color, "white", .both)
        sender.isSelected = true
        blackButton.isSelected = false
        customColorButton.isSelected = false
    }
    
    @IBAction func handleColorDetailsButtonTap(_ sender: UIButton) {
        
        self.delegate.showColorDetails()
    }
    
    @IBAction func handleOpacitySliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setStyle(.opacity, String(sender.value), .both )
    }
    
    public func customColorWasSelected() {
        
        blackButton.isSelected = false
        whiteButton.isSelected = false
        customColorButton.isSelected = true
    }
}

public class TICColorPickerPanelView : TICBasePanelView, ColorPickerDelegate {
    
    @IBOutlet weak var colorPicker : ColorPicker!
    @IBOutlet weak var brightnessSlider : BrightnessSlider!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        colorPicker.delegate = self
        brightnessSlider.delegate = self
        self.colorPicker.brightnessSlider = brightnessSlider
    }
    
    func pickedColor(_ color: UIColor) {
        
        self.delegate.setStyle(.color, color.toHex()!, .both)
        self.colorDelegate?.customColorWasSelected()
    }
}
