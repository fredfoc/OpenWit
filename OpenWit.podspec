#
# Be sure to run `pod lib lint OpenWit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OpenWit'
  s.version          = '0.1.1'
  s.summary          = 'swift framework for Wit© HTTP API.'
  s.description      = <<-DESC
This Pod is an intent to get a swift framework for Wit.ai© HTTP API.
You can find more information about Wit on: https://wit.ai and https://wit.ai/docs/http/20160526
Wit© is an amazing NLP api wher you can define stories (at the time of this writing they are in beta). It does speech recognition, converse, message analyse, can learn to understand what you want and many more things.
This library is a first version where you can analyse a message and converse (speech is actually not fully implemented but should be soon).
It requires Moya and ObjectMapper.
                       DESC

  s.homepage         = 'https://github.com/fredfoc/OpenWit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fauquette fred' => 'fredfocmac@gmail.com' }
  s.source           = { :git => 'https://github.com/fredfoc/OpenWit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/FredFauquette'

  s.ios.deployment_target = '9.0'

  s.source_files = 'OpenWit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OpenWit' => ['OpenWit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreAudio'
  s.dependency 'Moya-ObjectMapper', '2.2.1'
end
