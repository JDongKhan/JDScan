//
//  DemoStyle.h
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JDScanViewStyle.h>
#import <ZXBarcodeFormat.h>


@interface DemoStyle : NSObject

#pragma mark --style0
+ (JDScanViewStyle*)style0;

#pragma mark --style1
+ (JDScanViewStyle*)style1;

#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)style2;

#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)style3;

#pragma mark -4个角在矩形框线上,网格动画
+ (JDScanViewStyle*)style4;

#pragma mark -自定义4个角及矩形框颜色
+ (JDScanViewStyle*)style5;

#pragma mark -框内区域识别
+ (JDScanViewStyle*)style6;

#pragma mark -改变扫码区域位置
+ (JDScanViewStyle*)style7;

#pragma mark -非正方形，可以用在扫码条形码界面
+ (JDScanViewStyle*)notSquare;

#pragma mark -ZXing码格式类型转native
+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat;

@end
