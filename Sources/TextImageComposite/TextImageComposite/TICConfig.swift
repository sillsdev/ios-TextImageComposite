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
    public var active: Bool             = false
    
    public var selectedImage : UIImage?
    public var selectedURL : URL?
    
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

}

public struct TICTheme {
    var backgroundColor: UIColor!
    var contrastColor: UIColor!
    var accentColor: UIColor!
    var tintColor: UIColor!
    var highlightColor: UIColor!
    var buttonBackgroundColor: UIColor!
    var viewBackgroundColor: UIColor!
    
    public init(backgroundColor: UIColor, contrastColor: UIColor, accentColor: UIColor, tintColor: UIColor, highlightColor: UIColor, buttonBackgroundColor: UIColor, viewBackgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.contrastColor = contrastColor
        self.accentColor = accentColor
        self.tintColor = tintColor
        self.highlightColor = highlightColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.viewBackgroundColor = viewBackgroundColor
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
        navbar.tintColor = UIColor.white
        navbar.barTintColor = self.contrastColor
        navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:self.accentColor as Any]
    }
    
    static public func defaultTheme() -> TICTheme {
        var theme = TICTheme()
        theme.backgroundColor = UIColor.colorWithHex("EEEEEE") //
        theme.tintColor = UIColor.colorWithHex("7cb55d") //
        theme.accentColor = UIColor.colorWithHex("888888") //
        theme.contrastColor = UIColor.colorWithHex("FFFFFF") //
        theme.highlightColor = UIColor.colorWithHex("d1d2d1")
        theme.buttonBackgroundColor = UIColor.init(red: 0.820, green: 0.820, blue: 0.839, alpha: 1) // systemGray4
        theme.viewBackgroundColor = UIColor.init(red: 0.933, green: 0.933, blue: 0.933, alpha: 1) //
        
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

        return theme
    }
}

public struct TICLocalization
{
    var cancel: String!
    var ok: String!
    var share: String!
    var done: String!
    
    public init(cancel: String, ok: String, share: String, done: String) {
        self.cancel = cancel
        self.ok = ok
        self.share = share
        self.done = done
    }
    public init() {
        
    }
    static public func us_en() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Cancel"
        locale.ok = "OK"
        locale.share = "Share"
        locale.done = "Done"
        
        return locale
    }
    
    static public func lorem() -> TICLocalization {
        var locale = TICLocalization()
        locale.cancel = "Lorem"
        locale.ok = "KO"
        locale.share = "Sit"
        locale.done = "Pol"
        
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
    
    public init(title : String, fontFamily : String) {
        self.title = title
        self.fontFamily = fontFamily
    }
}
