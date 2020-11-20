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

public class TICConfig
{
    static public let instance = TICConfig()
    
    public var text: String             = ""
    public var reference: String        = ""
    public var images: [TICImage]       = []
    public var fonts: [TICFont]         = [TICFont.init(title : "Helvetica", fontFamily: "Helvetica")]
    public var locale: TICLocalization  = TICLocalization.us_en()
    public var theme: TICTheme          = TICTheme.defaultTheme()
    
    public var selectedImage : UIImage?
    
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
}

public struct TICTheme {
    var backgroundColor: UIColor!
    var contrastColor: UIColor!
    var accentColor: UIColor!
    var tintColor: UIColor!
    var highlightColor: UIColor!
    var buttonBackgroundColor: UIColor!
    
    func formatControl(_ control : UIControl) {
        control.tintColor = self.tintColor
        
        if let slider = control as? UISlider {
            slider.thumbTintColor = self.contrastColor
            slider.maximumTrackTintColor = self.accentColor
            slider.minimumTrackTintColor = self.tintColor
        }
    }
    
    func formatToolbarButton(_ button : UIButton) {
        if(button.isSelected) {
            button.backgroundColor = self.tintColor
            button.tintColor = self.contrastColor
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
        navbar.tintColor = self.accentColor
        navbar.barTintColor = self.contrastColor
        navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:self.accentColor as Any]
    }
    
    static public func defaultTheme() -> TICTheme {
        var theme = TICTheme()
        theme.backgroundColor = UIColor.colorWithHex("EEEEEE")
        theme.tintColor = UIColor.colorWithHex("7cb55d")
        theme.accentColor = UIColor.colorWithHex("888888")
        theme.contrastColor = UIColor.colorWithHex("FFFFFF")
        theme.highlightColor = UIColor.colorWithHex("d1d2d1")
        theme.buttonBackgroundColor = UIColor.init(red: 0.820, green: 0.820, blue: 0.839, alpha: 1) // systemGray4
        
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

        return theme
    }
}

public struct TICLocalization
{
    var cancel: String!
    var chooseImage: String!
    var save: String!
    var share: String!
    var size: String!
    var blur: String!
    var customize: String!
    var margins: String!
    var opacity: String!
    var top: String!
    var left: String!
    var right: String!
    var lineHeight: String!
    var letterSpacing: String!
    var done: String!
    
    static public func us_en() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Cancel"
        locale.chooseImage = "Choose Image"
        locale.save = "Save"
        locale.share = "Share"
        locale.size = "Size"
        locale.blur = "Blur"
        locale.customize = "Customize"
        locale.margins = "Margins"
        locale.opacity = "Opacity"
        locale.top = "Top"
        locale.left = "Left"
        locale.right = "Right"
        locale.lineHeight = "Line Height"
        locale.letterSpacing = "Letter Spacing"
        locale.done = "Done"
        
        return locale
    }
    
    static public func lorem() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Lorem"
        locale.chooseImage = "Eget Egestas"
        locale.save = "Dolor"
        locale.share = "Sit"
        locale.size = "Amet"
        locale.blur = "Elit"
        locale.customize = "Consectetur"
        locale.margins = "Adipiscing"
        locale.opacity = "Capit"
        locale.top = "Lop"
        locale.left = "Ifet"
        locale.right = "Thrig"
        locale.lineHeight = "Nil Ehgit"
        locale.letterSpacing = "Tellre Pacsin"
        locale.done = "Pol"
        
        return locale
    }
}

public struct TICImage
{
    var imageURL : URL
    var thumbURL : URL
    
    public init(imageURL : URL, thumbURL : URL) {
        self.imageURL = imageURL
        self.thumbURL = thumbURL
    }
    
    public init(imageName : String, thumbName : String) {
        self.imageURL = Bundle.main.url(forResource: imageName, withExtension: "")!
        self.thumbURL = Bundle.main.url(forResource: thumbName, withExtension: "")!
    }
}

public struct TICFont
{
    var title : String
    var fontFamily : String
    
    public init(title : String, fontFamily : String) {
        self.title = title
        self.fontFamily = fontFamily
    }
}
