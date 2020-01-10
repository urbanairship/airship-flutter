
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

require 'yaml'

package = YAML.load_file("#{__dir__}/../pubspec.yaml")
sync_version = `#{__dir__}/../scripts/sync_version.sh #{package["version"]}`

Pod::Spec.new do |s|
  s.name             = 'airship_flutter'
  s.version          = '2.0.0'
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
  s.dependency              'Airship', '~> 13.0.4'
end

