Pod::Spec.new do |s|
  s.name             = 'interaction_foundation'
  s.version          = '0.1.0'
  s.summary          = 'Typed interaction sound and haptic runtime.'
  s.description      = <<-DESC
Cross-platform interaction feedback bridge with native iOS sound and haptics.
                       DESC
  s.homepage         = 'https://github.com/axrbarsic/MargaritavilleFlutter'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Alex' => 'alex@example.invalid' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.resource_bundles = {
    'interaction_foundation_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
end
