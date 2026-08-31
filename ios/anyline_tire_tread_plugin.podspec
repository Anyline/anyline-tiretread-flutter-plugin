#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint anyline_tire_tread_plugin.podspec` to validate before publishing.
#

# Single source of truth for the bundled AnylineTireTreadSdk. The checksum is the
# SHA-256 of the xcframework archive, and matches the one published in the SDK's
# Package.swift. Both lines are updated together at release time — keep adjacent.
anyline_ttr_sdk_version  = '15.5.0'
anyline_ttr_sdk_checksum = '16835a6b486db7bef1fc939042db072f5101b6b318eee2f67b1702068ea0ab22'

Pod::Spec.new do |s|
  s.name             = 'anyline_tire_tread_plugin'
  s.version          = '15.5.0'
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

  # The Anyline Tire Tread SDK is vendored as a prebuilt xcframework fetched at
  # `pod install` rather than resolved as a CocoaPods dependency. See
  # fetch_anyline_sdk.sh for the download, checksum check and caching.
  s.vendored_frameworks = 'AnylineTireTreadSdk.xcframework'
  s.preserve_paths = 'fetch_anyline_sdk.sh'
  s.prepare_command = "sh fetch_anyline_sdk.sh #{anyline_ttr_sdk_version} #{anyline_ttr_sdk_checksum}"

  s.platform = :ios, '13.4'
  s.ios.deployment_target = '13.4'
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
