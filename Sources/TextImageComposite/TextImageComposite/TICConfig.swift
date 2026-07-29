//
//  TICImages.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public typealias TICShareCompletionHandlerType = (Bool, URL?) -> Void
public class TextImageComposite
{
    //used to load the bundle by name
}

public protocol SharingDelegate
{
    func createVideo(config: TICConfig, image: UIImage, completionHandler: @escaping TICShareCompletionHandlerType) -> Bool
}
public protocol TICTextViewDelegate
{
    func getTextViewController() -> EditTextBaseViewController
    func lockOrientation(mask: UIInterfaceOrientationMask, orientation: UIInterfaceOrientation? )
}
public class TICConfig
{
    
    static var _instance: TICConfig? = nil
    
    public var text: String             = ""
    public var reference: String        = ""
    public var link: String             = ""
    public var images: [TICImage]       = []
    public var fonts: [TICFont]         = [TICFont.init(title : "Helvetica", fontFamily: "Helvetica")]
    public var defaultFont: String      = ""
    public var locale: TICLocalization  = TICLocalization.us_en()
    public var theme: TICTheme          = TICTheme.defaultTheme()
    public var rtl: Bool                = false
    public var active: Bool             = false
    public var fontBaseURL: URL?
    
    public var selectedImage : UIImage?
    public var selectedTICImage: TICImage?
    public var watermarkImage: TICWatermark?
    public var sharingDelegate: SharingDelegate?
    public var textViewDelegate: TICTextViewDelegate?
    public var originalOrientationMask: UIInterfaceOrientationMask = .all
    public var originalOrientation: UIInterfaceOrientation? = nil
    
    public static var instance: TICConfig {
        if _instance == nil {
            _instance = TICConfig()
        }
        return _instance!
    }
    
    public var bundle: Bundle {
        let bundle = Bundle(identifier: "org.sil.TextImageComposite")
        return bundle!
    }
    
    public var viewControllerName : String {
        return "TICNavController"
    }
    public var storyboardName: String {
        return "TIC"
    }
    public var imageCache = NSCache<NSString, AnyObject>()
    public var containerApp: Bool = false

}

public struct TICTheme {
    var backgroundColor: UIColor!
    var contrastColor: UIColor!
    var accentColor: UIColor!
    var tintColor: UIColor!
    var highlightColor: UIColor!
    var buttonBackgroundColor: UIColor!
    var viewBackgroundColor: UIColor!
    var textColor: UIColor!
    var navTitleColor: UIColor!
    
    public init(backgroundColor: UIColor, contrastColor: UIColor, accentColor: UIColor, tintColor: UIColor, highlightColor: UIColor, buttonBackgroundColor: UIColor, viewBackgroundColor: UIColor, textColor: UIColor, navTitleColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.contrastColor = contrastColor
        self.accentColor = accentColor
        self.tintColor = tintColor
        self.highlightColor = highlightColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.viewBackgroundColor = viewBackgroundColor
        self.textColor = textColor
        self.navTitleColor = navTitleColor
    }
    public init() {
        
    }
    func formatControl(_ control : UIControl) {
        control.tintColor = self.tintColor
        
        if let slider = control as? UISlider {
            slider.thumbTintColor = self.tintColor
            slider.maximumTrackTintColor = self.accentColor
            slider.minimumTrackTintColor = self.tintColor
        }
    }
    
    func formatToolbarButton(_ button : UIButton) {
        if(button.isSelected) {
            button.backgroundColor = self.backgroundColor
            button.tintColor = self.tintColor
        } else {
            button.backgroundColor = self.backgroundColor
            button.tintColor = self.accentColor
        }
    }
    
    func formatLabel(_ label : UILabel) {
        label.textColor = self.accentColor
        label.font = UIFont.systemFont(ofSize: 13)
    }
    func formatImage(_ image : UIImageView) {
        image.backgroundColor = backgroundColor
        image.tintColor = tintColor

    }
    func formatView(_ view :UIView) {
        view.backgroundColor = backgroundColor
    }
    
    func formatNavbar(_ navbar : UINavigationBar) {
        let tintColor = self.navTitleColor ?? UIColor.white
        let appearance = getNavAppearance(navBar: navbar, tintColor: tintColor)
        navbar.standardAppearance = appearance
        navbar.scrollEdgeAppearance = appearance
        navbar.isTranslucent = false
        navbar.tintColor = tintColor
        navbar.barTintColor = self.contrastColor
    }
    func getNavAppearance(navBar: UINavigationBar, tintColor: UIColor) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = self.contrastColor
        let buttonAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor]
        appearance.buttonAppearance.normal.titleTextAttributes = buttonAttrs
        appearance.doneButtonAppearance.normal.titleTextAttributes = buttonAttrs
        if let attributes = navBar.largeTitleTextAttributes {
            appearance.largeTitleTextAttributes = attributes
        }

        if let attributes = navBar.titleTextAttributes {
            appearance.titleTextAttributes = attributes
        } else {
            appearance.titleTextAttributes = setNavBarAttributes(navBar: navBar)
        }
        return appearance
    }
    func setNavBarAttributes(navBar: UINavigationBar) -> [NSAttributedString.Key : Any] {
        let textAttributes = [NSAttributedString.Key.foregroundColor:self.accentColor as Any]
        navBar.titleTextAttributes = textAttributes
        return textAttributes
    }
    static public func defaultTheme() -> TICTheme {
        var theme = TICTheme()
        theme.backgroundColor = UIColor.colorWithHex("EEEEEE") //
        theme.tintColor = UIColor.colorWithHex("7cb55d") //
        theme.accentColor = UIColor.colorWithHex("888888") //
        theme.contrastColor = UIColor.colorWithHex("627D4D") //
        theme.highlightColor = UIColor.colorWithHex("d1d2d1")
        theme.buttonBackgroundColor = UIColor.init(red: 0.820, green: 0.820, blue: 0.839, alpha: 1) // systemGray4
        theme.viewBackgroundColor = UIColor.init(red: 0.933, green: 0.933, blue: 0.933, alpha: 1) //
        theme.textColor = UIColor.black
        theme.navTitleColor = UIColor.white
        return theme
    }
    
    //just used for testing colors quickly
    static public func wackyTheme() -> TICTheme {
        var theme = TICTheme()
        theme.backgroundColor = .red
        theme.tintColor = .blue
        theme.accentColor = .green
        theme.contrastColor = .yellow
        theme.highlightColor = .brown
        theme.buttonBackgroundColor = .cyan
        theme.viewBackgroundColor = .white
        theme.textColor = .black

        return theme
    }
}

public struct TICLocalization
{
    var cancel: String!
    var ok: String!
    var share: String!
    var done: String!
    var shareImage: String!
    var shareVideo: String!
    var saveImage: String!
    var saveVideo: String!
    var editText: String!
    
    public init(cancel: String, ok: String, share: String, done: String,
                shareImage: String, shareVideo: String,
                saveImage: String, saveVideo: String, editText: String) {
        self.cancel = cancel
        self.ok = ok
        self.share = share
        self.done = done
        self.shareImage = shareImage
        self.shareVideo = shareVideo
        self.saveImage = saveImage
        self.saveVideo = saveVideo
        self.editText = editText
    }
    public init(cancel: String, ok: String, share: String, done: String) {
        self.cancel = cancel
        self.ok = ok
        self.share = share
        self.done = done
        self.shareImage = ""
        self.shareVideo = ""
        self.saveImage = ""
        self.saveVideo = ""
        self.editText = ""
    }
    public init() {
        
    }
    static public func us_en() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Cancel"
        locale.ok = "OK"
        locale.share = "Share"
        locale.done = "Done"
        locale.shareVideo = "Share Video"
        locale.shareImage = "Share Image"
        locale.saveVideo = "Save Video"
        locale.saveImage = "Save Image"
        locale.editText = "Edit Text"
        return locale
    }
    
    static public func lorem() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Lorem"
        locale.ok = "KO"
        locale.share = "Sit"
        locale.done = "Pol"
        locale.shareVideo = "Ipsum unem"
        locale.shareImage = "Ipsum wen"
        locale.saveVideo = "Porce unem"
        locale.saveImage = "Porce wen"
        locale.editText = "Gypt wurse"
        
        return locale
    }
}
public struct TICTextArea
{
    var left: Float
    var top: Float
    var width: Float
    var height: Float
    
    public init(left: Float, top: Float, width: Float, height: Float) {
        // Clamp left and top to 0...1, defaulting to 0 if out of range
        self.left = (left >= 0 && left <= 1) ? left : 0
        self.top = (top >= 0 && top <= 1) ? top : 0
        
        // Clamp width and height to 0...1, defaulting to (1 - left/top) if out of range
        let totalWidth = self.left + width
        let totalHeight = self.top + height
        self.width = (totalWidth >= 0 && totalWidth <= 1) ? width : (1 - self.left)
        self.height = (totalHeight >= 0 && totalHeight <= 1) ? height : (1 - self.top)
    }
}
public struct TICImage
{
    var imageURL : URL
    var textArea : TICTextArea?
    
    public init(imageURL : URL, textArea: TICTextArea? = nil) {
        self.imageURL = imageURL
        self.textArea = textArea
    }
    
    public init(imageName : String, textArea: TICTextArea? = nil) {
        self.imageURL = Bundle.main.url(forResource: imageName, withExtension: "")!
        self.textArea = textArea
    }
}

public struct TICFont
{
    var title : String
    var fontFamily : String
    var fileName: String?
    
    public init(title : String, fontFamily : String, fileName : String? = nil) {
        self.title = title
        self.fontFamily = fontFamily
        self.fileName = fileName
    }
}

public enum TICWatermarkAlignment: String {
    case TOP_LEFT = "top-left"
    case TOP_CENTRE = "top-centre"
    case TOP_RIGHT = "top-right"
    case BOTTOM_LEFT = "bottom-left"
    case BOTTOM_CENTRE = "bottom-centre"
    case BOTTOM_RIGHT = "bottom-right"
}

public struct TICWatermark
{
    public var watermarkImage: UIImage?
    public var alignment: TICWatermarkAlignment
    public var marginPercent: Int
    public var widthPercent: Int
    
    public init(watermarkImage: UIImage, alignment: TICWatermarkAlignment, marginPercent: Int, widthPercent: Int) {
        self.watermarkImage = watermarkImage
        self.alignment = alignment
        self.marginPercent = marginPercent
        self.widthPercent = widthPercent
    }
    func getWatermarkHeight(_ imageSideSize: Int) -> Int {
        let heightInPoints = watermarkImage!.size.height
        let widthInPoints = watermarkImage!.size.width
        let watermarkHeight = Int(Double(heightInPoints / widthInPoints) * Double(getWatermarkWidth(imageSideSize)))
        return watermarkHeight
    }
    func getWatermarkWidth(_ imageSideSize: Int) -> Int {
        let watermarkWidth = imageSideSize * widthPercent / 100
        return watermarkWidth
    }
    public func getXY(_ imageWidthSize: Int, _ imageHeightSize: Int) -> (x: Int, y: Int) {
        var x: Int = 0
        var y: Int = 0
        
        let watermarkWidth = getWatermarkWidth(imageWidthSize)
        let watermarkHeight = getWatermarkHeight(imageHeightSize)
        let marginX = imageWidthSize * marginPercent / 100
        let marginY = imageHeightSize * marginPercent / 100
        
        switch alignment {
        case .TOP_LEFT:
            x = marginX
            y = marginY
        case .TOP_CENTRE:
            x = (imageWidthSize / 2) - (watermarkWidth / 2)
            y = marginY
        case .TOP_RIGHT:
            x = imageWidthSize - watermarkWidth - marginX
            y = marginY
        case .BOTTOM_LEFT:
            x = marginX
            y = imageHeightSize - watermarkHeight - marginY
        case .BOTTOM_CENTRE:
            x = (imageWidthSize / 2) - (watermarkWidth / 2)
            y = imageHeightSize - watermarkHeight - marginY
        case .BOTTOM_RIGHT:
            x = imageWidthSize - watermarkWidth - marginX
            y = imageHeightSize - watermarkHeight - marginY
        }
        return (x,y)
    }
}
