Pod::Spec.new do |s|

  s.name          = "JMSWebViewController"
  s.version       = "2.0.1"
  s.license       = "MIT"
  s.summary       = "Use Swift encapsulation WKWebView."
  s.homepage      = "https://github.com/James-swift/JMSWebViewController"
  s.author        = { "xiaobs" => "1007785739@qq.com" }
  s.source        = { :git => "https://github.com/James-swift/JMSWebViewController.git", :tag => "2.0.1" }
  s.requires_arc  = true
  s.description   = <<-DESC
                   JMSWebViewController - Use Swift encapsulation WKWebView.
                   DESC
  s.source_files  = "JMSWebViewController/*"
  s.platform      = :ios, '8.0'
  s.framework     = 'Foundation', 'UIKit'  
  s.dependency "JMSNavBackButtonHandler", "~> 1.0.2"

end
