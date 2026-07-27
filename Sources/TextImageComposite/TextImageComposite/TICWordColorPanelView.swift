//
//  TICWordPanelView.swift
//  TextImageComposite
//
//  Created by David Yaho on 7/27/26.
//

import Foundation
import UIKit

public class TICWordColorPanelView : TICBasePanelView, SBColorFormatDelegate, ColorPickerDelegate 
{
    @IBOutlet weak var whiteButton : UIButton!
    @IBOutlet weak var blackButton : UIButton!
    @IBOutlet weak var customColorButton : UIButton!
    @IBOutlet weak var opacitySlider : UISlider!
    @IBOutlet weak var lowerCaseButton: UIButton!
    @IBOutlet weak var upperCaseButton: UIButton!
    
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
        
        self.delegate.setWordStyle(.color, "black")
        sender.isSelected = true
        whiteButton.isSelected = false
        customColorButton.isSelected = false
    }
    
    @IBAction func handleWhiteButtonTap(_ sender: UIButton) {
        
        self.delegate.setWordStyle(.color, "white")
        sender.isSelected = true
        blackButton.isSelected = false
        customColorButton.isSelected = false
    }
    
    @IBAction func handleColorDetailsButtonTap(_ sender: UIButton) {
        
        self.delegate.showColorDetails()
    }
    
    @IBAction func handleOpacitySliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setWordStyle(.opacity, String(sender.value))
    }
    
    @IBAction func lowerCasePressed(_ sender: Any) {
        self.delegate.setLastTappedWordCase(toUpper: false)
    }
    @IBAction func upperCasePressed(_ sender: Any) {
        self.delegate.setLastTappedWordCase(toUpper: true)
    }
    public func customColorWasSelected() {
        
        blackButton.isSelected = false
        whiteButton.isSelected = false
        customColorButton.isSelected = true
    }
    public func pickedColor(_ color: UIColor) {
        if let hex = color.toHex() {
            self.delegate.setWordStyle(.color, hex)
        }
        self.customColorWasSelected()
    }
}

