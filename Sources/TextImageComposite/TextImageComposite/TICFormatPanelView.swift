//
//  TICPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public enum TextSection {
    case text
    case reference
    case both
}
public protocol TICFormatDelegate {
    func setStyle(_ property : CSSProperty, _ value : String, _ section : TextSection)
    func setBodyStyle(_ property : CSSProperty, _ value : String)
    
    func setImageBlur(_ alpha: CGFloat)
    func showFontDetails()
    func showColorDetails()
    func showMargins()
}

public protocol SBFontFormatDelegate
{
    func setLineHeightFromFontSize(_ size : Int)
}

public protocol SBColorFormatDelegate
{
    func customColorWasSelected()
}

public class TICFormatPanelView : UIView
{
    @IBOutlet var actionButtons: [UIButton]?
    @IBOutlet var selectableButtons: [UIButton]?
    @IBOutlet weak var closeButton : UIButton?
    
    var view: UIView!
    public var delegate: TICFormatDelegate!
    public var fontDelegate: SBFontFormatDelegate?
    public var colorDelegate: SBColorFormatDelegate?
    
    var selectedButton : UIButton?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public func commonInit() {
        
        TICConfig.instance.theme.formatView(self)
        
        view = loadNib()
        addSubview(view)
        view.constrainToFillSuperview()
        
        setupActionButtons()
        setupSelectableButtons()
        
        if let btn = self.closeButton {
            
            btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = TICConfig.instance.theme.accentColor
        }
    }
    
    func loadNib() -> UIView {
        
        let bundle = TICConfig.instance.bundle
        let nibName = type(of: self).description().components(separatedBy: ".").last!

        let nib = UINib(nibName: nibName, bundle: bundle)

        if let _ = bundle.path(forResource: nibName, ofType: "nib") {
            if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
                return view
            }
        }
        
        return UIView()
    }
    
    func setupActionButtons() {
        
        if let actionButtons = self.actionButtons {
            for btn : UIButton in actionButtons {
                btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                btn.tintColor = TICConfig.instance.theme.accentColor
                btn.backgroundColor = TICConfig.instance.theme.buttonBackgroundColor
            }
        }
    }
    
    func setupSelectableButtons() {
        
        if let selectableButtons = self.selectableButtons {
            for btn : UIButton in selectableButtons {
                btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                btn.tintColor = TICConfig.instance.theme.accentColor
                
                btn.addTarget(self, action: #selector(handleSelectableButtonTap(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func handleSelectableButtonTap(_ sender: UIButton) {
        
        if let btn = self.selectedButton {
            btn.isSelected = false
            btn.tintColor = TICConfig.instance.theme.accentColor
        }
        
        sender.isSelected = true
        sender.tintColor = TICConfig.instance.theme.tintColor
        selectedButton = sender
    }
    
    @IBAction func handleCloseButtonTap(_ sender: UIButton) {
        
        self.superview?.insertSubview(self, at: 0)
    }
    
    func flipButtonSelected(button: UIButton, attribute: CSSProperty, selectedValue: String, unselectedValue: String, section: TextSection) {
        if button.isSelected {
            button.isSelected = false
            button.tintColor = TICConfig.instance.theme.accentColor
            self.delegate.setStyle(attribute, unselectedValue, section)
        } else {
            button.isSelected = true
            button.tintColor = TICConfig.instance.theme.tintColor
            self.delegate.setStyle(attribute, selectedValue, section)
        }
    }
}
