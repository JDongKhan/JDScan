Pod::Spec.new do |spec|
    spec.name         = 'JDScan'
    spec.version      = '2.0' 
    spec.summary      = 'ios opencv zxing scan wrapper'
    spec.homepage     = 'https://github.com/JDongKhan'
    spec.license      = 'MIT'
    spec.authors      = {'WJD' => '419591321@qq.com'}
    spec.platform     = :ios, '8.0'
    spec.source       = {:git => 'https://github.com/JDongKhan/JDScan.git', :tag => spec.version}
    spec.requires_arc = true
#    spec.prefix_header_contents = '#import <Foundation/Foundation.h>'
    spec.ios.deployment_target = '8.0'

    spec.default_subspec = 'UI'

    spec.subspec 'ZXing' do |zxing|
      zxing.source_files = 'JDScan/ZXing/**/*.{h,m,mm}'
#      zxing.ios.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'ImageIO', 'QuartzCore'
#      zxing.prefix_header_contents = '#import "JDZXingWrapper.h"'
      zxing.vendored_frameworks  = 'JDScan/Frameworks/*.framework'
      zxing.libraries = 'c++','c','c++abi'
      zxing.dependency 'ZXingObjC', '~> 3.6.5'
    end
  
    spec.subspec 'UI' do |ui|
      ui.source_files = 'JDScan/UI/*.{h,m}'
      ui.resource     = 'JDScan/UI/CodeScan.bundle'
      ui.dependency 'JDScan/ZXing'
#      ui.prefix_header_contents = '#import "JDScanView.h"'
    end
    
end
