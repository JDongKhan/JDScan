//
//  JDZXingWrapper.m
//
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import "JDZXingWrapper.h"
#import "JDZXCaptureDelegate.h"
#import "JDZXCapture.h"
#import <ZXingObjC/ZXResult.h>


typedef void(^JDScanBlock)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg);

@interface JDZXingWrapper() <JDZXCaptureDelegate>

@property (nonatomic, strong) JDZXCapture *capture;

@property (nonatomic,copy) JDScanBlock block;

@property (nonatomic, assign) BOOL bNeedScanResult;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, strong) NSTimer *focusTimer;

@property (nonatomic, strong) NSTimer *zoomTimer;

@end

@implementation JDZXingWrapper 

- (id)init {
    if ( self = [super init]) {
        self.capture = [[JDZXCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.capture.rotation = 90.0f;
        self.scale = 1.0f;
        self.capture.delegate = self;
    }
    return self;
}

- (id)initWithPreView:(UIView*)preView block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg))block {
    if (self = [super init]) {
        
        self.capture = [[JDZXCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.capture.rotation = 90.0f;
        
        self.capture.delegate = self;
        
        self.block = block;
        
        CGRect rect = preView.frame;
        rect.origin = CGPointZero;
        
        self.capture.layer.frame = rect;
        //[preView.layer addSublayer:self.capture.layer];
        
        [preView.layer insertSublayer:self.capture.layer atIndex:0];
        
    }
    return self;
}

#pragma mark - 捏合手势拉近拉远
- (void)zoomForView:(UIView *)view {
     UIPinchGestureRecognizer  *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerClicked:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:pinchGesture];
}

- (void)pinchGestureRecognizerClicked:(UIPinchGestureRecognizer *)pinch {
    self.scale += (pinch.scale > 1.0 ? 0.1 : -0.1);
    self.scale = MAX(self.scale, 1.0);
    self.scale = MIN([self maxZoomFactor], self.scale);
    NSError *error = nil;
    if (![self.capture.captureDevice lockForConfiguration:&error] || error) {
        return;
    }
    self.capture.captureDevice.videoZoomFactor = self.scale;
    [self.capture.captureDevice unlockForConfiguration];
}

- (CGFloat)maxZoomFactor {
    return MIN(self.capture.captureDevice.activeFormat.videoMaxZoomFactor, 8.0f);
}

- (void)setScanRect:(CGRect)scanRect {
    self.capture.scanRect = scanRect;
}

- (void)start {
    self.bNeedScanResult = YES;
    [self.capture start];
    [self autoFocus];
//    [self autoZoom];
}

- (void)stop {
    self.bNeedScanResult = NO;
    [self.capture stop];
}

- (void)openTorch:(BOOL)on_off {
    [self.capture setTorch:on_off];
}

- (void)openOrCloseTorch {
    [self.capture changeTorch];
}

- (void)autoFocus {
    if (self.focusTimer == nil || ![self.focusTimer isValid]) {
        self.focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startFocus) userInfo:nil repeats:YES];
    }
}

- (void)startFocus {
    [self.capture autoFocus];
}

- (void)stopFocus {
    [_focusTimer invalidate];
    _focusTimer = nil;
}


- (void)autoZoom {
    if (self.zoomTimer == nil || ![self.zoomTimer isValid]) {
        self.zoomTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(startZoom) userInfo:nil repeats:NO];
    }
}

- (void)startZoom {
    CGFloat videoMaxZoomFactor = MIN([self maxZoomFactor], 6.0f);
    CGFloat videoZoomFactor = videoMaxZoomFactor/2.0f;
    if (![self.capture.captureDevice isRampingVideoZoom]
        && self.capture.captureDevice.videoZoomFactor < videoZoomFactor) {
        AVCaptureDevice *captureDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *cerror = nil;
        [captureDevice lockForConfiguration:&cerror];
        
        CGFloat maxRate = 6.0f;
        CGFloat rate = maxRate*0.5f+(videoZoomFactor-1.0f)*(maxRate*0.5f)/(videoMaxZoomFactor-1.0f);
        //The zoom factor is continuously scaled by pow(2,rate * time)
        [self.capture.captureDevice rampToVideoZoomFactor:videoZoomFactor withRate:rate];
        self.scale = videoZoomFactor;
        if (self.capture.captureDevice.isFocusPointOfInterestSupported
            && [self.capture.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.capture.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [self.capture.captureDevice unlockForConfiguration];
    }
}

- (void)stopZoom {
    [_zoomTimer invalidate];
    _zoomTimer = nil;
}


#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(JDZXCapture *)capture result:(JDCaptureResult *)result scanImage:(UIImage *)img {
    if (!result) return;
    if (self.bNeedScanResult == NO) {
        return;
    }
    if (_block) {
        [self stop];
        _block(result.type,result.text,img);
    }    
}

- (void)captureCameraPreImage:(UIImage *)preImage {
    if (self.preImageBlock != nil) {
        self.preImageBlock(preImage);
    }
}


+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format {
    return [JDZXCapture createCodeWithString:str size:size CodeFomart:format];
}

+ (void)recognizeImage:(UIImage *)image
                 block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *text))block {
    JDCaptureResult *result = [JDZXCapture recognizeImage:image.CGImage invert:NO] ;
    if (result == nil) {
        block(kBarcodeFormatQRCode,nil);
        return;
    }
    block(result.type,result.text);
}

- (void)dealloc {
    [self stopFocus];
    [self stopZoom];
}

@end
