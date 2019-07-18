//
//  JDCapture.h
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ZXingObjC/ZXBarcodeFormat.h>
#import "JDScanResult.h"
#import "JDCaptureDelegate.h"

@interface JDCapture : NSObject <CAAction>

/**
 摄像头 0:后置摄像头 1:前置摄像头
 */
@property (nonatomic, assign) int camera;

@property (nonatomic, strong) AVCaptureDevice *captureDevice;

@property (nonatomic, weak) id<JDCaptureDelegate> delegate;

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
- (NSError *)start;

/**
 停止扫描
 */
- (void)stop;

/**
 自动对焦
 */
- (void)autoFocus;

/**
 识别码

 @param image 图片
 @param invert 是否反转
 @return 识别的结果
 */
+ (NSArray *)recognizeImage:(CGImageRef)image invert:(BOOL)invert;


/**
 创建码

 @param str 字符串
 @param size z尺寸
 @param format 格式
 @return 码图片
 */
+ (UIImage *)generateCodeWithString:(NSString*)str size:(CGSize)size codeFomart:(ZXBarcodeFormat)format;

@end
