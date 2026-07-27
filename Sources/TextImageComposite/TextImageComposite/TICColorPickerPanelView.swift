//
//  TICColorPickerPanelView.swift
//  TextImageComposite
//
//  Created by David Moore on 7/27/26.
//


import Foundation
import UIKit

public class TICColorPickerPanelView : TICBasePanelView {
    
    @IBOutlet weak var colorPicker : ColorPicker!
    @IBOutlet weak var brightnessSlider : BrightnessSlider!
    var colorPickerDelegate : ColorPickerDelegate?
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        colorPicker.delegate = colorPickerDelegate
        brightnessSlider.delegate = colorPickerDelegate
        self.colorPicker.brightnessSlider = brightnessSlider
    }
    func setDelegate(_ delegate: ColorPickerDelegate) {
        self.colorPickerDelegate = delegate
        self.brightnessSlider?.delegate = delegate
    }
}
