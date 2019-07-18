//
//  JDZXDetectorHook.h
//  JDScanner
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//


#import "JDZXDetectorHook.h"
#import <objc/runtime.h>
#import <ZXingObjC/ZXingObjC.h>
#import <AVFoundation/AVFoundation.h>

#define MaxBarcodeModuleSize   8.0f

@implementation ZXQRCodeDetector (hook)

//自动缩放
- (ZXDetectorResult *)rep_processFinderPatternInfo:(ZXQRCodeFinderPatternInfo *)info error:(NSError **)error {
    
    ZXQRCodeFinderPattern *topLeft = info.topLeft;
    ZXQRCodeFinderPattern *topRight = info.topRight;
    ZXQRCodeFinderPattern *bottomLeft = info.bottomLeft;
    float moduleSize = [self calculateModuleSize:topLeft topRight:topRight bottomLeft:bottomLeft];
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![captureDevice isRampingVideoZoom] && moduleSize < MaxBarcodeModuleSize) {
        NSError *cerror = nil;
        [captureDevice lockForConfiguration:&cerror];
        CGFloat videoMaxZoomFactor = 2.5f;
        if (captureDevice.activeFormat.videoMaxZoomFactor < videoMaxZoomFactor) {
            videoMaxZoomFactor = captureDevice.activeFormat.videoMaxZoomFactor;
        }
        [captureDevice rampToVideoZoomFactor:videoMaxZoomFactor withRate:6.0f];
        [captureDevice unlockForConfiguration];
    }
    
    return [self rep_processFinderPatternInfo:info error:error];
}

@end

@implementation JDZXDetectorHook

+ (void)startHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod([ZXQRCodeDetector class], @selector(processFinderPatternInfo:error:));
        Method repMethod = class_getInstanceMethod([ZXQRCodeDetector class], @selector(rep_processFinderPatternInfo:error:));
        method_exchangeImplementations(oriMethod, repMethod);
    });
}

@end
