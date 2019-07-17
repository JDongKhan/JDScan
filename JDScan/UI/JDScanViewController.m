//
//  JDScanViewController.m
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import "JDScanViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface JDScanViewController ()

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation JDScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫一扫";
    
    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.videoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.videoView];
    
    //扫描view
    [self drawScanView];
    
    //开启灯光按钮
    if (self.lightButton == nil && !self.hiddenLightButton) {
        UIButton *button = [[UIButton alloc] init];
        CGRect scanRect  = self.qRScanView.scanRect;
        button.frame = CGRectMake((self.view.frame.size.width - 100)/2, CGRectGetMaxY(scanRect)+20, 100, 50);
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_scan_off"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
        self.lightButton = button;
    }
    
    //预览view
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)willEnterForeground {
    [self start];
}

- (void)didEnterBackground {
    [self stop];
}

- (void)setLightButton:(UIButton *)lightButton {
    [_lightButton removeFromSuperview];
    _lightButton = lightButton;
    [self.view addSubview:self.lightButton];
}

- (void)setHiddenLightButton:(BOOL)hiddenLightButton {
    self.lightButton.hidden = YES;
}

- (void)setIsNeedScanImage:(BOOL)isNeedScanImage {
    _isNeedScanImage = isNeedScanImage;
    self.imageView.hidden = !isNeedScanImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            //不延时，可能会导致界面黑屏并卡住一会
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.3];
        }else{
            [self->_qRScanView stopDeviceReadying];
        }
    }];
}

//绘制扫描区域
- (void)drawScanView {
    if (!_qRScanView) {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        _qRScanView = [[JDScanView alloc]initWithFrame:rect style:_style];
        [self.view addSubview:_qRScanView];
    }
    
    if (!_cameraWakeMessage) {
        _cameraWakeMessage = NSLocalizedString(@"wating...", nil);
    }
    [_qRScanView startDeviceReadyingWithText:_cameraWakeMessage];
}

//启动设备
- (void)startScan {
    if (!_zxing) {
        __weak __typeof(self) weakSelf = self;
        _zxing = [[JDScanner alloc] initWithPreView:self.videoView block:^(NSArray<JDScanResult *> *results) {
            [weakSelf scanResultWithArray:results];
        }];
        self.zxing.preImageBlock = ^(UIImage *preImage) {
            weakSelf.imageView.image = preImage;
        };
        
        //计算扫描区域
        if (_onlyScanCenterRect) {
            CGRect scanRect = self.qRScanView.scanRect;
            
            //将屏幕宽设置为扫描区域
            if (self.fullWidthScan) {
                CGFloat width = self.view.frame.size.width;
                if (self.view.frame.size.height < width) {
                    width = self.view.frame.size.height;
                }
                CGFloat frameX = scanRect.origin.x - (width - scanRect.size.width)/2.0f;
                CGFloat frameY = scanRect.origin.y - (width - scanRect.size.height)/2.0f;
                CGRect fixRect = CGRectMake(frameX, frameY, width, width);
                scanRect = fixRect;
            }
            
            [_zxing setZxingRect:[JDScanView getZXingScanRectWithPreView:self.videoView scanRect:scanRect]];
            [_zxing setNativeRect:[JDScanView getScanRectWithPreView:self.view scanRect:scanRect]];
        }
    }
    //开始扫描
    [self start];
    
    if (_style.supportAutoFocus) {
        [_zxing autoFocus];
    }
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stop];
}

- (void)start {
    [_zxing start];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
}

- (void)stop {
    [_zxing stop];
    [_qRScanView stopScanAnimation];
    //停止扫描后将灯光按钮还原
    _lightButton.selected = NO;
}

#pragma mark -扫码结果处理

- (void)scanResultWithArray:(NSArray<JDScanResult*>*)array {
    //设置了委托的处理
    if (_delegate) {
        [_delegate scanResultWithArray:array];
    }
    //也可以通过继承JDScanViewController，重写本方法即可
}

//开关闪光灯
- (void)openOrClose:(UIButton *)btn {
    btn.selected = !btn.selected;
    [_zxing openOrCloseTorch];
}

#pragma mark ------  打开相册并识别图片

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto:(BOOL)allowsEditing {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //部分机型有问题
    picker.allowsEditing = allowsEditing;
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __weak __typeof(self) weakSelf = self;
    [JDScanner recognizeImage:image block:^(NSArray<JDScanResult *>  *results) {
        [weakSelf scanResultWithArray:results];
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestCameraPemissionWithResult:(void(^)(BOOL granted))completion {
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     completion(true);
                                                 } else {
                                                     completion(false);
                                                 }
                                             });
                                             
                                         }];
            }
                break;
                
        }
    }
}

+ (BOOL)photoPermission {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusDenied) {
            return NO;
        }
        return YES;
    }
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if ( authorStatus == PHAuthorizationStatusDenied ) {
        return NO;
    }
    return YES;
}

@end
