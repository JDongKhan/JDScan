//
//  JDScanViewController.h
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JDScanResult.h"
#import "JDScanView.h"
#import "JDZXing.h" //ZXing扫码封装

/**
 扫码结果delegate,也可通过继承本控制器，override方法scanResultWithArray即可
 */
@protocol JDScanViewControllerDelegate <NSObject>
@optional
- (void)scanResultWithArray:(NSArray<JDScanResult*>*)array;
@end

@interface JDScanViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

#pragma mark ---- 需要初始化参数 ------

//扫码结果委托，另外一种方案是通过继承本控制器，override方法scanResultWithArray即可
@property (nonatomic, weak) id<JDScanViewControllerDelegate> delegate;

/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;

/**
 @brief  启动区域识别功能，只扫描中间区域
 */
@property(nonatomic, assign) BOOL onlyScanCenterRect;

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
@property (nonatomic, strong, readonly) JDZXing *zxing;

#pragma mark ---- 扫码界面效果及提示等 ------
/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic, strong, readonly) JDScanView *qRScanView;

/**
 隐藏灯光按钮
 */
@property (nonatomic, assign) BOOL hiddenLightButton;

@property (nonatomic, assign) BOOL fullWidthScan;

/**
 打开灯光按钮
 */
@property (nonatomic, strong) UIButton *lightButton;

//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开启灯光
- (void)openOrClose:(UIButton *)btn;

//启动扫描
- (void)start;

//关闭扫描
- (void)stop;

@end
