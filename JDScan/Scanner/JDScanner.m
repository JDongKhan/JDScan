//
//  JDScanner.m
//  JDScanner
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import "JDScanner.h"
#import "JDCaptureDelegate.h"
#import "JDCapture.h"
#import "JDZXDetectorHook.h"

typedef void(^JDScanBlock)(NSArray<JDScanResult *>  *result);

@interface JDScanner() <JDCaptureDelegate>

@property (nonatomic, strong) JDCapture *capture;

@property (nonatomic,copy) JDScanBlock block;

@property (nonatomic, assign) BOOL bNeedScanResult;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, strong) NSTimer *focusTimer;

@property (nonatomic, weak) UIView *preView;

@end

@implementation JDScanner

- (id)init {
    if ( self = [super init]) {
        self.capture = [[JDCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.rotation = 90.0f;
        self.scale = 1.0f;
        self.capture.delegate = self;
    }
    return self;
}

- (id)initWithPreView:(UIView*)preView block:(void(^)(NSArray<JDScanResult *> *result))block {
    if (self = [super init]) {
        _preView = preView;
        self.capture = [[JDCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.rotation = 90.0f;
        self.scale = 1.0f;
        self.capture.delegate = self;
        
        self.block = block;
        
        CGRect rect = preView.frame;
        rect.origin = CGPointZero;
        self.capture.layer.frame = rect;
        [preView.layer insertSublayer:self.capture.layer atIndex:0];
    }
    return self;
}

- (void)setZxingRect:(CGRect)zxingRect {
    //设置只识别框内区域
    self.capture.zxingRect = zxingRect;
}

- (void)setNativeRect:(CGRect)nativeRect {
    self.capture.nativeRect = nativeRect;
}

- (NSError *)start {
    self.bNeedScanResult = YES;
    return [self.capture start];
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

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(JDCapture *)capture result:(NSArray<JDScanResult *> *)result {
    if (!result) return;
    if (self.bNeedScanResult == NO) {
        return;
    }
    if (_block) {
        [self stop];
        _block(result);
    }    
}

- (void)captureResult:(JDCapture *)capture preImage:(UIImage *)preImage {
    if (self.preImageBlock != nil) {
        self.preImageBlock(preImage);
    }
}


#pragma mark  ---------- 功能方法 ---------------
+ (UIImage*)generateCodeWithString:(NSString*)str size:(CGSize)size codeFomart:(ZXBarcodeFormat)format {
    return [JDCapture generateCodeWithString:str size:size codeFomart:format];
}

+ (void)recognizeImage:(UIImage *)image
                 block:(void(^)(NSArray<JDScanResult *> *results))block {
    NSArray<JDScanResult *> *results = [JDCapture recognizeImage:image.CGImage invert:NO] ;
    if (results == nil) {
        block(nil);
        return;
    }
    block(results);
}

- (void)dealloc {
    [self stopFocus];
}

#pragma mark -------- 捏合手势拉近拉远 ---
- (void)zoomForView:(UIView *)view {
    UIPinchGestureRecognizer  *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:pinchGesture];
}

- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)pinch {
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

#pragma mark -------- focus ---

- (void)autoFocus {
    if (self.focusTimer == nil || ![self.focusTimer isValid]) {
        self.focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startFocus) userInfo:nil repeats:YES];
    }
}

- (void)startFocus {
    [self.capture autoFocus];
}

- (void)stopFocus {
    if (_focusTimer == nil) {
        return;
    }
    [_focusTimer invalidate];
    _focusTimer = nil;
}

#pragma mark -------- zoom ------
- (void)autoZoom {
    [JDZXDetectorHook startHook];
}

@end
