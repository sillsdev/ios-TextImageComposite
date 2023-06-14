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
import Photos
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
    case dir = "direction"
}
extension TICCustomizeViewController : UIPopoverPresentationControllerDelegate {
    public func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        var retMode = UIModalPresentationStyle.currentContext
        // Views below are always popover
        if let _: ShareTypeTableViewController = controller.presentedViewController as? ShareTypeTableViewController {
            retMode = UIModalPresentationStyle.none
        }
        return retMode
    }
}
extension TICCustomizeViewController : TICImageSelectionDelegate {
    public func getAnchorButton() -> UIBarButtonItem {
        return saveButton
    }
    
    public func changeSelectedImage() {
        setupImage()
        getFinalImageView()
    }
    
}

extension TICCustomizeViewController : TICShareDelegate {
    fileprivate func shareResult(_ activityItems: inout [Any]) {
        if !TICConfig.instance.link.isEmpty {
            activityItems += [TICConfig.instance.link]
        }
        if !activityItems.isEmpty {
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            vc.popoverPresentationController?.barButtonItem = self.shareButton
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    public func share(type: TICShareOutputType) {
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.compositeImage = UIImage.init(view: self.compositeView)
            if let img = self.compositeImage {
                var activityItems : [Any] = []
                switch type {
                case .image:
                    activityItems = [img]
                    self.shareResult(&activityItems)
                case .video:
                    if  !TICConfig.instance.sharingDelegate!.createVideo(config: TICConfig.instance, image: img, completionHandler: { (success: Bool, url: URL?) in
                        guard let videoURL = url else { return }
                        activityItems = [videoURL]
                        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.shareResult(&activityItems)
                        }
                    })
                    {
                        print ("Error saving video")
                    }
                }
            }
        }
    }
    
    public func save(type: TICShareOutputType) {
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.compositeImage = UIImage.init(view: self.compositeView)
            if let img = self.compositeImage
            {
                switch type {
                case .image:
                    UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                case .video:
                    if  !TICConfig.instance.sharingDelegate!.createVideo(config: TICConfig.instance, image: img, completionHandler: { (success: Bool, url: URL?) in
                        guard let videoURL = url else { return }
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL as URL)
                        }) { saved, error in
                            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                                if saved {
                                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                    {
                        print ("Error saving video")
                    }
                }

            }
        }
    }
    
    
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
        
    }
}
extension TICCustomizeViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         return true
    }
}
public class TICCustomizeViewController : UIViewController
{
    @IBOutlet weak var imageSelect: UIButton!
    @IBOutlet weak var imageView: BlurredImageView!
    @IBOutlet weak var compositeView: UIView!
    @IBOutlet weak var toolbarDividersView: UIView!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var referenceFormatButton: UIButton!
    @IBOutlet weak var toolbarScrollView: UIScrollView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
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
    var imageSelectController: TICImageSelectPanel!
    var lastX: Int = 0
    var lastY: Int = 0
    var doubleTap: UITapGestureRecognizer?

    @IBOutlet weak var panelContainerView: UIView!
    
    @IBOutlet var toolbarButtons: [UIButton]!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func double(_ sender:UITapGestureRecognizer) {
        NSLog("Double tap")
        if let editTextVC = TICConfig.instance.textViewDelegate == nil ?
            EditTextBaseViewController() :
            TICConfig.instance.textViewDelegate?.getTextViewController() {
            editTextVC.webView = webView
            self.navigationController?.pushViewController(editTextVC, animated: true)
        }
    }
    var compositeImage: UIImage?
    var fontSize: Int = 15
    var selectedToolbarButton: UIButton? = nil
    var fontFormatDelegate: SBFontFormatDelegate!
    var fontSizeDelegate: SBFontSizeDelegate!
    var referenceFontSizeDelegate: SBFontSizeDelegate?

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        TICConfig.instance.active = true
        
        self.cancelBarButton.title = TICConfig.instance.locale.cancel
        
        //using empty string to remove default `Back` text on NavigationBar back item
        self.navigationItem.title = " "//TICConfig.instance.locale.chooseImage
        self.cancelBarButton.title = TICConfig.instance.locale.cancel
        
        TICConfig.instance.theme.formatNavbar((self.navigationController?.navigationBar)!)

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
        
        let doubleTapSelector : Selector = #selector(TICCustomizeViewController .double(_:))
        doubleTap = UITapGestureRecognizer(target: self, action: doubleTapSelector)
        doubleTap!.numberOfTapsRequired = 2
        doubleTap!.numberOfTouchesRequired = 1
        doubleTap!.delegate = self
        compositeView.addGestureRecognizer(doubleTap!)
        
        TICConfig.instance.selectedURL = TICConfig.instance.images[0].imageURL
        TICConfig.instance.selectedImage = nil

        filter = CIFilter(name: "CIColorControls")

        setupImage()
        
        //using empty string to remove default `Back` text on NavigationBar back item
        self.navigationItem.title = " "//TICConfig.instance.locale.chooseImage
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        loadHTML()
        
        //widthInPixels = imageView.frame.width * UIScreen.main.scale
        self.setupEditorPanels()
        self.setupToolbarButtons()
        
        self.toolbarScrollView.setContentOffset(CGPoint(x: imageSelect.center.x, y: self.toolbarScrollView.contentOffset.y), animated: true)
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
        var panels: [TICBasePanelView] = []
        let f = self.panelContainerView.bounds
        self.alignmentView = TICAlignmentPanelView(frame: f)
        self.extrasView = TICExtrasPanelView(frame: f)
        self.colorView = TICColorPanelView(frame: f)
        self.colorDetailsView = TICColorPickerPanelView(frame: f)
        self.fontSizeView = TICFontAttributesPanelView(frame: f)
        if (TICConfig.instance.reference.isEmpty) {
            referenceFormatButton.isHidden = true
        } else {
            self.referenceSizeView = TICReferenceFontPanelView(frame: f)
        }
        self.shadowView = TICTextShadowPanelView(frame: f)
        self.colorFilterView = TICColorFilterPanelView(frame: f)
        
        let fontPanelStoryboard =  UIStoryboard(name: "TICFontPanel", bundle: TICConfig.instance.bundle)
        fontViewController = fontPanelStoryboard.instantiateViewController(withIdentifier: "FontPanelViewController") as? TICFontPanelViewController
        let imageSelectStoryboard = UIStoryboard(name: "TICImageSelectPanel", bundle: TICConfig.instance.bundle)
        imageSelectController = imageSelectStoryboard.instantiateViewController(withIdentifier: "TICImageSelectPanel") as? TICImageSelectPanel
        imageSelectController.selectImageDelegate = self
        
        alignmentView.imageWidth = widthInPixels
        
        panels.append(self.alignmentView)
        panels.append(self.extrasView)
        panels.append(self.colorView)
        panels.append(self.colorDetailsView)
        panels.append(self.fontSizeView)
        if !TICConfig.instance.reference.isEmpty {
            panels.append(self.referenceSizeView)
            referenceFontSizeDelegate = referenceSizeView
        }
        panels.append(self.shadowView)
        panels.append(self.colorFilterView)
        
        panels.forEach {
            self.panelContainerView.addSubview($0)
            $0.constrainToFillSuperview()
            $0.delegate = self
        }
        self.panelContainerView.addSubview(fontViewController.view)
        fontViewController.view.constrainToFillSuperview()
        
        self.panelContainerView.addSubview(imageSelectController.view)
        imageSelectController.view.constrainToFillSuperview()
        
        fontViewController.delegate = self
        fontViewController.setAvailableFonts(fonts: TICConfig.instance.fonts)
        fontSizeView.fontDelegate = alignmentView
        colorDetailsView.colorDelegate = colorView
        fontFormatDelegate = alignmentView
        fontSizeDelegate = fontSizeView
        
        self.view.addSubview(self.panelContainerView)
    }
    
    func setupToolbarButtons() {
        var i = 0
        for btn : UIButton in self.toolbarButtons {
             if (btn == imageSelect) {
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
    
    func setupImage() {
        var baseImage: UIImage?
        if TICConfig.instance.selectedURL != nil {
            baseImage = UIImage(contentsOfFile: TICConfig.instance.selectedURL!.path)
        } else {
            baseImage = TICConfig.instance.selectedImage
        }
        if let watermark = TICConfig.instance.watermarkImage {
            // If watermark defined
            let pointCoordinates = watermark.getXY(Int(baseImage!.size.width), Int(baseImage!.size.height))
            let watermarkImage = watermark.watermarkImage!
            UIGraphicsBeginImageContextWithOptions(baseImage!.size, false, 0.0)
            baseImage!.draw(in: CGRect(x: 0.0, y: 0.0, width: baseImage!.size.width, height: baseImage!.size.height))
            watermarkImage.draw(in: CGRect(x: pointCoordinates.x, y: pointCoordinates.y, width: watermark.getWatermarkWidth(Int(baseImage!.size.width)), height: watermark.getWatermarkHeight(Int(baseImage!.size.height))))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageView.image = result
        } else {
            self.imageView.image = baseImage
        }
        
        beginImage = CIImage(image: self.imageView.image!)
        filter.setValue(beginImage, forKey: kCIInputImageKey)

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
                let assetsUrl = TICConfig.instance.bundle.resourceURL!
                if TICConfig.instance.containerApp {
                    loadHTMLForContainer(html: html, webView: webView, localUrl: assetsUrl)
                } else {
                    webView.loadHTMLString(html, baseURL: assetsUrl)
                }
            } catch {
                // contents could not be loaded
            }
        }
    }
    func loadHTMLForContainer(html: String, webView: WKWebView, localUrl: URL) {
        do {
            let jqueryUrl = TICConfig.instance.fontBaseURL!.appendingPathComponent("jquery-3.2.1.min.js")
            if !FileManager.default.fileExists(atPath: jqueryUrl.path) {
                let srcUrl = localUrl.appendingPathComponent("jquery-3.2.1.min.js")
                if FileManager.default.fileExists(atPath: srcUrl.path) {
                    NSLog("Copying \(srcUrl.path) to \(jqueryUrl.path)")
                    try FileManager.default.copyItem(at: srcUrl, to: jqueryUrl)
                }
            }
            let dstURL = TICConfig.instance.fontBaseURL!.appendingPathComponent("TICHTML.html")
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try html.write(to: dstURL, atomically: false, encoding: .utf8)
            webView.loadFileURL(dstURL, allowingReadAccessTo: TICConfig.instance.fontBaseURL!)
        } catch {
            NSLog("Error on loadHTMLForContainer")
        }
    }
    @IBAction func handleSaveButtonTap(_ sender: Any) {
        if TICConfig.instance.sharingDelegate == nil {
            save(type: .image)
        } else {
            showShareTypeOptions(barButton: saveButton, shareOperation: false)
        }
    }
    
    @IBAction func handleShareButtonTap(_ sender: Any) {
        if TICConfig.instance.sharingDelegate == nil {
            share(type: .image)
        } else {
            showShareTypeOptions(barButton: shareButton, shareOperation: true)
        }
    }
    
    func showShareTypeOptions(barButton: UIBarButtonItem, shareOperation: Bool) {
        if let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "ShareTypeVC") as? ShareTypeTableViewController {
            popoverContent.shareOperation = shareOperation
            popoverContent.shareDelegate = self
            popoverContent.modalPresentationStyle = .popover
            if let popover = popoverContent.popoverPresentationController {

                popover.barButtonItem = barButton

                // the size you want to display
                popoverContent.preferredContentSize = CGSize(width: 200, height: 100)
                popover.delegate = self
            }

            self.present(popoverContent, animated: true, completion: nil)
        }
    }
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            TICConfig.instance.active = true
        }  else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    func setInitialTextSize() {
        var divHeight = getDivHeight()
        let maxHeight = widthInPixels
        while (divHeight > (maxHeight * 0.90)) && (fontSizeDelegate.getFontSize() > fontSizeDelegate!.getFontSizeMinimum()) {
            fontSizeDelegate.setFontSize(newSize: (fontSizeDelegate.getFontSize() - 1))
            if referenceFontSizeDelegate != nil {
                if referenceFontSizeDelegate!.getFontSize() > 5 {
                    referenceFontSizeDelegate!.setFontSize(newSize: (referenceFontSizeDelegate!.getFontSize() - 1))
                } else {
                    break
                }
            }
            divHeight = getDivHeight()
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
    
    @IBAction func handleImageSelectTap(_ sender: Any) {
        self.panelContainerView.addSubview(self.imageSelectController.view)
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
    @IBAction func cancelBarButtonPressed(_ sender: Any) {
        TICConfig.instance.active = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func centerButton(button: UIButton) {
        let xCenter = max(0, (button.center.x - self.toolbarScrollView.frame.width/2))
        self.toolbarScrollView.setContentOffset(CGPoint(x: xCenter, y: self.toolbarScrollView.contentOffset.y), animated: true)
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
    func getBodyHeight() -> CGFloat {
        let anyHeight = TICCustomizeViewController.evaluateJavaScript("document.body.clientHeight", webView: webView)
        let floatHeight = ((anyHeight as? CGFloat) != nil) ? anyHeight as! CGFloat : 320
        return floatHeight
    }
    static func setTextAndReference(webView: WKWebView?) {
        var text = TICConfig.instance.text.replacingOccurrences(of: "\n", with: "<br>").replacingOccurrences(of: "\t", with: "")
        text = text.replacingOccurrences(of: "\'", with: "&#39")
        var reference = TICConfig.instance.reference.replacingOccurrences(of: "\n", with: "<br>").replacingOccurrences(of: "\t", with: "")
        reference = reference.replacingOccurrences(of: "\'", with: "&#39")
        let js = "reset('\(text)', '\(reference)')"
        webView?.evaluateJavaScript(js, completionHandler: nil)
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
        let initialFontFamily = !TICConfig.instance.defaultFont.isEmpty ? TICConfig.instance.defaultFont : TICConfig.instance.fonts[0].fontFamily
        TICCustomizeViewController.setTextAndReference(webView: webView)
        if TICConfig.instance.rtl {
            self.setStyle(.dir, "rtl", .both)
        }
        self.setStyle(.textAlign, Alignment.center.stringValue(), .both )
        self.setStyle(.fontFamily, initialFontFamily, .both)
        self.widthInPixels = self.getBodyWidth()
        self.setStyle(.fontWeight, "bold", .text)
        if alignmentView != nil {
            alignmentView.imageWidth = widthInPixels
            alignmentView.setDivWidth(newWidth: Int(widthInPixels) * 75 / 100)
        }
        let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.setInitialTextSize()
            self.fontFormatDelegate.setDivTopMarginCenter()
            let fontSizeMaximum = Float(self.widthInPixels/9)
            self.fontSizeDelegate.setFontSizeMaximum(maximum: fontSizeMaximum)
            self.referenceFontSizeDelegate?.setFontSizeMaximum(maximum: fontSizeMaximum)
            
        }
    }

}
