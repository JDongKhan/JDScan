/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <AVFoundation/AVFoundation.h>
//#import "ZXResult.h"
#import "JDZXCaptureDelegate.h"
#import <ZXingObjC/ZXBarcodeFormat.h>

@protocol JDZXCaptureDelegate, ZXReader;
@class ZXDecodeHints;

@interface JDCaptureResult: NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) ZXBarcodeFormat type;
@property (nonatomic, strong) UIImage *image;
@end


@interface JDZXCapture : NSObject <CAAction>

/**
 摄像头 1:后置摄像头 0:前置摄像头
 */
@property (nonatomic, assign) int camera;

@property (nonatomic, strong) AVCaptureDevice *captureDevice;

@property (nonatomic, weak) id<JDZXCaptureDelegate> delegate;
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
@property (nonatomic, assign) BOOL invert;
@property (nonatomic, strong, readonly) CALayer *layer;
@property (nonatomic, assign) BOOL mirror;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign, readonly) BOOL running;
@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, assign) BOOL torch;
@property (nonatomic, assign) CGAffineTransform transform;

- (int)back;
- (int)front;
- (BOOL)hasBack;
- (BOOL)hasFront;
- (BOOL)hasTorch;

- (void)setTorch:(BOOL)torch;

- (void)changeTorch;

- (CALayer *)binary;
- (void)setBinary:(BOOL)on_off;

- (CALayer *)luminance;
- (void)setLuminance:(BOOL)on_off;

- (void)hard_stop;
- (void)order_skip;
- (void)start;
- (void)stop;

- (void)autoFocus;

+ (JDCaptureResult *)recognizeImage:(CGImageRef)image invert:(BOOL)invert;
+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format;

@end
