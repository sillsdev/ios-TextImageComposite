//
//  UIView+Layout.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    public func constrainToFillContainer(_ container: UIView) {

        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Using older syntax to support iOS 8
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    public func constrainToFillSuperview() {
        
        if let v = self.superview {
            self.constrainToFillContainer(v)
        }
    }
}
