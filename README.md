# TextImageComposite
![Language](https://img.shields.io/badge/language-Swift%203.2-orange.svg)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sillsdev/ios-TextImageComposite/blob/master/LICENSE.md)


# Features
TextImageComposite is a tool to create a single, sharable image composite of text on top of an image.

Inspired by [YouVersion](https://www.youversion.com)'s iOS implementation.  

Users can edit:

* Font
* Font Size
* Text Color
* Line Height
* Letter Spacing
* Top / Left / Right Margins
* Alignment
* Color
* Brightness
* Opacity
* Blur

# Requirements
* Swift 3.2
* iOS 8.0+

# Cocoa Keys
iOS 10.0+
* NSPhotoLibraryAddUsageDescription

# Installation

    use_frameworks!
    platform :ios, '8.0'

    target “<TARGET>” do
        pod 'TextImageComposite’
    end

# Customizing
### Images
Images are added to the configuration through **TICImage**.  You will need to specify a high-res image and a thumbnail image.  All images in the example are sourced from [pexels.com](http://pexels.com)

### Fonts
By default *Helvetica* is the only option. You can add more by passing by creating an array of **TICFont**

### Localization
You can pass in a set of strings in the struct **TICLocalization**

### Theme
You can pass in an instance of **TICTheme** to specify colors

# Usage

	TICConfig.instance.text = "In the beginning, God created the heavens and the earth."
	TICConfig.instance.reference = "Genesis 1:1"
	let storyboard = UIStoryboard(name: "TIC", bundle: TICConfig.instance.bundle)
	let nvc = storyboard.instantiateViewController(withIdentifier: "TICNavController") as! UINavigationController
	
	present(nvc, animated: true, completion: nil)

# Icons

All in app icons were created using [fa2png](http://fa2png.io) and can be found in **TextImageComposite/Resources/Images/icons**
