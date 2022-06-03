//
//  TICAlignmentPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICAlignmentPanelView : TICBasePanelView, SBFontFormatDelegate
{

    @IBOutlet weak var lineSpacingSlider: UISlider!
    @IBOutlet weak var textWidthSlider: UISlider!
    
    var lineHeight : Int = 30
    var imageWidth : CGFloat = 320 {
        didSet {
            divWidth = Int(imageWidth * 75 / 100)
            if textWidthSlider != nil {
                textWidthSlider.maximumValue = Float(imageWidth)
                textWidthSlider.value = Float(imageWidth * 75 / 100)
            }
        }
    }
    var divWidth : Int = 320
    var divLeftMargin : Int = 0
    var divTopMargin : Int = 0
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let btn = viewWithTag(101) as? UIButton {
            self.handleSelectableButtonTap(btn)
        }
        TICConfig.instance.theme.formatControl(textWidthSlider)
        TICConfig.instance.theme.formatControl(lineSpacingSlider)
        lineSpacingSlider.value = 30
        textWidthSlider.maximumValue = Float(imageWidth)
        textWidthSlider.minimumValue = 100
        textWidthSlider.value = Float(imageWidth * 75 / 100)
        divLeftMargin = 0
        divTopMargin = 0
        divWidth = Int(imageWidth * 75 / 100)
    }
    
    @IBAction func lineSpacingValueChanged(_ sender: UISlider) {
        lineHeight = Int(sender.value)
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh, .both)
    }
    

    @IBAction func textWidthValueChanged(_ sender: UISlider) {
        let newDivWidth = Int(sender.value)
        setDivWidth(newWidth: newDivWidth)
    }
    @IBAction func handleJustificationButtonTap(_ sender: UIButton) {
        
        self.delegate.setStyle(.textAlign, (Alignment(rawValue: sender.tag)?.stringValue())!, .both )
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
    public func getDivTopMargin() -> Int {
        return divTopMargin
    }
    public func setDivTopMargin(newMargin: Int) {
        var divHeight = Int(delegate.getDivHeight()) - divTopMargin
        let maxIntHeight = Int(Float(imageWidth)) // ImageHeight = ImageWidth
        if (divHeight > maxIntHeight) {
            divHeight = maxIntHeight
        }
        let maxAdjustment =  maxIntHeight - divHeight
        var adjustment = newMargin > maxAdjustment ? maxAdjustment : newMargin
        adjustment = newMargin < 0 ? 0 : adjustment
        divTopMargin = adjustment
        if (divTopMargin > 0) {
            self.delegate.setBodyStyle(.marginTop, String(divTopMargin) + "px")
        }
    }
    public func setDivTopMarginCenter() {
        var divHeight = Int(delegate.getDivHeight())
        let maxIntHeight = Int(Float(imageWidth)) // ImageHeight = ImageWidth
        if (divHeight > maxIntHeight) {
            divHeight = maxIntHeight
        }
        let maxAdjustment =  maxIntHeight - divHeight
        let centerAdjustment = maxAdjustment / 2
        divTopMargin = centerAdjustment
        if (divTopMargin > 0) {
            self.delegate.setBodyStyle(.marginTop, String(divTopMargin) + "px")
        }
    }
    public func getDivWidth() -> Int {
        return divWidth
    }
    public func setDivWidth(newWidth: Int) {
        let maxDivWidth = (Int(imageWidth) - abs(divLeftMargin))
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
