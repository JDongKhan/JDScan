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
#import <ZXingObjC/ZXBarcodeFormat.h>
#import "JDScanResult.h"
#import "JDZXCaptureDelegate.h"

@protocol JDZXCaptureDelegate, ZXReader;
@class ZXDecodeHints;

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


//扫描区域
@property (nonatomic, assign) CGRect zxingRect;
@property (nonatomic, assign) CGRect nativeRect;

@property (nonatomic, copy) NSString *sessionPreset;
//是否开启灯光
@property (nonatomic, assign) BOOL torch;
@property (nonatomic, assign) CGAffineTransform transform;

- (int)back;
- (int)front;
- (BOOL)hasBack;
- (BOOL)hasFront;
- (BOOL)hasTorch;

- (CALayer *)binary;
- (void)setBinary:(BOOL)on_off;

- (CALayer *)luminance;
- (void)setLuminance:(BOOL)on_off;


/**
 灯光操作
 */
- (void)setTorch:(BOOL)torch;
- (void)changeTorch;


/**
 强制停止，停止后就不能start了
 */
- (void)hard_stop;

- (void)order_skip;


/**
 开始扫描
 */
- (void)start;

/**
 停止扫描
 */
- (void)stop;

/**
 自动对焦
 */
- (void)autoFocus;

/**
 识别二维码

 @param image 图片
 @param invert 是否反转
 @return 识别的结果
 */
+ (JDScanResult *)recognizeImage:(CGImageRef)image invert:(BOOL)invert;


/**
 创建二维码

 @param str 字符串
 @param size z尺寸
 @param format 格式
 @return 二维码图片
 */
+ (UIImage *)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format;

@end
