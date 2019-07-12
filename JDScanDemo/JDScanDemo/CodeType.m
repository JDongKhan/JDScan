//
//  CodeType.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "CodeType.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@implementation CodeType

+ (instancetype)sharedManager {
    static CodeType* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CodeType alloc] init];
        _sharedInstance.scanCodeType = JDScanCodeTypeQRCode;
    });
    
    return _sharedInstance;
}

- (NSString*)nativeCodeType {
    return [self nativeCodeWithType:_scanCodeType];
}

- (NSString*)nativeCodeWithType:(JDScanCodeType)type {
    switch (type) {
        case JDScanCodeTypeQRCode:
            return AVMetadataObjectTypeQRCode;
            break;
        case JDScanCodeTypeBarCode93:
            return AVMetadataObjectTypeCode93Code;
            break;
        case JDScanCodeTypeBarCode128:
            return AVMetadataObjectTypeCode128Code;
            break;
        case JDScanCodeTypeBarCodeITF:
            return @"ITF条码:only ZXing支持";
            break;
        case JDScanCodeTypeBarEAN13:
            return AVMetadataObjectTypeEAN13Code;
            break;
            
        default:
            return AVMetadataObjectTypeQRCode;
            break;
    }
}

- (NSArray*)nativeTypes {
    return @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,@"ITF(只有ZXing支持)",AVMetadataObjectTypeEAN13Code];
}


@end
