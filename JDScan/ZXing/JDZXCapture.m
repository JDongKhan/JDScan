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

#import "JDZXCapture.h"
#import <ImageIO/ImageIO.h>
#import "ZXingObjC.h"
#import "JDImageUtils.h"

@interface JDZXCapture () <CALayerDelegate,AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) CALayer *binaryLayer;
@property (nonatomic, assign) BOOL cameraIsReady;
@property (nonatomic, assign) int captureDeviceIndex;
@property (nonatomic, assign) BOOL hardStop;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, strong) CALayer *luminanceLayer;
@property (nonatomic, assign) int orderInSkip;
@property (nonatomic, assign) int orderOutSkip;
@property (nonatomic, assign) BOOL onScreen;


// 摄像配置
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataQueue;
@property (nonatomic, strong) dispatch_queue_t metadataQueue;

@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation JDZXCapture

- (JDZXCapture *)init {
    if (self = [super init]) {
        _captureDeviceIndex = -1;
        _videoDataQueue = dispatch_queue_create("com.zxing.videoDataQueue", NULL);
        _metadataQueue = dispatch_queue_create("com.zxing.metadataQueue", NULL);
        
        _focusMode = AVCaptureFocusModeContinuousAutoFocus;
        _hardStop = NO;
        _onScreen = NO;
        _orderInSkip = 0;
        _orderOutSkip = 0;
        _rotation = 0.0f;
        _running = NO;
        _sessionPreset = AVCaptureSessionPresetHigh;
        _transform = CGAffineTransformIdentity;
    
        _zxingRect = CGRectZero;
        _nativeRect = CGRectZero;
    }
  return self;
}

- (void)dealloc {
    if (_session && _session.inputs) {
        for(AVCaptureInput *input in _session.inputs) {
            [_session removeInput:input];
        }
        [self.layer removeFromSuperlayer];
    }

    if (_session && _session.outputs) {
        for(AVCaptureOutput *output in _session.outputs) {
            [_session removeOutput:output];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ---- CAAction ----

- (id<CAAction>)actionForLayer:(CALayer *)_layer forKey:(NSString *)event {
  [CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];

  if ([event isEqualToString:kCAOnOrderIn] || [event isEqualToString:kCAOnOrderOut]) {
    return self;
  }

  return nil;
}

- (void)runActionForKey:(NSString *)key object:(id)anObject arguments:(NSDictionary *)dict {
  if ([key isEqualToString:kCAOnOrderIn]) {
    if (self.orderInSkip) {
      self.orderInSkip--;
      return;
    }

    self.onScreen = YES;
  } else if ([key isEqualToString:kCAOnOrderOut]) {
    if (self.orderOutSkip) {
      self.orderOutSkip--;
      return;
    }
    self.onScreen = NO;
  }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

  @autoreleasepool {
    if (!self.cameraIsReady) {
      self.cameraIsReady = YES;
      if ([self.delegate respondsToSelector:@selector(captureCameraIsReady:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.delegate captureCameraIsReady:self];
        });
      }
    }
      
    CVImageBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGImageRef videoFrameImage = [ZXCGImageLuminanceSource createImageFromBuffer:videoFrame];
    CGImageRef rotatedImage = [self createRotatedImage:videoFrameImage degrees:self.rotation];
    CGImageRelease(videoFrameImage);
    
    // If zxingRect is set, crop the current image to include only the desired rect
    if (!CGRectIsEmpty(self.zxingRect)) {
      CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage, self.zxingRect);
      CFRelease(rotatedImage);
      rotatedImage = croppedImage;
    }
    
    //识别原生图片
    JDScanResult *result = [JDZXCapture recognizeImage:rotatedImage invert:self.invert];
    //识别识别，开始使用opencv处理
    if (result == nil) {
        //将图片处理一下下
        UIImage *image1 = [JDImageUtils translator:[UIImage imageWithCGImage:rotatedImage]];
        CFRelease(rotatedImage);
        rotatedImage = CGImageRetain(image1.CGImage);
        result = [JDZXCapture recognizeImage:rotatedImage invert:self.invert];
    }
      
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureResult:preImage:)]) {
        UIImage *image = [UIImage imageWithCGImage:rotatedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate captureResult:self preImage:image];
        });
    }
      
    if (self.luminanceLayer) {
        CGImageRef image = CGImageRetain(rotatedImage);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            self.luminanceLayer.contents = (__bridge id)image;
            CGImageRelease(image);
        });
    }
      
    if (self.binaryLayer) {
        CGImageRef image = CGImageRetain(rotatedImage);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            self.binaryLayer.contents = (__bridge id)image;
            CGImageRelease(image);
        });
    }

    if (result) {
      UIImage *image = [UIImage imageWithCGImage:rotatedImage];
      result.image = image;
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.delegate captureResult:self result:result];
      });
    }
    
    CGImageRelease(rotatedImage);
    
  }
}

#pragma mark --- 二维码扫描 -------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if ([metadataObjects count]) {
            JDScanResult *result = nil;
            for (AVMetadataObject *obj in metadataObjects) {
                if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                    AVMetadataMachineReadableCodeObject *codeObj = (AVMetadataMachineReadableCodeObject *)obj;
                    result = [[JDScanResult alloc] init];
                    result.text = [codeObj.stringValue copy];
                    result.type = [codeObj.type copy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate captureResult:self result:result];
                    });
                    break;
                }
                
            }
        }
    }
}

#pragma mark - Start, Stop

- (void)hard_stop {
    self.hardStop = YES;
    
    if (self.running) {
        [self stop];
    }
}

- (void)order_skip {
    self.orderInSkip = 1;
    self.orderOutSkip = 1;
}

- (void)start {
    if (self.running) {
        return;
    }
    if (self.hardStop) {
        return;
    }
    //[self stillImageOutput];
    [self videoDataOutput];
    [self metadataOutput];
    if (!self.session.running) {
        static int i = 0;
        if (++i == -2) {
            abort();
        }
        [self.session startRunning];
    }
    self.running = YES;
}

- (void)stop {
    if (!self.running) {
        return;
    }
    
    if (self.session.running) {
        [self.session stopRunning];
    }
    self.running = NO;
}


#pragma mark ------- 功能方法 ------

- (void)startStop {
  if ((!self.running && (self.delegate || self.onScreen)) ||
      (!self.videoDataOutput && !self.metadataOutput &&
       (self.delegate ||
        (self.onScreen && (self.luminanceLayer || self.binaryLayer))))) {
         [self start];
       }

  if (self.running && !self.delegate && !self.onScreen) {
    [self stop];
  }
}

+ (JDScanResult *)recognizeImage:(CGImageRef)image invert:(BOOL)invert {
    ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image];
    ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource:invert ? [source invert] : source];
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    NSError *error;
    id<ZXReader> reader  = [ZXMultiFormatReader reader];
    ZXDecodeHints *_hints = [ZXDecodeHints hints];
    ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
    JDScanResult *newResult = nil;
    if (result != nil) {
        newResult = [[JDScanResult alloc] init];
        newResult.text = result.text;
        newResult.type = [JDZXCapture strBarCodeType:result.barcodeFormat];
    }
    return newResult;
}

+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format {
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:str
                                  format:format
                                   width:size.width
                                  height:size.width
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        return [UIImage imageWithCGImage:image.cgimage];
    } else {
        return nil;
    }
}

- (void)changeTorch {
    AVCaptureTorchMode torch = self.input.device.torchMode;
    
    switch (self.input.device.torchMode) {
        case AVCaptureTorchModeAuto:
            break;
        case AVCaptureTorchModeOff:
            torch = AVCaptureTorchModeOn;
            break;
        case AVCaptureTorchModeOn:
            torch = AVCaptureTorchModeOff;
            break;
        default:
            break;
    }
    
    [self.input.device lockForConfiguration:nil];
    self.input.device.torchMode = torch;
    [self.input.device unlockForConfiguration];
}

#pragma mark - Property Setters

- (void)setCamera:(int)camera {
    if (_camera != camera) {
        _camera = camera;
        self.captureDeviceIndex = -1;
        self.captureDevice = nil;
        [self replaceInput];
    }
}

- (void)setDelegate:(id<JDZXCaptureDelegate>)delegate {
    _delegate = delegate;
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    if ([self.input.device isFocusModeSupported:focusMode] && self.input.device.focusMode != focusMode) {
        _focusMode = focusMode;
        
        [self.input.device lockForConfiguration:nil];
        self.input.device.focusMode = focusMode;
        [self.input.device unlockForConfiguration];
    }
}

- (void)setMirror:(BOOL)mirror {
    if (_mirror != mirror) {
        _mirror = mirror;
        if (self.layer) {
            CGAffineTransform transform = self.transform;
            transform.a = - transform.a;
            self.transform = transform;
            [self.layer setAffineTransform:self.transform];
        }
    }
}

- (void)setTorch:(BOOL)torch {
    _torch = torch;
    
    [self.input.device lockForConfiguration:nil];
    self.input.device.torchMode = self.torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    [self.input.device unlockForConfiguration];
}

- (void)setTransform:(CGAffineTransform)transform {
    _transform = transform;
    [self.layer setAffineTransform:transform];
}


#pragma mark - Back, Front, Torch

- (int)back {
    return 1;
}

- (int)front {
    return 0;
}

- (BOOL)hasFront {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [devices count] > 1;
}

- (BOOL)hasBack {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [devices count] > 0;
}

- (BOOL)hasTorch {
    if ([self device]) {
        return [self device].hasTorch;
    } else {
        return NO;
    }
}

#pragma mark - Binary

- (CALayer *)binary {
    return self.binaryLayer;
}

- (void)setBinary:(BOOL)on {
    if (on && !self.binaryLayer) {
        self.binaryLayer = [CALayer layer];
    } else if (!on && self.binaryLayer) {
        self.binaryLayer = nil;
    }
}

#pragma mark - Luminance

- (CALayer *)luminance {
    return self.luminanceLayer;
}

- (void)setLuminance:(BOOL)on {
    if (on && !self.luminanceLayer) {
        self.luminanceLayer = [CALayer layer];
    } else if (!on && self.luminanceLayer) {
        self.luminanceLayer = nil;
    }
}


#pragma mark ----- Property Getters ------

- (CALayer *)layer {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)_layer;
    if (!_layer) {
        layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        layer.affineTransform = self.transform;
        layer.delegate = self;
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _layer = layer;
    }
    return layer;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSetting = @{AVVideoCodecKey:AVVideoCodecJPEG};
        [_stillImageOutput setOutputSettings:outputSetting];
        if ([self.session canAddOutput:_stillImageOutput]) {
            [self.session addOutput:_stillImageOutput];
        }
    }
    return _stillImageOutput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setVideoSettings:@{
                                             (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                             }];
        [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataQueue];
        if ([self.session canAddOutput:_videoDataOutput]) {
            [self.session addOutput:_videoDataOutput];
        }
    }
    return _videoDataOutput;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:_metadataQueue];
        if ([self.session canAddOutput:_metadataOutput]) {
            [self.session addOutput:_metadataOutput];
        }
        _metadataOutput.metadataObjectTypes = [_metadataOutput availableMetadataObjectTypes];
        //设置扫描区域
        _metadataOutput.rectOfInterest = self.nativeRect;
    }
    return _metadataOutput;
}

- (AVCaptureDevice *)device {
    if (self.captureDevice) {
        return self.captureDevice;
    }
    
    AVCaptureDevice *device = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if ([devices count] > 0) {
        if (self.captureDeviceIndex == -1) {
            AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
            if (self.camera == self.front) {
                position = AVCaptureDevicePositionFront;
            }
            
            for (unsigned int i = 0; i < [devices count]; ++i) {
                AVCaptureDevice *dev = [devices objectAtIndex:i];
                if (dev.position == position) {
                    self.captureDeviceIndex = i;
                    device = dev;
                    break;
                }
            }
        }
        
        if (!device && self.captureDeviceIndex != -1) {
            device = [devices objectAtIndex:self.captureDeviceIndex];
        }
    }
    if (!device) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    self.captureDevice = device;
    NSError *error = nil;
    if ([device lockForConfiguration:&error] || error) {
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        device.subjectAreaChangeMonitoringEnabled = YES;
    }
    device.activeVideoMinFrameDuration = CMTimeMake(10, (int)(30 * 10));
    device.activeVideoMaxFrameDuration = device.activeVideoMinFrameDuration;
   
    [device unlockForConfiguration];
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoFocus) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:device];
    
    return device;
}

- (void)replaceInput {
    [self.session beginConfiguration];
    if (self.session && self.input) {
        [self.session removeInput:self.input];
        self.input = nil;
    }
    AVCaptureDevice *device = [self device];
    if (device) {
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        self.focusMode = self.focusMode;
    }
    if (self.input) {
        [self.session addInput:self.input];
    }
    [self.session commitConfiguration];
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = self.sessionPreset;
        [self replaceInput];
    }
    return _session;
}


- (void)autoFocus {
    CGPoint pointOfInterest = CGPointMake(0.5, 0.5);
    NSError *error = nil;
    if ([self.captureDevice lockForConfiguration:&error]) {
        if ([self.captureDevice isFocusPointOfInterestSupported]) {
            [self.captureDevice setFocusPointOfInterest:pointOfInterest];
        }
        if ([self.captureDevice isSmoothAutoFocusEnabled]) {
            [self.captureDevice setSmoothAutoFocusEnabled:YES];
        }
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光
        if ([self.captureDevice isExposurePointOfInterestSupported] && [self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.captureDevice setExposurePointOfInterest:pointOfInterest];
            [self.captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
    }
    [self.captureDevice unlockForConfiguration];
}

#pragma mark -------工具方法------


#pragma mark - Private

// Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
- (CGImageRef)createRotatedImage:(CGImageRef)original degrees:(float)degrees CF_RETURNS_RETAINED {
    if (degrees == 0.0f) {
        CGImageRetain(original);
        return original;
    } else {
        double radians = degrees * M_PI / 180;
        
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians;
#endif
        
        size_t _width = CGImageGetWidth(original);
        size_t _height = CGImageGetHeight(original);
        
        CGRect imgRect = CGRectMake(0, 0, _width, _height);
        CGAffineTransform __transform = CGAffineTransformMakeRotation(radians);
        CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, __transform);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     rotatedRect.size.width,
                                                     rotatedRect.size.height,
                                                     CGImageGetBitsPerComponent(original),
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
        CGContextSetAllowsAntialiasing(context, FALSE);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGColorSpaceRelease(colorSpace);
        
        CGContextTranslateCTM(context,
                              +(rotatedRect.size.width/2),
                              +(rotatedRect.size.height/2));
        CGContextRotateCTM(context, radians);
        
        CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                                               -imgRect.size.height/2,
                                               imgRect.size.width,
                                               imgRect.size.height),
                           original);
        
        CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        
        return rotatedImage;
    }
}

+ (NSString*)strBarCodeType:(ZXBarcodeFormat)barCodeFormat {
    NSString *strAVMetadataObjectType = nil;
    switch (barCodeFormat) {
        case kBarcodeFormatQRCode:
            strAVMetadataObjectType = AVMetadataObjectTypeQRCode;
            break;
        case kBarcodeFormatEan13:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN13Code;
            break;
        case kBarcodeFormatEan8:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN8Code;
            break;
        case kBarcodeFormatPDF417:
            strAVMetadataObjectType = AVMetadataObjectTypePDF417Code;
            break;
        case kBarcodeFormatAztec:
            strAVMetadataObjectType = AVMetadataObjectTypeAztecCode;
            break;
        case kBarcodeFormatCode39:
            strAVMetadataObjectType = AVMetadataObjectTypeCode39Code;
            break;
        case kBarcodeFormatCode93:
            strAVMetadataObjectType = AVMetadataObjectTypeCode93Code;
            break;
        case kBarcodeFormatCode128:
            strAVMetadataObjectType = AVMetadataObjectTypeCode128Code;
            break;
        case kBarcodeFormatDataMatrix:
            strAVMetadataObjectType = AVMetadataObjectTypeDataMatrixCode;
            break;
        case kBarcodeFormatITF:
            strAVMetadataObjectType = AVMetadataObjectTypeITF14Code;
            break;
        case kBarcodeFormatRSS14:
            break;
        case kBarcodeFormatRSSExpanded:
            break;
        case kBarcodeFormatUPCA:
            break;
        case kBarcodeFormatUPCE:
            strAVMetadataObjectType = AVMetadataObjectTypeUPCECode;
            break;
        default:
            break;
    }
    return strAVMetadataObjectType;
}

@end
