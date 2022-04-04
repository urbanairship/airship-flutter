
AIRSHIP_FLUTTER_VERSION="5.4.0"

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'airship_flutter'
  s.version          = AIRSHIP_FLUTTER_VERSION
  s.summary          = 'A flutter plugin for Airship.'
  s.description      = <<-DESC
Airship flutter plugin.
                       DESC
  s.homepage         = 'http://airship.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Airship' => 'support@airship.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target   = "11.0"
  s.dependency              'Airship/Core', '~> 16.5.1'
  s.dependency              'Airship/MessageCenter', '~> 16.5.1'
  s.dependency              'Airship/Automation', '~> 16.5.1'
  s.dependency              'Airship/PreferenceCenter', '~> 16.5.1'
end

