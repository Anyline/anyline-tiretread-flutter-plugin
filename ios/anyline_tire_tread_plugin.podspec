#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint anyline_tire_tread_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'anyline_tire_tread_plugin'
  s.version          = '2.0.0'
  s.summary          = 'The Anyline Tire Tread Flutter Plugin allows you to measure tire tread depth and wear with a mobile device.'
  s.description      = <<-DESC
The Anyline Tire Tread Flutter Plugin allows you to measure tire tread depth and wear with a mobile device.
                       DESC
  s.homepage         = 'http://anyline.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Anyline GmbH' => 'capture-team@anyline.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AnylineTireTreadSdk', '13.0.2'
  s.platform = :ios, '16.4'
  s.ios.deployment_target = '16.4'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'anyline_tire_tread_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
