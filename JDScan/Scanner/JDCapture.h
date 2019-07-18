//
//  JDCapture.h
//  JDScanner
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ZXingObjC/ZXBarcodeFormat.h>
#import "JDScanResult.h"
#import "JDCaptureDelegate.h"

@interface JDCapture : NSObject <CAAction>

/*!
 摄像头 0:后置摄像头 1:前置摄像头
 */
@property (nonatomic, assign) int camera;

/*!
 设备对象
 */
@property (nonatomic, strong, readonly) AVCaptureDevice *captureDevice;

/*!
 委托
 */
@property (nonatomic, weak) id<JDCaptureDelegate> delegate;

/**/
@property (nonatomic, assign) BOOL invert;

/*!
 layer
 */
@property (nonatomic, strong, readonly) CALayer *layer;

/*!
 处理图片时翻转度数
 */
@property (nonatomic, assign) CGFloat rotation;

/*!
 是否正在扫描
 */
@property (nonatomic, assign, readonly) BOOL running;


/*!
 使用zxing扫描时的扫描区域
 */
@property (nonatomic, assign) CGRect zxingRect;

/*!
 使用native扫描时的扫描区域
 */
@property (nonatomic, assign) CGRect nativeRect;

/*!
 session的清晰度
 可选值:
 AVCaptureSessionPresetHigh,
 AVCaptureSessionPresetMedium,
 AVCaptureSessionPresetLow,
 AVCaptureSessionPreset320x240,
 AVCaptureSessionPreset352x288,
 AVCaptureSessionPreset640x480,
 AVCaptureSessionPreset960x540,
 AVCaptureSessionPreset1280x720,
 AVCaptureSessionPreset1920x1080,
 AVCaptureSessionPreset3840x2160
 */
@property (nonatomic, copy) NSString *sessionPreset;

/*!
 是否开启灯光
 */
@property (nonatomic, assign) BOOL torch;

/**
 CGAffineTransform
 */
@property (nonatomic, assign) CGAffineTransform transform;

/*!
 后置摄像头
 */
- (int)back;

/*!
 前置摄像头
 */
- (int)front;

/*!
 是否有后置摄像头
 */
- (BOOL)hasBack;

/*!
 是否有前置摄像头
 */
- (BOOL)hasFront;

/*!
 是否能打开灯光
 */
- (BOOL)hasTorch;

/*!
 灯光操作
 */
- (void)setTorch:(BOOL)torch;
- (void)changeTorch;

/**
 强制停止，停止后就不能start了
 */
- (void)hard_stop;

- (void)order_skip;

/*!
 开始扫描
 */
- (NSError *)start;

/*!
 停止扫描
 */
- (void)stop;

/*!
 自动对焦
 */
- (void)autoFocus;

/*!
 识别码

 @param image 图片
 @param invert 是否反转
 @return 识别的结果
 */
+ (NSArray *)recognizeImage:(CGImageRef)image invert:(BOOL)invert;


/*!
 创建码

 @param str 字符串
 @param size 尺寸
 @param format 格式
 @return 码图片
 */
+ (UIImage *)generateCodeWithString:(NSString*)str size:(CGSize)size codeFomart:(ZXBarcodeFormat)format;

@end
