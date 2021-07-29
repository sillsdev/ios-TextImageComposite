//
//  TICImages.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TextImageComposite
{
    //used to load the bundle by name
}

public protocol SharingDelegate
{
    func createVideo(_ config: TICConfig, _ image: UIImage) -> NSURL?
}
public protocol TICTextViewDelegate
{
    func getTextViewController() -> EditTextBaseViewController
}
public class TICConfig
{
    
    static var _instance: TICConfig? = nil
    
    public var text: String             = ""
    public var reference: String        = ""
    public var images: [TICImage]       = []
    public var fonts: [TICFont]         = [TICFont.init(title : "Helvetica", fontFamily: "Helvetica")]
    public var defaultFont: String      = ""
    public var locale: TICLocalization  = TICLocalization.us_en()
    public var theme: TICTheme          = TICTheme.defaultTheme()
    public var rtl: Bool                = false
    public var active: Bool             = false
    public var fontBaseURL: URL?
    
    public var selectedImage : UIImage?
    public var selectedURL : URL?
    public var watermarkImage: TICWatermark?
    public var sharingDelegate: SharingDelegate?
    public var textViewDelegate: TICTextViewDelegate?
    
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
    
    public init(backgroundColor: UIColor, contrastColor: UIColor, accentColor: UIColor, tintColor: UIColor, highlightColor: UIColor, buttonBackgroundColor: UIColor, viewBackgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.contrastColor = contrastColor
        self.accentColor = accentColor
        self.tintColor = tintColor
        self.highlightColor = highlightColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.viewBackgroundColor = viewBackgroundColor
        self.textColor = textColor
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
        navbar.tintColor = UIColor.white
        navbar.barTintColor = self.contrastColor
        navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:self.accentColor as Any]
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

public struct TICImage
{
    var imageURL : URL
    
    public init(imageURL : URL) {
        self.imageURL = imageURL
    }
    
    public init(imageName : String) {
        self.imageURL = Bundle.main.url(forResource: imageName, withExtension: "")!
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
    public func getXY(_ imageSideSize: Int) -> (x: Int, y: Int) {
        var x: Int = 0
        var y: Int = 0
        
        let watermarkWidth = getWatermarkWidth(imageSideSize)
        let watermarkHeight = getWatermarkHeight(imageSideSize)
        let marginX = imageSideSize * marginPercent / 100
        let marginY = imageSideSize * marginPercent / 100
        
        switch alignment {
        case .TOP_LEFT:
            x = marginX
            y = marginY
        case .TOP_CENTRE:
            x = (imageSideSize / 2) - (watermarkWidth / 2)
            y = marginY
        case .TOP_RIGHT:
            x = imageSideSize - watermarkWidth - marginX
            y = marginY
        case .BOTTOM_LEFT:
            x = marginX
            y = imageSideSize - watermarkHeight - marginY
        case .BOTTOM_CENTRE:
            x = (imageSideSize / 2) - (watermarkWidth / 2)
            y = imageSideSize - watermarkHeight - marginY
        case .BOTTOM_RIGHT:
            x = imageSideSize - watermarkWidth - marginX
            y = imageSideSize - watermarkHeight - marginY
        }
        return (x,y)
    }
}
