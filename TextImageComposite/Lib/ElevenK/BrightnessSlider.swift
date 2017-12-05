//
//  BrightnessSlider.swift
//
//  Created by Jacob Bullock on 10/14/17.
//  Copyright © 2017 Eleven K. All rights reserved.
//

import Foundation
import UIKit
@objc protocol brightnessDelegate{
    @objc optional func brightnessSelected(_ brightness:CGFloat)
}


public class BrightnessSlider: UIView {
    
    var swatch: UIView!
    var currentSelectionY: CGFloat = 0;
    var selectedColor: UIColor!
    var delegate: ColorPickerDelegate!
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 1.0
    
    public var brightness: CGFloat = 1.0
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public func commonInit() {
        
        swatch = UIView(frame: CGRect(x: (self.frame.size.width / 2) - 10, y: 0, width: 20, height: 20))
        swatch.backgroundColor = .red
        swatch.layer.borderWidth = 3
        swatch.layer.borderColor = UIColor.lightGray.cgColor
        swatch.layer.cornerRadius =  10
        swatch.layer.masksToBounds = true
        
        self.addSubview(swatch)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override public func draw(_ rect: CGRect) {
        
        UIColor.black.set()

        //draw central bar over it
        let width = Int(self.frame.size.width)
        let height = Int(self.frame.size.height)
        for j in 0 ..< height {
            UIColor(hue: hue, saturation: saturation,
                    brightness:CGFloat(Float(1 - (Float(j) / Float(height)))),
                    alpha: 1.0).set()
            let temp = CGRect(x: CGFloat(0), y: CGFloat(j), width: CGFloat(width), height: CGFloat(1.0))
            UIRectFill(temp);
        }
    }
    
    func setColor(_ color : UIColor)
    {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            //currentSelectionX = CGFloat (hue * self.frame.size.height);
            self.hue = hue
            self.saturation = saturation
            //print("setColor: \(color)")
            self.setNeedsDisplay()

            selectedColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
            swatch.backgroundColor = selectedColor
            self.delegate.pickedColor!(selectedColor)
        }
       
        //self.delegate.pickedColor!(selectedColor)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch =  touches.first
        updateColor(touch!)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch =  touches.first
        updateColor(touch!)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch =  touches.first
        updateColor(touch!)
    }
    
    func updateColor(_ touch: UITouch) {
        
        currentSelectionY = (touch.location(in: self).y)
        
        if(currentSelectionY < 0) {
            currentSelectionY = 0
        } else if(currentSelectionY > self.frame.size.height) {
            currentSelectionY = self.frame.size.height
        }
        
        self.brightness = 1 - (currentSelectionY / self.frame.size.height)
        selectedColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        self.delegate.pickedColor!(selectedColor)
        self.setNeedsDisplay()
        
        var f = swatch.frame
        f.origin.y = currentSelectionY - swatch.frame.size.height / 2
        
        if(f.origin.x > self.frame.size.width - 20) {
            f.origin.x = self.frame.size.width - 20
        } else if(f.origin.x < 0) {
            f.origin.x = 0
        }
        
        if(f.origin.y > self.frame.size.height - 20) {
            f.origin.y = self.frame.size.height - 20
        } else if(f.origin.y < 0) {
            f.origin.y = 0
        }
        
        swatch.frame = f
        swatch.backgroundColor =  selectedColor
    }
}
