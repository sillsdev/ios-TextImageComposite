Pod::Spec.new do |s|
  s.name             = 'TextImageComposite'
  s.version          = '0.1.0'
  s.summary          = 'Text formatter that saves a composite image'
  s.description      = <<-DESC
TextImageComposite is a tool to create a single, sharable image composite of Text on top of an image. Initially designed for sharing scripture verses on images for apps created with Scripture App Builder
                       DESC

  s.platform 		 = :ios, '9.0'

  s.homepage         = 'https://github.com/sillsdev/ios-TextImageComposite.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Jacob Bullock' => 'jacob.bullock@gmail.com' }
  s.source           = { :git => 'https://github.com/sillsdev/ios-TextImageComposite', :tag => s.version.to_s }
 
  s.source_files 	= 'TICExample/TextImageComposite/*.swift', 'TICExample/TextImageComposite/Lib/ElevenK/*.swift'
  s.resources 		= 'TICExample/TextImageComposite/Resources/Images/**/*.*', 'TICExample/TextImageComposite/*.storyboard'
end