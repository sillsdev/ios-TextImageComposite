//
//  BrightnessSlider.swift
//
//  Created by Jacob Bullock on 10/14/17.
//  Copyright © 2017 Eleven K. All rights reserved.
//

import UIKit
@objc protocol ColorPickerDelegate{
    @objc optional func pickedColor(_ color:UIColor)
}


class ColorPicker: UIView
{
    var currentSelectionX: CGFloat = 0;
    var currentSelectionY: CGFloat = 0;
    var selectedColor: UIColor!
    var delegate: ColorPickerDelegate!
    var swatch: UIView!
    
    public var brightnessSlider : BrightnessSlider!
    
    var hue: CGFloat = 0.0
    var sat : CGFloat = 1.0

    public var brightness : CGFloat
    {
        set
        {
            selectedColor = UIColor(hue: hue, saturation: sat, brightness: newValue, alpha: 1.0)
            //self.delegate.pickedColor!(self.brightnessSlider.selectedColor)
        }
        get
        {
            return self.brightnessSlider.brightness
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        brightness = 1.0
        commonInit()
    }
    
    public func commonInit()
    {
        swatch = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        swatch.backgroundColor = .red
        swatch.layer.borderWidth = 3
        swatch.layer.borderColor = UIColor.lightGray.cgColor
        swatch.layer.cornerRadius =  10
        swatch.layer.masksToBounds = true
        
        self.addSubview(swatch)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        UIColor.black.set()
        var tempYPlace = self.currentSelectionX;
        if (tempYPlace < CGFloat (0.0)) {
            tempYPlace = CGFloat (0.0);
        } else if (tempYPlace >= self.frame.size.width) {
            tempYPlace = self.frame.size.width - 1.0;
        }
        
        let temp = CGRect(x: 0.0, y: tempYPlace, width: 1.0, height: self.frame.size.height);
        UIRectFill(temp);
        
        //draw central bar over it
        let width = Int(self.frame.size.width)
        let height = Int(self.frame.size.height)
        for i in 0 ..< width {
            for j in 0 ..< height {
                UIColor(hue:CGFloat (i)/self.frame.size.width, saturation: CGFloat(Float(1 - (Float(j) / Float(height)))), brightness: 1.0, alpha: 1.0).set()
                let temp = CGRect(x: CGFloat (i), y: CGFloat(j), width: 1.0, height: 1.0);
                UIRectFill(temp);
            }
        }
    }
    
    //Changes the selected color, updates the UI, and notifies the delegate.
    func selectedColor(_ sColor: UIColor)
    {
        if (sColor != selectedColor)
        {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            if sColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
                currentSelectionX = CGFloat (hue * self.frame.size.height);
                self.setNeedsDisplay();
                
            }
            selectedColor = sColor
            self.delegate.pickedColor!(selectedColor)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch =  touches.first
        updateColor(touch!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch =  touches.first
        updateColor(touch!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch =  touches.first
        updateColor(touch!)
    }
    
    func updateColor(_ touch: UITouch)
    {
        currentSelectionX = (touch.location(in: self).x)
        currentSelectionY = (touch.location(in: self).y)
        
        if(currentSelectionY < 0)
        {
            currentSelectionY = 0
        }
        else if(currentSelectionY > self.frame.size.height)
        {
            currentSelectionY = self.frame.size.height
        }
        
        if(currentSelectionX < 0)
        {
            currentSelectionX = 0
        }
        else if(currentSelectionX > self.frame.size.width)
        {
            currentSelectionX = self.frame.size.width
        }
        
        self.hue = (currentSelectionX / self.frame.size.width)
        self.sat = 1 - (currentSelectionY / self.frame.size.height)
        selectedColor = UIColor(hue: hue, saturation: sat, brightness: 1.0, alpha: 1.0)
        //
        self.brightnessSlider.setColor( selectedColor )
        self.setNeedsDisplay()
        
        var f = swatch.frame
        f.origin.x = currentSelectionX - swatch.frame.size.width / 2
        f.origin.y = currentSelectionY - swatch.frame.size.height / 2
        if(f.origin.x > self.frame.size.width - 20)
        {
            f.origin.x = self.frame.size.width - 20
        }
        else if(f.origin.x < 0)
        {
            f.origin.x = 0
        }
        if(f.origin.y > self.frame.size.height - 20)
        {
            f.origin.y = self.frame.size.height - 20
        }
        else if(f.origin.y < 0)
        {
            f.origin.y = 0
        }
        swatch.frame = f
        
        swatch.backgroundColor =  selectedColor
        
        //self.delegate.pickedColor!(self.brightnessSlider.selectedColor)
    }
}
