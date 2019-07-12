//
//  DemoListViewModel.h
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JDScanViewStyle.h>
#import <ZXBarcodeFormat.h>


@interface StyleDIY : NSObject

#pragma mark -模仿qq界面
+ (JDScanViewStyle*)qqStyle;

#pragma mark --模仿支付宝
+ (JDScanViewStyle*)ZhiFuBaoStyle;

#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)InnerStyle;

#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)weixinStyle;

#pragma mark -框内区域识别
+ (JDScanViewStyle*)recoCropRect;

#pragma mark -4个角在矩形框线上,网格动画
+ (JDScanViewStyle*)OnStyle;

#pragma mark -自定义4个角及矩形框颜色
+ (JDScanViewStyle*)changeColor;

#pragma mark -改变扫码区域位置
+ (JDScanViewStyle*)changeSize;

#pragma mark -非正方形，可以用在扫码条形码界面
+ (JDScanViewStyle*)notSquare;

#pragma mark -ZXing码格式类型转native
+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat;

@end
