#
# Be sure to run `pod lib lint YZTAlphaLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YZTAlphaLib'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YZTAlphaLib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zeasy/YZTAlphaLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zeasy@qq.com' => 'zhuyi535@pingan.com.cn' }
   s.source           = { :git => 'https://github.com/zeasy/YZTAlphaLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = ['YZTAlphaLib/Classes/**/*','YZTAlphaLib/YZTAlpha/**/*.{h,m}']
  
  # s.resource_bundles = {
  #   'YZTAlphaLib' => ['YZTAlphaLib/Assets/*.png']
  # }
  


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'YZTAlphaLib/YZTAlpha'

  s.dependency  'Alpha/Interface'
  s.dependency  'Alpha/Screenshot'
  s.dependency  'Alpha/Trigger'
  s.dependency  'Alpha/File'
end
