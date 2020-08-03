#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint qiscus_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'qiscus_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Qiscus Chat SDK plugin for iOS and Android'
  s.description      = <<-DESC
Qiscus Chat SDK plugin for iOS and Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.dependency 'QiscusCore',  '1.5.1'
  s.dependency 'SQLite.swift', '~> 0.12.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
