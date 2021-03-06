#
# Be sure to run `pod lib lint samplePod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'samplePod'
  s.version          = '0.1.7'
  s.summary          = 'This is a testing pod'
  s.swift_version    = '4.2'
  s.platform         = :ios

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Mayuramipara94/samplePod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  
  
  s.screenshots  = "https://wallpaperbrowse.com/media/images/pexels-photo-248797.jpeg"

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mayuramipara94' => 'mayur.amipara@coruscate.co.in' }
  s.source           = { :git => 'https://github.com/Mayuramipara94/samplePod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "4.2" }
  s.requires_arc = true

  s.source_files = 'samplePod/Classes/**/*'
  
  # s.resource_bundles = {
  #   'samplePod' => ['samplePod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Alamofire'
end
