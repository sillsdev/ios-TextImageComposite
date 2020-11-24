//
//  TICAlignmentPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICAlignmentPanelView : TICFormatPanelView, SBFontFormatDelegate
{

    @IBOutlet weak var lineSpacingSlider: UISlider!
    @IBOutlet weak var textWidthSlider: UISlider!
    
    @IBOutlet weak var leftMarginSlider: UISlider!
    
    var lineHeight : Int = 25
    var imageWidth : CGFloat = 320 {
        didSet {
            divWidth = Int(imageWidth)
            if textWidthSlider != nil {
                textWidthSlider.maximumValue = Float(imageWidth)
                textWidthSlider.value = Float(imageWidth)
            }
            if leftMarginSlider != nil {
                leftMarginSlider.maximumValue = Float(imageWidth / 2) - 20
                leftMarginSlider.minimumValue = Float(-imageWidth / 2) - 20
                leftMarginSlider.value = 0
            }
        }
    }
    var divWidth : Int = 320
    var divLeftMargin : Int = 0
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let btn = viewWithTag(101) as? UIButton {
            self.handleSelectableButtonTap(btn)
        }
        TICConfig.instance.theme.formatControl(textWidthSlider)
        TICConfig.instance.theme.formatControl(lineSpacingSlider)
        lineSpacingSlider.value = 25
        textWidthSlider.maximumValue = Float(imageWidth)
        textWidthSlider.minimumValue = 100
        textWidthSlider.value = Float(imageWidth)
        divLeftMargin = 0
        divWidth = Int(imageWidth)
    }
    
    @IBAction func lineSpacingValueChanged(_ sender: UISlider) {
        lineHeight = Int(sender.value)
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh, .both)
    }
    

    @IBAction func textWidthValueChanged(_ sender: UISlider) {
        let newDivWidth = Int(sender.value)
        setDivWidth(newWidth: newDivWidth)
        leftMarginSlider.value = Float(divLeftMargin)
    }
    @IBAction func handleJustificationButtonTap(_ sender: UIButton) {
        
        self.delegate.setStyle(.textAlign, (Alignment(rawValue: sender.tag)?.stringValue())!, .both )
    }
    
    @IBAction func leftMarginSliderValueChanged(_ sender: UISlider) {
        setDivLeftMargin(newMargin: Int(sender.value))
    }
    
    
    // MARK: SBFontFormatDelegate
    public func setLineHeightFromFontSize(_ size : Int) {
        
        lineHeight = size + 10
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh, .both)
        
        lineSpacingSlider.value = Float(lineHeight)
    }
    public func getDivLeftMargin() -> Int {
        return divLeftMargin
    }
    public func setDivLeftMargin(newMargin: Int) {
        let maxAdjustment = (Int(imageWidth) - divWidth) / 2
        let minAdjustment = -maxAdjustment
        if (newMargin > maxAdjustment) {
            divLeftMargin = maxAdjustment
        } else if (newMargin < minAdjustment) {
            divLeftMargin = minAdjustment
        } else {
            divLeftMargin = newMargin
        }
        setAdjustedLeftMargin()
    }
    public func getDivWidth() -> Int {
        return divWidth
    }
    public func setDivWidth(newWidth: Int) {
        let maxDivWidth = (Int(imageWidth) - abs(divLeftMargin)) - 40
        if (newWidth < maxDivWidth) {
            divWidth = newWidth
        } else {
            divWidth = maxDivWidth
        }
        self.delegate.setStyle(.maxWidth, String(divWidth), .div)
        setAdjustedLeftMargin()
    }
    func setAdjustedLeftMargin() {
        let adjustment = (Int(imageWidth) - divWidth) / 2
        let newLeftMargin = divLeftMargin + adjustment
        self.delegate.setBodyStyle(.marginLeft, String(newLeftMargin)+"px" )
    }
}

public class TICMarginsPanelView : TICFormatPanelView {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet var sliders : [UISlider]!
    @IBOutlet weak var leftMarginSlider: UISlider!
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        for slider : UISlider in sliders
        {
            TICConfig.instance.theme.formatControl(slider)
        }
        leftMarginSlider.value = 0
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
        fontDelegate!.setDivLeftMargin(newMargin: Int(sender.value))
        //self.delegate.setBodyStyle(.marginLeft, String(Int(300 * sender.value))+"px" )
    }
    
    @IBAction func handleRightSliderValueChanged(_ sender: UISlider) {
        
        self.delegate.setBodyStyle(.marginRight, String(Int(300 * sender.value))+"px" )
    }
}
