Pod::Spec.new do |s|
  s.name             = 'TextImageComposite'
  s.version          = '0.1.0'
  s.summary          = 'Text formatter that saves a composite image'
  s.description      = <<-DESC
TextImageComposite is a tool to create a single, sharable image composite of Text on top of an image. Initially designed for sharing scripture verses on images for apps created with Scripture App Builder.  Inspired by the YouVersion iOS implementation of a similar feature.
                       DESC

  s.platform 		 = :ios, '8.0'

  s.homepage         = 'https://github.com/sillsdev/ios-TextImageComposite'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Jacob Bullock' => 'jacob.bullock@gmail.com' }
  s.source           = { :git => 'https://github.com/sillsdev/ios-TextImageComposite.git', :tag => s.version.to_s }
 
  s.source_files 	= 'TextImageComposite/*.swift', 'TextImageComposite/Lib/ElevenK/*.swift'
  s.resource_bundles = {
    'TextImageComposite' => ['TextImageComposite/Resources/Images/**/*.{jpg,png}', 'TextImageComposite/*.storyboard', 'TextImageComposite/Resources/HTML/*.{html,js}', 'TextImageComposite/XIB/*.xib']
  }
end