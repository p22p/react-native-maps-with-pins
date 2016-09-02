Pod::Spec.new do |s|
  s.name         = "react-native-maps"
  s.version      = "0.8.2"
  s.summary      = "React Native Mapview component for iOS + Android"

  s.authors      = { "intelligibabble" => "leland.m.richardson@gmail.com" }
  s.homepage     = "https://github.com/lelandrichardson/react-native-maps#readme"
  s.license      = "MIT"
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/lelandrichardson/react-native-maps.git" }
  s.source_files  = "ios/AirMaps/**/*.{h,m}"

  s.dependency 'React'
  s.dependency 'GoogleMaps', '2.0.1'

  # s.frameworks  = 'CoreLocation', 'CoreText', 'CoreGraphics', 'QuartzCore', 'UIKit', 'MapKit'

  #def s.post_install(target)
  #  puts("-----> #{target.name}")
  #end

  #post_install do |installer|
  #  installer.pods_project.targets.each do |target|
  #  target.build_configurations.each do |config|
  #        config.build_settings['CLANG_ENABLE_MODULES'] = 'NO'
  #    end
  #  end
  #end
end
