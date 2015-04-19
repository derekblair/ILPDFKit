
Pod::Spec.new do |s|

s.name         = "ILPDFKit"
s.version      = "0.1.1"
s.summary      = "A simple toolkit for filling out and saving PDF forms, and extracting PDF data."
s.homepage     = "http://ilpdfkit.com"
s.screenshot  = "http://imgur.com/oo5HLUg.png"
s.license      = "MIT"
s.author       = { "Derek Blair" => "derekjblair@gmail.com" }
s.platform     = :ios
s.ios.deployment_target = "7.0"
s.source  = { :git => "https://github.com/iwelabs/ILPDFKit.git", :tag => "0.1.1" }
s.source_files  = "ILPDFKit/**/*.{h,m}"
s.frameworks = "QuartzCore", "UIKit"
s.requires_arc = true
s.documentation_url = 'http://ilpdfkit.com/index.html'

end
