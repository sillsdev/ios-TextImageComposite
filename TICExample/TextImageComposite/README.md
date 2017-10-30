
TextImageComposite is a tool to create a single, sharable image composite of Text on top of a specificed Image

Users can edit:
    Font
    Font Size
    Text Color
    Line Height
    Letter Spacing
    
    Color
    Brightness
    Opacity
    
    Alignment
    Margins
    
    Blur

Configuration of the editor can be controlled via the singleton TICConfig (see example project)


Default Resources
    There are 15 default images included.  8 Nature themed and 7 textrues
    More images can be provided by creating instances of TICImage

    There is only a single font included: Andika
    More fonts can be provided by creating instances of TICFont
    

Presenting the Editor

After updating the configuration, you can present the editor

let storyboard = UIStoryboard(name: "TIC", bundle: nil)
let nvc = storyboard.instantiateViewController(withIdentifier: "TICNavController") as! UINavigationController

present(nvc, animated: true, completion: nil)

All in app icons were created using http://fa2png.io and can be found in Resources/TICIcons.xcassets

Build Requirements:
Must add *NSPhotoLibraryUsageDescription* in Info.plist. This key is required to save photos to the camera roll for iOS 10+
