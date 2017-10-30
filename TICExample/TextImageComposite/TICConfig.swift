//
//  TICImages.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

class TICConfig
{
    static let instance = TICConfig()
    
    public var text : String = ""
    public var reference : String = ""
    public var images : [TICImage] = []
    public var fonts : [TICFont] = []
    public var locale : TICLocalization = TICLocalization.us_en()
    public var theme : TICTheme = TICTheme.defaultTheme()
    
    public var imageUrl : URL?
    
    /*
    init(text : String, reference : String, images : [TICImage], fonts : [TICFont])
    {
        self.text = text
        self.reference = reference
        self.images = images
        self.fonts = fonts
    }
 */
}

struct TICTheme
{
    //backgroundColor, accentColor, tertiaryColor, textColor, buttonColor
    
    var backgroundColor : UIColor!
    var textColor : UIColor!
    
    //navbar
    var navbarBackgroundColor : UIColor!
    var navbarTintColor : UIColor!
    var navbarTextColor : UIColor!
    
    //main toolbar area
    var toolbarBackgroundColor : UIColor!
    var toolbarItemColor : UIColor!
    var toolbarSelectedItemColor : UIColor!
    var toolbarSelectedItemBackgroundColor : UIColor!
    
    //font selection
    var fontItemColor : UIColor!
    var fontItemSelectedColor : UIColor!
    
    //buttons that prompt new menus
    var actionButtonColor : UIColor!
    
    //buttons that have a selectable state such as the alignment options
    var optionButtonColor : UIColor!
    var selectedOptionButtonColor : UIColor!
    
    //basic UIKit tint
    var tintColor : UIColor!
    var accentTintColor : UIColor!
    var tertiaryTintColor : UIColor!
    
    func formatControl(_ control : UIControl)
    {
        control.tintColor = self.tintColor
        
        if let slider = control as? UISlider
        {
            slider.thumbTintColor = self.tertiaryTintColor
            slider.maximumTrackTintColor = self.accentTintColor
        }
    }
    
    func formatToolbarButton(_ button : UIButton)
    {
        if(button.isSelected)
        {
            button.backgroundColor = self.toolbarSelectedItemBackgroundColor
            button.tintColor = self.toolbarSelectedItemColor
        }
        else
        {
            button.backgroundColor = self.toolbarBackgroundColor
            button.tintColor = self.toolbarItemColor
        }
    }
    
    func formatLabel(_ label : UILabel)
    {
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: 13)
    }
    
    func formatView(_ view :UIView)
    {
        view.backgroundColor = backgroundColor
    }
    
    func formatNavbar(_ navbar : UINavigationBar)
    {
        //let navbarFont =  UIFont(name: "Andika New Basic", size: 17)
        navbar.tintColor = self.navbarTintColor
        navbar.barTintColor = self.navbarBackgroundColor
        //NSFontAttributeName: navbarFont!,
        navbar.titleTextAttributes = [NSForegroundColorAttributeName:self.navbarTextColor]
    }
    
    static func defaultTheme() -> TICTheme
    {
        var theme = TICTheme()
        
        theme.navbarTintColor = .blue
        theme.navbarBackgroundColor = .white
        theme.navbarTextColor = .darkGray
        
        theme.backgroundColor = UIColor.colorWithHex("EEEEEE")
        theme.textColor = .darkText
        
        theme.fontItemColor = .gray
        theme.fontItemSelectedColor = .black
        
        theme.toolbarBackgroundColor = .lightGray
        theme.toolbarItemColor = .white
        theme.toolbarSelectedItemColor = .darkGray
        theme.toolbarSelectedItemBackgroundColor = .blue
        
        theme.actionButtonColor = .darkGray
        
        theme.optionButtonColor = .darkGray
        theme.selectedOptionButtonColor = .blue
        
        theme.tintColor = .blue
        theme.accentTintColor = .lightGray
        theme.tertiaryTintColor = .white

        return theme
    }
    
    static func wackyTheme() -> TICTheme
    {
        var theme = TICTheme()
        
        theme.navbarTintColor = .red
        theme.navbarBackgroundColor = .blue
        theme.navbarTextColor = .white
        
        theme.backgroundColor = .red
        theme.textColor = .green
        
        theme.fontItemColor = .blue
        theme.fontItemSelectedColor = .green
        
        theme.toolbarBackgroundColor = .blue
        theme.toolbarItemColor = .brown
        theme.toolbarSelectedItemColor = .yellow
        theme.toolbarSelectedItemBackgroundColor = .green
        
        theme.actionButtonColor = .purple
        
        theme.optionButtonColor = .orange
        theme.selectedOptionButtonColor = .yellow
        
        theme.tintColor = .yellow
        theme.accentTintColor = .green
        theme.tertiaryTintColor = .brown
        
        return theme
    }
    
}

struct TICLocalization
{
    var cancel : String!
    var chooseImage : String!
    var save : String!
    var share : String!
    var size : String!
    var blur : String!
    var customize : String!
    var margins : String!
    var opacity : String!
    var top : String!
    var left : String!
    var right : String!
    var lineHeight : String!
    var letterSpacing : String!
    
    static func us_en() -> TICLocalization
    {
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
        
        return locale
    }
    
    static func lorem() -> TICLocalization
    {
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
        
        return locale
    }
}

struct TICImage
{
    var imageURL : URL
    var thumbURL : URL
    
    init(imageURL : URL, thumbURL : URL) {
        self.imageURL = imageURL
        self.thumbURL = thumbURL
    }
    
    init(imageName : String, thumbName : String)
    {
        self.imageURL = Bundle.main.url(forResource: imageName, withExtension: "")!
        self.thumbURL = Bundle.main.url(forResource: thumbName, withExtension: "")!
    }
}

struct TICImages
{
    let s = TICImage.init(imageName: "texture_1.jpg", thumbName: "thumb_texture_1.jpg")
    
    static public let textureImageUrls : [TICImage] = [TICImage.init(imageName: "texture_1.jpg", thumbName: "thumb_texture_1.jpg"),
                                                       TICImage.init(imageName: "texture_2.jpg", thumbName: "thumb_texture_2.jpg"),
                                                       TICImage.init(imageName: "texture_3.jpg", thumbName: "thumb_texture_3.jpg"),
                                                       TICImage.init(imageName: "texture_4.jpg", thumbName: "thumb_texture_4.jpg"),
                                                       TICImage.init(imageName: "texture_5.jpg", thumbName: "thumb_texture_5.jpg"),
                                                       TICImage.init(imageName: "texture_6.jpg", thumbName: "thumb_texture_6.jpg"),
                                                       TICImage.init(imageName: "texture_7.jpg", thumbName: "thumb_texture_7.jpg"),]
    
    static public let natureImageUrls : [TICImage] = [TICImage.init(imageName: "nature_1.jpg", thumbName: "thumb_nature_1.jpg"),
                                                      TICImage.init(imageName: "nature_2.jpg", thumbName: "thumb_nature_2.jpg"),
                                                      TICImage.init(imageName: "nature_3.jpg", thumbName: "thumb_nature_3.jpg"),
                                                      TICImage.init(imageName: "nature_4.jpg", thumbName: "thumb_nature_4.jpg"),
                                                      TICImage.init(imageName: "nature_5.jpg", thumbName: "thumb_nature_5.jpg"),
                                                      TICImage.init(imageName: "nature_6.jpg", thumbName: "thumb_nature_6.jpg"),
                                                      TICImage.init(imageName: "nature_7.jpg", thumbName: "thumb_nature_7.jpg"),
                                                      TICImage.init(imageName: "nature_8.jpg", thumbName: "thumb_nature_8.jpg")]
    
    static public let allImages : [TICImage] = textureImageUrls + natureImageUrls
}

struct TICFont
{
    var title : String
    var fontFamily : String
    
    init(title : String, fontFamily : String) {
        self.title = title
        self.fontFamily = fontFamily
    }
}

struct TICFonts
{
    static public let andikaFont = TICFont.init(title : "Andika", fontFamily: "Andika New Basic")
}
