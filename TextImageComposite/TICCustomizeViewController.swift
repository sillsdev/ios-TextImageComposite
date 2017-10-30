//
//  TICCustomizeViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/6/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

enum Alignment: Int
{
    case left = 100
    case center = 101
    case right = 102
    case justify = 103
    
    func stringValue() -> String
    {
        switch self {
        case .center:
            return "center"
        case .right:
            return "right"
        case .justify:
            return "justify"
        default:
            return "left"
        }
    }
}

enum CSSProperty: String
{
    case textAlign = "text-align"
    case fontSize = "font-size"
    case color = "color"
    case fontFamily = "font-family"
    case lineHeight = "line-height"
    case letterSpacing = "letter-spacing"
    case opacity = "opacity"
    case marginTop = "margin-top"
    case marginLeft = "margin-left"
    case marginRight = "margin-right"
}

protocol TICFormatDelegate {
    func setStyle(_ property : CSSProperty, _ value : String)
    func setBodyStyle(_ property : CSSProperty, _ value : String)
    
    func setImageBlur(_ alpha: CGFloat)
    func showFontDetails()
    func showColorDetails()
    func showMargins()
}

protocol SBFontFormatDelegate
{
    func setLineHeightFromFontSize(_ size : Int)
}

protocol SBColorFormatDelegate
{
    func customColorWasSelected()
}

class TICFormatPanelView : UIView
{
    public var delegate: TICFormatDelegate!
    public var fontDelegate: SBFontFormatDelegate?
    public var colorDelegate: SBColorFormatDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public func commonInit()
    {
        TICConfig.instance.theme.formatView(self)
    }
}

class TICAlignmentPanelView : TICFormatPanelView
{
    @IBAction func handleJustificationButtonTap(_ sender: UIButton)
    {
        self.delegate.setStyle(.textAlign, (Alignment.init(rawValue: sender.tag)?.stringValue())! )
    }
    
    @IBAction func handleMarginsButtonTap(_ sender: UIButton)
    {
        self.delegate.showMargins()
    }
}

class TICMarginsPanelView : TICFormatPanelView
{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet var sliders : [UISlider]!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for slider : UISlider in sliders
        {
            TICConfig.instance.theme.formatControl(slider)
        }
        
        topLabel.text = TICConfig.instance.locale.top
        leftLabel.text = TICConfig.instance.locale.left
        rightLabel.text = TICConfig.instance.locale.right
        
        TICConfig.instance.theme.formatLabel(topLabel)
        TICConfig.instance.theme.formatLabel(leftLabel)
        TICConfig.instance.theme.formatLabel(rightLabel)
    }
    
    @IBAction func handleTopSliderValueChanged(_ sender: UISlider)
    {
        self.delegate.setBodyStyle(.marginTop, String(Int(300 * sender.value))+"px" )
    }
    
    @IBAction func handleLeftSliderValueChanged(_ sender: UISlider)
    {
        self.delegate.setBodyStyle(.marginLeft, String(Int(300 * sender.value))+"px" )
    }
    
    @IBAction func handleRightSliderValueChanged(_ sender: UISlider)
    {
        self.delegate.setBodyStyle(.marginRight, String(Int(300 * sender.value))+"px" )
    }
}

class TICFontPanelView : TICFormatPanelView
{
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontScrollView: UIScrollView!
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    var selectedFontButton : UIButton? = nil
    var availableFonts : [TICFont] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatControl(fontSizeSlider)
        TICConfig.instance.theme.formatLabel(sizeLabel)
        TICConfig.instance.theme.formatLabel(fontSizeLabel)
        
        sizeLabel.text = TICConfig.instance.locale.size
    }
    
    @IBAction func handleTextSizeSliderValueChanged(_ sender: UISlider)
    {
        let pointSize = String(Int(sender.value)) + "pt"
        self.delegate.setStyle(.fontSize, pointSize)
        self.fontDelegate?.setLineHeightFromFontSize(Int(sender.value))
        fontSizeLabel.text = pointSize
    }
    
    @IBAction func handleFontDetailsButtonTap(_ sender: Any)
    {
        self.delegate.showFontDetails()
    }
    
    func setAvailableFonts(fonts : [TICFont])
    {
        availableFonts = fonts
        
        var x : Int = 20
        var i : Int = 0
        for f : TICFont in fonts
        {
            let button = UIButton(type: .custom)
            let str : NSString = f.title as NSString
            let font = UIFont(name: f.fontFamily, size: 17) //should add if let
            if(i == 0)
            {
                button.isSelected = true
                selectedFontButton = button
            }
            button.tag = i
            button .setTitle(f.title, for: .normal)
            button.setTitleColor(TICConfig.instance.theme.fontItemColor, for: .normal)
            button.setTitleColor(TICConfig.instance.theme.fontItemSelectedColor, for: .selected)
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
    
    func handleFontButtonTap(_ sender: UIButton)
    {
        if let btn = selectedFontButton
        {
            btn.isSelected = false
        }
        
        selectedFontButton = sender
        selectedFontButton?.isSelected = true
        
        let f = self.availableFonts[sender.tag]
        self.delegate.setStyle(.fontFamily, f.fontFamily)
    }
}

class TICFontDetailsPanelView : TICFormatPanelView, SBFontFormatDelegate
{
    
    @IBOutlet weak var lineHeightStepper: UIStepper!
    @IBOutlet weak var letterSpacingStepper: UIStepper!
    @IBOutlet weak var lineHeightLabel: UILabel!
    @IBOutlet weak var letterSpacingLabel: UILabel!
    
    var lineHeight : Int = 25
    var letterSpacing : Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatLabel(lineHeightLabel)
        TICConfig.instance.theme.formatLabel(letterSpacingLabel)
        
        TICConfig.instance.theme.formatControl(lineHeightStepper)
        TICConfig.instance.theme.formatControl(letterSpacingStepper)
        
        lineHeightLabel.text = TICConfig.instance.locale.lineHeight
        letterSpacingLabel.text = TICConfig.instance.locale.letterSpacing
    }
    
    @IBAction func handleLetterSpacingValueChanged(_ sender: UIStepper)
    {
        letterSpacing = Int(sender.value)
        let ls = String(letterSpacing) + "px"
        self.delegate.setStyle(.letterSpacing, ls)
    }
    
    @IBAction func handleLineHeightValueChanged(_ sender: UIStepper)
    {
        lineHeight = Int(sender.value)
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh)
    }
    
    func setLineHeightFromFontSize(_ size : Int)
    {
        lineHeight = size + 10
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh)
        
        lineHeightStepper.value = Double(lineHeight)
    }
}

class TICExtrasPanelView : TICFormatPanelView
{
    @IBOutlet weak var blurLabel : UILabel!
    @IBOutlet weak var blurSlider : UISlider!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatLabel(blurLabel)
        TICConfig.instance.theme.formatControl(blurSlider)
        blurLabel.text = TICConfig.instance.locale.blur
    }
    
    @IBAction func handleBlurSliderValueChanged(_ sender: UISlider)
    {
        self.delegate.setImageBlur(CGFloat(sender.value))
    }
}

class TICColorPanelView : TICFormatPanelView, SBColorFormatDelegate
{
    @IBOutlet weak var whiteButton : UIButton!
    @IBOutlet weak var blackButton : UIButton!
    @IBOutlet weak var opacityLabel : UILabel!
    @IBOutlet weak var opacitySlider : UISlider!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.whiteButton.isSelected = true
        TICConfig.instance.theme.formatLabel(opacityLabel)
        TICConfig.instance.theme.formatControl(opacitySlider)
        opacityLabel.text = TICConfig.instance.locale.opacity
        whiteButton.layer.borderColor = UIColor.darkGray.cgColor
        whiteButton.layer.borderWidth = 1
    }
    
    @IBAction func handleBlackButtonTap(_ sender: UIButton)
    {
        self.delegate.setStyle(.color, "black")
        sender.isSelected = true
        whiteButton.isSelected = false
    }
    
    @IBAction func handleWhiteButtonTap(_ sender: UIButton)
    {
        self.delegate.setStyle(.color, "white")
        sender.isSelected = true
        blackButton.isSelected = false
    }
    
    @IBAction func handleColorDetailsButtonTap(_ sender: UIButton)
    {
        self.delegate.showColorDetails()
    }
    
    @IBAction func handleOpacitySliderValueChanged(_ sender: UISlider)
    {
        self.delegate.setStyle(.opacity, String(sender.value) )
    }
    
    func customColorWasSelected()
    {
        blackButton.isSelected = false
        whiteButton.isSelected = false
    }
}

class TICColorPickerPanelView : TICFormatPanelView, ColorPickerDelegate
{
    @IBOutlet weak var colorPicker : ColorPicker!
    @IBOutlet weak var brightnessSlider : BrightnessSlider!
    
    override public func commonInit() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorPicker.delegate = self
        brightnessSlider.delegate = self
        self.colorPicker.brightnessSlider = brightnessSlider
    }
    
    func pickedColor(_ color: UIColor)
    {
        self.delegate.setStyle(.color, color.toHex()!)
    }
}

extension TICCustomizeViewController : TICFormatDelegate
{
    func setStyle(_ property : CSSProperty, _ value : String)
    {
        //print("\(property) - \(value)")
        let js = "setStyle('\(property.rawValue)', '\(value)');"
        self.webView.stringByEvaluatingJavaScript(from: js)
    }
    
    func setBodyStyle(_ property : CSSProperty, _ value : String)
    {
        //print("\(property) - \(value)")
        let js = "setBodyStyle('\(property.rawValue)', '\(value)');"
        self.webView.stringByEvaluatingJavaScript(from: js)
    }
    
    func setImageBlur(_ alpha: CGFloat)
    {
        self.imageView.addBlur(alpha)
    }
    
    func showFontDetails()
    {
        self.view.addSubview(self.fontDetailsView)
    }
    
    func showColorDetails() {
        self.view.addSubview(self.colorDetailsView)
    }
    
    func showMargins() {
        self.view.addSubview(self.marginsView)
    }
}

class TICCustomizeViewController : UIViewController
{
    @IBOutlet weak var imageView: BlurredImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var compositeView: UIView!
    
    @IBOutlet weak var fontSizeView: TICFontPanelView!
    @IBOutlet weak var fontDetailsView: TICFontDetailsPanelView!
    @IBOutlet weak var colorView: TICColorPanelView!
    @IBOutlet weak var colorDetailsView: TICColorPickerPanelView!
    @IBOutlet weak var alignmentView: TICAlignmentPanelView!
    @IBOutlet weak var extrasView: TICExtrasPanelView!
    @IBOutlet weak var marginsView: TICMarginsPanelView!
    
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet var toolbarButtons: [UIButton]!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    //public var config : TICConfig!
    var compositeImage : UIImage?
    var fontSize : Int = 15
    var selectedToolbarButton : UIButton? = nil

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.saveButton.title = TICConfig.instance.locale.save
        
        self.navigationItem.title = TICConfig.instance.locale.chooseImage
        
        let request = URLRequest(url: Bundle.main.url(forResource: "composite", withExtension: "html")!)
        
        self.webView.loadRequest(request)
        
        self.imageView.imageURL = TICConfig.instance.imageUrl
        
        self.setupEditorPanels()
        self.setupActionButtons()
        self.setupToolbarButtons()
        
        self.fontSizeView.setAvailableFonts(fonts: TICConfig.instance.fonts)
        
        self.view.addSubview(fontSizeView)
    }
    
    func setupEditorPanels()
    {
        fontSizeView.delegate = self
        fontDetailsView.delegate = self
        alignmentView.delegate = self
        colorView.delegate = self
        colorDetailsView.delegate = self
        extrasView.delegate = self
        marginsView.delegate = self
        
        fontSizeView.fontDelegate = fontDetailsView
        colorDetailsView.colorDelegate = colorView
        
        //self.matchContraints(colorView, fontSizeView)
        //self.matchContraints(alignmentView, fontSizeView)
        //self.matchContraints(extrasView, fontSizeView)
        //self.matchContraints(fontDetailsView, fontSizeView)
    }
    
    func setupToolbarButtons()
    {
        var i = 0
        for btn : UIButton in self.toolbarButtons
        {
            if(i == 0)
            {
                self.selectedToolbarButton = btn
                btn.isSelected = true
            }
            TICConfig.instance.theme.formatToolbarButton(btn)
            
            btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            
            btn.addTarget(self, action: #selector(handleToolbarButtonTap(_:)), for: .touchUpInside)
            
            i += 1
        }
    }
    
    func setupActionButtons()
    {
        for btn : UIButton in self.actionButtons
        {
            btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = .black
        }
    }
    
    //This is a convenience method so that we don't have to manage autolayout for all of the panels in IB
    func matchContraints(_ from: UIView, _ to: UIView)
    {
        from.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: from, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: from, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: from, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: from, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }

    @IBAction func handleSaveButtonTap(_ sender: Any)
    {
        compositeImage = UIImage.init(view: self.compositeView)
        if let img = compositeImage
        {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            /*
            let ac = UIAlertController(title: "Saved!", message: "Image saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
             */
            self.performSegue(withIdentifier: "ShowComposite", sender: self)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    //MARK: - Toolbar
    
    @IBAction func handleToolbarButtonTap(_ sender: UIButton)
    {
        if let btn = selectedToolbarButton
        {
            btn.isSelected = false
            TICConfig.instance.theme.formatToolbarButton(btn)
        }
        
        sender.isSelected = true
        TICConfig.instance.theme.formatToolbarButton(sender)
        
        selectedToolbarButton = sender
        
    }
    
    @IBAction func handleFontButtonTap(_ sender: Any)
    {
        self.view.addSubview(self.fontSizeView)
    }
    
    @IBAction func handleColorButtonTap(_ sender: Any)
    {
        self.view.addSubview(self.colorView)
    }
    
    @IBAction func handleAlignmentButtonTap(_ sender: Any)
    {
        self.view.addSubview(self.alignmentView)
    }
    
    @IBAction func handleExtrasButtonTap(_ sender: Any)
    {
        self.view.addSubview(self.extrasView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowComposite"
        {
            if let vc = segue.destination as? TICShareViewController
            {
                vc.compositeImage = self.compositeImage
            }
        }
    }
}

extension TICCustomizeViewController : UIWebViewDelegate
{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let js = "reset('\(TICConfig.instance.text)', '\(TICConfig.instance.reference)')"
        self.webView.stringByEvaluatingJavaScript(from: js)
    }
}
