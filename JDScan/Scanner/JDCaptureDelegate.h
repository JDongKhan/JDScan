//
//  JDCaptureDelegate.h
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import "JDScanResult.h"

@class JDCapture;

@protocol JDCaptureDelegate <NSObject>

- (void)captureResult:(JDCapture *)capture result:(NSArray<JDScanResult *> *)result;

@optional

- (void)captureCameraIsReady:(JDCapture *)capture;

- (void)captureResult:(JDCapture *)capture preImage:(UIImage *)preImage;

@end
