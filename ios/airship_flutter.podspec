
AIRSHIP_FLUTTER_VERSION="9.1.0"

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
  s.source_files = 'airship_flutter/Sources/airship_flutter/**/*'
  s.public_header_files = 'airship_flutter/Sources/airship_flutter/obj-c/**/*.h'
  s.dependency 'Flutter'
  s.ios.deployment_target      = "14.0"
  s.dependency "AirshipFrameworkProxy", "11.1.0"
  s.swift_version = "5.0.0"
  s.resource_bundles = {'airship_flutter_privacy' => ['airship_flutter/Sources/airship_flutter/swift/PrivacyInfo.xcprivacy']}
end

