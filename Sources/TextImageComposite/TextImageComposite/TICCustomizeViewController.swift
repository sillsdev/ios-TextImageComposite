//
//  TICCustomizeViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/6/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public enum Alignment: Int {
    case left = 100
    case center = 101
    case right = 102
    
    func stringValue() -> String {
        switch self {
        case .center:
            return "center"
        case .right:
            return "right"
        default:
            return "left"
        }
    }
}

public enum CSSProperty: String {
    case textAlign = "text-align"
    case fontSize = "font-size"
    case color = "color"
    case fontFamily = "font-family"
    case fontStyle = "font-style"
    case fontWeight = "font-weight"
    case lineHeight = "line-height"
    case letterSpacing = "letter-spacing"
    case opacity = "opacity"
    case marginTop = "margin-top"
    case marginLeft = "margin-left"
    case marginRight = "margin-right"
    case textShadow = "text-shadow"
}

extension TICCustomizeViewController : TICFormatDelegate {
    
    public func setStyle(_ property : CSSProperty, _ value : String, _ section : TextSection) {
        switch section {
        case .text:
            let js = "setStyleText('\(property.rawValue)', '\(value)');"
            self.webView.stringByEvaluatingJavaScript(from: js)
        case .reference:
            let js = "setStyleReference('\(property.rawValue)', '\(value)');"
            self.webView.stringByEvaluatingJavaScript(from: js)
        case .both:
            let js = "setStyleText('\(property.rawValue)', '\(value)');"
            self.webView.stringByEvaluatingJavaScript(from: js)
            let js2 = "setStyleReference('\(property.rawValue)', '\(value)');"
            self.webView.stringByEvaluatingJavaScript(from: js2)
        }
    }
    
    public func setBodyStyle(_ property : CSSProperty, _ value : String) {
        //print("\(property) - \(value)")
        let js = "setBodyStyle('\(property.rawValue)', '\(value)');"
        self.webView.stringByEvaluatingJavaScript(from: js)
    }
    
    public func setImageBlur(_ alpha: CGFloat) {
        self.imageView.addBlur(alpha)
    }
    
    public func showFontDetails() {
        self.panelContainerView.addSubview(self.fontDetailsView)
    }
    
    public func showColorDetails() {
        self.panelContainerView.addSubview(self.colorDetailsView)
    }
    
    public func showMargins() {
        self.panelContainerView.addSubview(self.marginsView)
    }
}

public class TICCustomizeViewController : UIViewController
{
    @IBOutlet weak var imageView: BlurredImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var compositeView: UIView!
    @IBOutlet weak var toolbarDividersView: UIView!
    @IBOutlet weak var fontButton: UIButton!
    
    var fontSizeView: TICFontAttributesPanelView!
    var referenceSizeView: TICReferenceFontPanelView!
    var fontDetailsView: TICFontDetailsPanelView!
    var colorView: TICColorPanelView!
    var colorDetailsView: TICColorPickerPanelView!
    var extrasView: TICExtrasPanelView!
    var marginsView: TICMarginsPanelView!
    var alignmentView: TICAlignmentPanelView!
    var fontView: TICFontPanelView!
    var shadowView: TICTextShadowPanelView!
    
    @IBOutlet weak var panelContainerView: UIView!
    
    @IBOutlet var toolbarButtons: [UIButton]!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var compositeImage: UIImage?
    var fontSize: Int = 15
    var selectedToolbarButton: UIButton? = nil

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.saveButton.title = TICConfig.instance.locale.save
        
        //using empty string to remove default `Back` text on NavigationBar back item
        self.navigationItem.title = " "//TICConfig.instance.locale.chooseImage
        
        let request = URLRequest(url: TICConfig.instance.bundle.url(forResource: "composite", withExtension: "html")!)
        
        self.webView.loadRequest(request)
        
        self.imageView.image = TICConfig.instance.selectedImage
        
        self.setupEditorPanels()
        self.setupToolbarButtons()
        
        toolbarDividersView.subviews.forEach {
            $0.backgroundColor = TICConfig.instance.theme.highlightColor
        }
    }
    
    func setupEditorPanels()
    {
        var panels: [TICFormatPanelView] = []

        let f = self.panelContainerView.bounds
        self.alignmentView = TICAlignmentPanelView(frame: f)
        self.marginsView = TICMarginsPanelView(frame: f)
        self.extrasView = TICExtrasPanelView(frame: f)
        self.colorView = TICColorPanelView(frame: f)
        self.colorDetailsView = TICColorPickerPanelView(frame: f)
        self.fontView = TICFontPanelView(frame: f)
        self.fontSizeView = TICFontAttributesPanelView(frame: f)
        self.referenceSizeView = TICReferenceFontPanelView(frame: f)
        self.fontDetailsView = TICFontDetailsPanelView(frame: f)
        self.shadowView = TICTextShadowPanelView(frame: f)

        panels.append(self.alignmentView)
        panels.append(self.marginsView)
        panels.append(self.extrasView)
        panels.append(self.colorView)
        panels.append(self.colorDetailsView)
        panels.append(self.fontDetailsView)
        panels.append(self.fontSizeView)
        panels.append(self.referenceSizeView)
        panels.append(self.shadowView)
        panels.append(self.fontView) // Last appended is view displayed on startup
   
        panels.forEach {
            self.panelContainerView.addSubview($0)
            $0.constrainToFillSuperview()
            $0.delegate = self
        }
        
        fontView.setAvailableFonts(fonts: TICConfig.instance.fonts)
        fontView.fontDelegate = fontDetailsView
        fontSizeView.fontDelegate = fontDetailsView
        colorDetailsView.colorDelegate = colorView
        
        self.view.addSubview(self.panelContainerView)
    }
    
    func setupToolbarButtons() {
        var i = 0
        for btn : UIButton in self.toolbarButtons {
             if (btn == fontButton) {
                self.selectedToolbarButton = btn
                btn.isSelected = true
            }
            TICConfig.instance.theme.formatToolbarButton(btn)

            btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.addTarget(self, action: #selector(handleToolbarButtonTap(_:)), for: .touchUpInside)
            
            i += 1
        }
    }

    @IBAction func handleSaveButtonTap(_ sender: Any) {
        
        compositeImage = UIImage.init(view: self.compositeView)
        if let img = compositeImage
        {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
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
    
    @IBAction func handleToolbarButtonTap(_ sender: UIButton) {
        
        if let btn = selectedToolbarButton {
            btn.isSelected = false
            TICConfig.instance.theme.formatToolbarButton(btn)
        }
        
        sender.isSelected = true
        TICConfig.instance.theme.formatToolbarButton(sender)
        
        selectedToolbarButton = sender
    }
    
    @IBAction func handleFontButtonTap(_ sender: Any) {
        
        self.panelContainerView.addSubview(self.fontView)
    }
    
    @IBAction func handleFontSizeButtonTap(_ sender: Any) {
        
        self.panelContainerView.addSubview(self.fontSizeView)
    }
    @IBAction func handleColorButtonTap(_ sender: Any) {
        
        self.panelContainerView.addSubview(self.colorView)
    }
    
    @IBAction func handleAlignmentButtonTap(_ sender: Any) {
        
        self.panelContainerView.addSubview(self.alignmentView)
    }
    
    @IBAction func handleExtrasButtonTap(_ sender: Any) {
        
        self.panelContainerView.addSubview(self.extrasView)
    }
    
    @IBAction func handleReferenceFontButtonTap(_ sender: Any) {
        self.panelContainerView.addSubview(self.referenceSizeView)
    }
    
    @IBAction func handleTextShadowTap(_ sender: Any) {
        self.panelContainerView.addSubview(self.shadowView)
    }
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowComposite" {
            if let vc = segue.destination as? TICShareViewController {
                vc.compositeImage = self.compositeImage
            }
        }
    }
}

extension TICCustomizeViewController : UIWebViewDelegate {
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        let js = "reset('\(TICConfig.instance.text)', '\(TICConfig.instance.reference)')"
        self.webView.stringByEvaluatingJavaScript(from: js)
        self.setStyle(.textAlign, Alignment.center.stringValue(), .both )
    }
}
