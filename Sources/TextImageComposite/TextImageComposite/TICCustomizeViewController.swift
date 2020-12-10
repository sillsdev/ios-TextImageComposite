//
//  TICCustomizeViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/6/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import os.log

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
    case maxWidth = "max-width"
}

extension TICCustomizeViewController : TICFormatDelegate {
    
    public func setStyle(_ property : CSSProperty, _ value : String, _ section : TextSection) {
        switch section {
        case .text:
            let js = "setStyleText('\(property.rawValue)', '\(value)');"
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        case .reference:
            let js = "setStyleReference('\(property.rawValue)', '\(value)');"
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        case .both:
            let js = "setStyleText('\(property.rawValue)', '\(value)');"
            self.webView.evaluateJavaScript(js, completionHandler: nil)
            let js2 = "setStyleReference('\(property.rawValue)', '\(value)');"
            self.webView.evaluateJavaScript(js2, completionHandler: nil)
        case .div:
            let js = "setStyleDiv('\(property.rawValue)', '\(value)');"
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    public func setBodyStyle(_ property : CSSProperty, _ value : String) {
        //print("\(property) - \(value)")
        let js = "setBodyStyle('\(property.rawValue)', '\(value)');"
        self.webView.evaluateJavaScript(js, completionHandler: nil)
    }
    public func getDivHeight() -> CGFloat {
        let allHeight = TICCustomizeViewController.evaluateJavaScript("document.getElementById('all').clientHeight", webView: webView)
        let floatHeight = ((allHeight as? CGFloat) != nil ? allHeight as! CGFloat : 320)
        return floatHeight
    }
    public func showColorDetails() {
        self.panelContainerView.addSubview(self.colorDetailsView)
    }
    public func setImageBrightness(_ value: Float) {
        brightnessValue = value
        //filter.setValue(value, forKey: kCIInputBrightnessKey)
        getFinalImageView()
    }
    public func setImageContrast(_ value: Float) {
        contrastValue = value
        //filter.setValue(value, forKey: kCIInputContrastKey)
        getFinalImageView()
    }
    public func setImageSaturation(_ value: Float) {
        saturationValue = value
        //filter.setValue(value, forKey: kCIInputSaturationKey)
        getFinalImageView()
    }
    public func setImageBlur(_ value: Float) {
        blurValue = value
        getFinalImageView()
    }
    func getFinalImageView() {
        if #available(iOS 10.0, *) {
            let outputImage = beginImage.applyingFilter("CIColorControls",
                                                    parameters: [
                                                        kCIInputBrightnessKey: brightnessValue,
                                                        kCIInputSaturationKey: saturationValue,
                                                        kCIInputContrastKey: contrastValue
                                                    ])
                .applyingGaussianBlur(sigma: Double(blurValue))
                .cropped(to: beginImage.extent)
            imageView.image = UIImage(ciImage: outputImage)
        } else {
            let outputImage = beginImage.applyingFilter("CIColorControls",
                                                    parameters: [
                                                        kCIInputBrightnessKey: brightnessValue,
                                                        kCIInputSaturationKey: saturationValue,
                                                        kCIInputContrastKey: contrastValue
                                                    ])
            imageView.image = UIImage(ciImage: outputImage)
            self.imageView.addBlur(CGFloat(blurValue/10))
        }
        
        
   /*
        
        if let ciImage = filter.value(forKey: "outputImage") as? CIImage {
            if #available(iOS 10.0, *) {
                let blurredCIImage = ciImage.applyingGaussianBlur(sigma: Double(blurValue))
                let croppedImage = blurredCIImage.cropped(to: ciImage.extent)
                imageView.image = UIImage(ciImage: croppedImage)
            } else {
                imageView.image = UIImage(ciImage: ciImage)
                self.imageView.addBlur(CGFloat(blurValue/10))
            }
            
        }
 */
    }
}

public class TICCustomizeViewController : UIViewController
{
    @IBOutlet weak var imageView: BlurredImageView!
    @IBOutlet weak var compositeView: UIView!
    @IBOutlet weak var toolbarDividersView: UIView!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var referenceFormatButton: UIButton!
    @IBOutlet weak var toolbarScrollView: UIScrollView!
    var webView: WKWebView!
    
    var fontSizeView: TICFontAttributesPanelView!
    var referenceSizeView: TICReferenceFontPanelView!
    var colorView: TICColorPanelView!
    var colorDetailsView: TICColorPickerPanelView!
    var extrasView: TICExtrasPanelView!
    var alignmentView: TICAlignmentPanelView!
    var shadowView: TICTextShadowPanelView!
    var colorFilterView: TICColorFilterPanelView!
    var widthInPixels: CGFloat = 320
    var filter: CIFilter!;
    var blurValue: Float = 0
    var contrastValue: Float = 1
    var brightnessValue: Float = 0
    var saturationValue: Float = 1
    var beginImage: CIImage!
    
    var fontViewController: TICFontPanelViewController!
    var lastX: Int = 0
    var lastY: Int = 0
    
    @IBOutlet weak var panelContainerView: UIView!
    
    @IBOutlet var toolbarButtons: [UIButton]!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var compositeImage: UIImage?
    var fontSize: Int = 15
    var selectedToolbarButton: UIButton? = nil
    var fontFormatDelegate: SBFontFormatDelegate!

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        let contentController = createContentController()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        // Fix Fullscreen mode for video and autoplay
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: self.webContainerView.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.contentMode = .scaleAspectFill
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.isOpaque = false
        webView.isUserInteractionEnabled = false
        webContainerView.addSubview(webView)
        
        if TICConfig.instance.selectedURL != nil {
            self.imageView.imageURL = TICConfig.instance.selectedURL
        } else {
            self.imageView.image = TICConfig.instance.selectedImage
        }
        
        filter = CIFilter(name: "CIColorControls")
        beginImage = CIImage(image: self.imageView.image!)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        
        //using empty string to remove default `Back` text on NavigationBar back item
        self.navigationItem.title = " "//TICConfig.instance.locale.chooseImage
        
        loadHTML()
        
        //widthInPixels = imageView.frame.width * UIScreen.main.scale
        self.setupEditorPanels()
        self.setupToolbarButtons()
        
        toolbarDividersView.subviews.forEach {
            $0.backgroundColor = TICConfig.instance.theme.highlightColor
        }
     }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.webContainerView.bounds
    }

    func setupEditorPanels()
    {
        var panels: [TICFormatPanelView] = []

        let f = self.panelContainerView.bounds
        self.alignmentView = TICAlignmentPanelView(frame: f)
        self.extrasView = TICExtrasPanelView(frame: f)
        self.colorView = TICColorPanelView(frame: f)
        self.colorDetailsView = TICColorPickerPanelView(frame: f)
        self.fontSizeView = TICFontAttributesPanelView(frame: f)
        self.referenceSizeView = TICReferenceFontPanelView(frame: f)
        self.shadowView = TICTextShadowPanelView(frame: f)
        self.colorFilterView = TICColorFilterPanelView(frame: f)
        
        let fontPanelStoryboard =  UIStoryboard(name: "TICFontPanel", bundle: TICConfig.instance.bundle)
        fontViewController = fontPanelStoryboard.instantiateViewController(withIdentifier: "FontPanelViewController") as? TICFontPanelViewController
        

        alignmentView.imageWidth = widthInPixels
        
        panels.append(self.alignmentView)
        panels.append(self.extrasView)
        panels.append(self.colorView)
        panels.append(self.colorDetailsView)
        panels.append(self.fontSizeView)
        panels.append(self.referenceSizeView)
        panels.append(self.shadowView)
        panels.append(self.colorFilterView)
        
        panels.forEach {
            self.panelContainerView.addSubview($0)
            $0.constrainToFillSuperview()
            $0.delegate = self
        }
        self.panelContainerView.addSubview(fontViewController.view)
        fontViewController.view.constrainToFillSuperview()
        
        fontViewController.delegate = self
        fontViewController.setAvailableFonts(fonts: TICConfig.instance.fonts)
        fontSizeView.fontDelegate = alignmentView
        colorDetailsView.colorDelegate = colorView
        fontFormatDelegate = alignmentView
        
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

    func loadHTML() {
        if let filepath = TICConfig.instance.bundle.path(forResource: "composite", ofType: "html") {
            do {
                let contents = try String(contentsOfFile: filepath)
                var fontString = ""
                for font in TICConfig.instance.fonts {
                    if font.fileName != nil {
                        let fontUrlString = TICConfig.instance.fontBaseURL!.absoluteString + font.fileName!
                        let newFontString = "@font-face { font-family: \(font.fontFamily); src: url('\(fontUrlString)') format('truetype'); font-weight: normal; font-style: normal; }\n"
                        fontString = fontString + newFontString
                    }
                }
                let html = contents.replacingOccurrences(of: "//FONTS", with: fontString)
                let assetsUrl = TICConfig.instance.bundle.resourceURL!.appendingPathComponent("HTML")
                webView.loadHTMLString(html, baseURL: assetsUrl)
            } catch {
                // contents could not be loaded
            }
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
            TICConfig.instance.active = false
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
    
    @IBAction func handleFontButtonTap(_ sender: UIButton) {
        
        //self.panelContainerView.addSubview(self.fontView)
        self.panelContainerView.addSubview(self.fontViewController.view)
    }
    
    @IBAction func handleFontSizeButtonTap(_ sender: UIButton) {
        
        self.panelContainerView.addSubview(self.fontSizeView)
        centerButton(button: sender)
    }
    @IBAction func handleColorButtonTap(_ sender: UIButton) {
        
        self.panelContainerView.addSubview(self.colorView)
        centerButton(button: sender)
    }
    
    @IBAction func handleAlignmentButtonTap(_ sender: UIButton) {
        
        self.panelContainerView.addSubview(self.alignmentView)
        centerButton(button: sender)

    }
    
    @IBAction func handleExtrasButtonTap(_ sender: UIButton) {
        
        self.panelContainerView.addSubview(self.extrasView)
        centerButton(button: sender)
    }
    
    @IBAction func handleReferenceFontButtonTap(_ sender: UIButton) {
        self.panelContainerView.addSubview(self.referenceSizeView)
    }
    
    @IBAction func colorFilterButtonTap(_ sender: UIButton) {
        self.panelContainerView.addSubview(self.colorFilterView)
        centerButton(button: sender)
    }
    @IBAction func handleTextShadowTap(_ sender: UIButton) {
        self.panelContainerView.addSubview(self.shadowView)
        centerButton(button: sender)

    }
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == UIGestureRecognizer.State.began {
            lastX = 0
            lastY = 0
        } else {
            let newX = Int(translation.x)
            if newX != lastX {
                let adjustment = newX - lastX
                lastX = newX
                let leftMargin = fontFormatDelegate.getDivLeftMargin()
                fontFormatDelegate.setDivLeftMargin(newMargin: leftMargin + adjustment)
            }
            let newY = Int(translation.y)
            if newY != lastY {
                let yAdjustment = newY - lastY
                 lastY = newY
                let topMargin = fontFormatDelegate.getDivTopMargin()
                fontFormatDelegate.setDivTopMargin(newMargin: topMargin + yAdjustment)
            }
        }
    }
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowComposite" {
            if let vc = segue.destination as? TICShareViewController {
                vc.compositeImage = self.compositeImage
            }
        }
    }
    
    func centerButton(button: UIButton) {
        let xCenter = max(0, (button.center.x - self.toolbarScrollView.frame.width/2))
        if xCenter > toolbarScrollView.contentOffset.x {
            if !toolbarScrollView.bounds.contains(referenceFormatButton.frame) {
                self.toolbarScrollView.setContentOffset(CGPoint(x: xCenter, y: self.toolbarScrollView.contentOffset.y), animated: true)
            }
        } else {
            if !toolbarScrollView.bounds.contains(fontButton.frame) {
                self.toolbarScrollView.setContentOffset(CGPoint(x: xCenter, y: self.toolbarScrollView.contentOffset.y), animated: true)
            }
        }
    }
    func createContentController() -> WKUserContentController {
        let contentController = WKUserContentController()
//        contentController.add(self, name: "addVersePosition")
        return contentController
    }
    func getBodyWidth() -> CGFloat {
        let anyWidth = TICCustomizeViewController.evaluateJavaScript("document.body.clientWidth", webView: webView)
        let floatWidth = ((anyWidth as? CGFloat) != nil) ? anyWidth as! CGFloat : 320

      return floatWidth
    }

    static func evaluateJavaScript(_ script: String, webView: WKWebView?) -> AnyObject {
        var finished = false
        var retVal: AnyObject = 0 as AnyObject
        let failureDate = Date(timeIntervalSinceNow: 3.0)
        webView!.evaluateJavaScript(script) {(result, error) in
            if error == nil {
                retVal = result as AnyObject
            }
            finished = true
        }
        while !finished {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 3.0))
            let now = Date()
            if (now > failureDate) {
                finished = true
                if #available(iOS 10.0, *) {
                    os_log("TIC: evaluateJavaScript Didn't complete prior to failure time")
                } else {
                    NSLog("TIC: evaluateJavaScript Didn't complete prior to failure time")
                }
            }
        }
        return retVal
    }

}

extension TICCustomizeViewController : WKNavigationDelegate {
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let text = TICConfig.instance.text
        let reference = TICConfig.instance.reference
        print("Text: \(text) Reference:\(reference)")
        let js = "reset('\(text)', '\(reference)')"
        print("Reset: \(js)")
        let initialFont = TICConfig.instance.fonts[0]
        self.webView.evaluateJavaScript(js, completionHandler: nil)
        self.setStyle(.textAlign, Alignment.center.stringValue(), .both )
        self.setStyle(.fontFamily, initialFont.fontFamily, .both)
        self.widthInPixels = self.getBodyWidth()
        if alignmentView != nil {
            alignmentView.imageWidth = widthInPixels
        }
    }

}
