//
//  JDScanViewController.h
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JDScanTypes.h"
//UI
#import "JDScanView.h"
#import "JDZXingWrapper.h" //ZXing扫码封装

// @[@"QRCode",@"BarCode93",@"BarCode128",@"BarCodeITF",@"EAN13"];
typedef NS_ENUM(NSInteger, JDScanCodeType) {
    JDScanCodeTypeQRCode, //QR二维码
    JDScanCodeTypeBarCode93,
    JDScanCodeTypeBarCode128,//支付条形码(支付宝、微信支付条形码)
    JDScanCodeTypeBarCodeITF,//燃气回执联 条形码?
    JDScanCodeTypeBarEAN13 //一般用做商品码
};


/**
 扫码结果delegate,也可通过继承本控制器，override方法scanResultWithArray即可
 */
@protocol JDScanViewControllerDelegate <NSObject>
@optional
- (void)scanResultWithArray:(NSArray<JDScanResult*>*)array;
@end


@interface JDScanViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


#pragma mark ---- 需要初始化参数 ------
/**
 当前选择的识别码制
 - ZXing暂不支持类型选择
 */
@property (nonatomic, assign) JDScanCodeType scanCodeType;

//扫码结果委托，另外一种方案是通过继承本控制器，override方法scanResultWithArray即可
@property (nonatomic, weak) id<JDScanViewControllerDelegate> delegate;



/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;

/**
 @brief  启动区域识别功能
 */
@property(nonatomic, assign) BOOL isOpenInterestRect;

/**
 相机启动提示,如 相机启动中...
 */
@property (nonatomic, copy) NSString *cameraWakeMessage;

/**
 *  界面效果参数
 */
@property (nonatomic, strong) JDScanViewStyle *style;

#pragma mark -----  扫码使用的库对象 -------
/**
 ZXing扫码对象
 */
@property (nonatomic, strong, readonly) JDZXingWrapper *zxingObj;


#pragma mark ---- 扫码界面效果及提示等 ------
/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic, strong, readonly) JDScanView* qRScanView;

/**
 @brief  闪关灯开启状态记录
 */
@property(nonatomic,assign, readonly) BOOL isOpenFlash;

//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;

//启动扫描
- (void)restartDevice;

//关闭扫描
- (void)stopScan;


@end
