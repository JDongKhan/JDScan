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

@property (nonatomic, strong) UIButton *openOrCloseButton;

@end

@implementation JDScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"ZXing";
    
    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.videoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.videoView];
    
    [self drawScanView];
    
    self.openOrCloseButton = [[UIButton alloc] init];
    CGRect rect = [JDScanView getZXingScanRectWithPreView:self.view style:_style];
    self.openOrCloseButton.frame = CGRectMake(100, rect.origin.y, 100, 50);
    self.openOrCloseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.openOrCloseButton setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [self.openOrCloseButton setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_scan_off"] forState:UIControlStateSelected];
    [self.openOrCloseButton addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openOrCloseButton];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
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

- (void)restartDevice {
    [_zxingObj start];
}

//启动设备
- (void)startScan {
    if (!_zxingObj) {
        __weak __typeof(self) weakSelf = self;
        _zxingObj = [[JDZXingWrapper alloc]initWithPreView:self.videoView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
            JDScanResult *result = [[JDScanResult alloc]init];
            result.strScanned = str;
            result.imgScanned = scanImg;
            result.strBarCodeType = [weakSelf convertCodeFormat:barcodeFormat];
            [weakSelf scanResultWithArray:@[result]];
        }];
        self.zxingObj.preImageBlock = ^(UIImage *preImage) {
            weakSelf.imageView.image = preImage;
        };
        [_zxingObj zoomForView:self.view];
        if (_isOpenInterestRect) {
            //设置只识别框内区域
            CGRect cropRect = [JDScanView getZXingScanRectWithPreView:self.videoView style:_style];
            [_zxingObj setScanRect:cropRect];
        }
    }
    [_zxingObj start];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopScan];
}

- (void)stopScan {
    [_zxingObj stop];
    [_qRScanView stopScanAnimation];
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
    [_zxingObj openOrCloseTorch];
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
    [JDZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        JDScanResult *result = [[JDScanResult alloc]init];
        result.strScanned = str;
        result.imgScanned = image;
        result.strBarCodeType = [self convertCodeFormat:barcodeFormat];
        [weakSelf scanResultWithArray:@[result]];
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)convertCodeFormat:(ZXBarcodeFormat)barCodeFormat {
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
