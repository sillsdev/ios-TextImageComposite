//
//  TICFontPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICFontPanelView : TICFormatPanelView
{
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontScrollView: UIScrollView!
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    var selectedFontButton: UIButton? = nil
    var availableFonts: [TICFont] = []
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(fontSizeSlider)
        TICConfig.instance.theme.formatLabel(sizeLabel)
        TICConfig.instance.theme.formatLabel(fontSizeLabel)
        
        sizeLabel.text = TICConfig.instance.locale.size
    }
    
    @IBAction func handleTextSizeSliderValueChanged(_ sender: UISlider) {
        
        let pointSize = String(Int(sender.value)) + "pt"
        self.delegate.setStyle(.fontSize, pointSize)
        self.fontDelegate?.setLineHeightFromFontSize(Int(sender.value))
        fontSizeLabel.text = pointSize
    }
    
    @IBAction func handleFontDetailsButtonTap(_ sender: Any) {
        
        self.delegate.showFontDetails()
    }
    
    func setAvailableFonts(fonts : [TICFont]) {
        
        availableFonts = fonts
        
        var x : Int = 20
        var i : Int = 0
        for f : TICFont in fonts {
            let button = UIButton(type: .custom)
            let str : NSString = f.title as NSString
            let font = UIFont(name: f.fontFamily, size: 17) //should add if let
            if(i == 0) {
                button.isSelected = true
                selectedFontButton = button
            }
            button.tag = i
            button .setTitle(f.title, for: .normal)
            button.setTitleColor(TICConfig.instance.theme.accentColor, for: .normal)
            button.setTitleColor(TICConfig.instance.theme.tintColor, for: .selected)
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(handleFontButtonTap(_:)), for: .touchUpInside)
            let stringSize = str.size(attributes: [NSFontAttributeName: font!])
            let buttonSize = Int(stringSize.width) + 20
            button.frame = CGRect(x: x, y: 0, width: buttonSize, height: Int(fontScrollView.frame.size.height))
            x = x + buttonSize + 10
            i = i + 1
            fontScrollView.addSubview(button)
        }
        
        fontScrollView.contentSize = CGSize(width: x, height: Int(fontScrollView.frame.size.height))
    }
    
    func handleFontButtonTap(_ sender: UIButton) {
        
        if let btn = selectedFontButton {
            btn.isSelected = false
        }
        
        selectedFontButton = sender
        selectedFontButton?.isSelected = true
        
        let f = self.availableFonts[sender.tag]
        self.delegate.setStyle(.fontFamily, f.fontFamily)
    }
}

public class TICFontDetailsPanelView : TICFormatPanelView, SBFontFormatDelegate
{
    @IBOutlet weak var lineHeightStepper: UIStepper!
    @IBOutlet weak var letterSpacingStepper: UIStepper!
    @IBOutlet weak var lineHeightLabel: UILabel!
    @IBOutlet weak var letterSpacingLabel: UILabel!
    
    var lineHeight : Int = 25
    var letterSpacing : Int = 0
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatLabel(lineHeightLabel)
        TICConfig.instance.theme.formatLabel(letterSpacingLabel)
        
        TICConfig.instance.theme.formatControl(lineHeightStepper)
        TICConfig.instance.theme.formatControl(letterSpacingStepper)
        
        lineHeightLabel.text = TICConfig.instance.locale.lineHeight
        letterSpacingLabel.text = TICConfig.instance.locale.letterSpacing
    }
    
    @IBAction func handleLetterSpacingValueChanged(_ sender: UIStepper) {
        
        letterSpacing = Int(sender.value)
        let ls = String(letterSpacing) + "px"
        self.delegate.setStyle(.letterSpacing, ls)
    }
    
    @IBAction func handleLineHeightValueChanged(_ sender: UIStepper) {
        
        lineHeight = Int(sender.value)
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh)
    }
    
    public func setLineHeightFromFontSize(_ size : Int) {
        
        lineHeight = size + 10
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh)
        
        lineHeightStepper.value = Double(lineHeight)
    }
}
