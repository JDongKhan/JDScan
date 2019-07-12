Pod::Spec.new do |s|
    s.name         = 'JDScan'
    s.version      = '1.0'
    s.summary      = 'ios opencv zxing scan wrapper'
    s.homepage     = 'https://github.com/wangjindong'
    s.license      = 'MIT'
    s.authors      = {'WJD' => '419591321@qq.com'}
#    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/wangjindong/JDScan.git', :tag => s.version}
    s.requires_arc = true
#    s.prefix_header_contents = '#import <Foundation/Foundation.h>'
    s.ios.deployment_target = '8.0'

    s.default_subspec = 'All'

    s.subspec 'ZXing' do |zxing|
      zxing.source_files = 'JDScan/ZXing/**/*.{h,m,mm}'
#      zxing.ios.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'ImageIO', 'QuartzCore'
#      zxing.prefix_header_contents = '#import "JDZXingWrapper.h"'
      zxing.vendored_frameworks  = 'JDScan/Frameworks/*.framework'
      zxing.libraries = 'c++','c','c++abi'
      zxing.dependency 'ZXingObjC', '3.1.1'
    end
  
    s.subspec 'UI' do |ui|
      ui.source_files = 'JDScan/UI/*.{h,m}'
      ui.resource     = 'JDScan/UI/CodeScan.bundle'
#      ui.prefix_header_contents = '#import "JDScanView.h"'
    end
    
    s.subspec 'All' do |all|
       all.dependency 'JDScan/ZXing'
       all.dependency 'JDScan/UI'
    end

    
end
