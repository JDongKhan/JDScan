//
//  DemoStyle.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "DemoStyle.h"
#import "JDScanLineAnimation.h"
#import "JDScanNetAnimation.h"

#import <AVFoundation/AVFoundation.h>

@implementation DemoStyle


#pragma mark --style0
+ (JDScanViewStyle*)style0 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    return style;
}

#pragma mark --style1
+ (JDScanViewStyle*)style1 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 60;
    style.horizontalMargin = 30;
    if ([UIScreen mainScreen].bounds.size.height <= 480 ) {
        //3.5inch 显示的扫码缩小
        style.verticalOffset = 40;
        style.horizontalMargin = 20;
    }
    style.cornerStyle = JDScanViewCornerStyleInner;
    style.cornerLineWidth = 2.0;
    style.cornerWidth = 16;
    style.cornerHeight = 16;
    style.borderWidth = 0.0f;
    style.supportAutoFocus = YES;
    style.supportAutoZoom = YES;
    style.lightButtonOffset = CGPointMake(0, -60);
    style.scanAnimation = [JDScanNetAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_full_net"]];
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}


#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)style2 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    style.cornerStyle = JDScanViewCornerStyleOuter;
    style.cornerLineWidth = 2;
    style.cornerWidth = 18;
    style.cornerHeight = 18;
    style.borderWidth = 1.0f;
    style.scanAnimation = [JDScanLineAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line"]];
    style.cornerColor = [UIColor colorWithRed:0./255 green:200./255. blue:20./255. alpha:1.0];
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}


#pragma mark -无边框，内嵌4个角
+ (JDScanViewStyle*)style3 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    style.cornerStyle = JDScanViewCornerStyleInner;
    style.cornerLineWidth = 3;
    style.cornerWidth = 18;
    style.cornerHeight = 18;
    style.borderWidth = 0.0f;
    style.scanAnimation = [JDScanLineAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"]];
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}

#pragma mark -4个角在矩形框线上,网格动画
+ (JDScanViewStyle*)style4 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    style.cornerStyle = JDScanViewCornerStyleDefault;
    style.cornerLineWidth = 6;
    style.cornerWidth = 24;
    style.cornerHeight = 24;
    style.borderWidth = 5.0f;
    style.scanAnimation = [JDScanNetAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"]];
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}

#pragma mark -自定义4个角及矩形框颜色
+ (JDScanViewStyle*)style5 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    //扫码框周围4个角的类型设置为在框的上面
    style.cornerStyle = JDScanViewCornerStyleDefault;
    //扫码框周围4个角绘制线宽度
    style.cornerLineWidth = 6;
    //扫码框周围4个角的宽度
    style.cornerWidth = 24;
    //扫码框周围4个角的高度
    style.cornerHeight = 24;
    //显示矩形框
    style.borderWidth = 2.0f;
    //动画类型：网格形式，模仿支付宝
    style.scanAnimation = [JDScanNetAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"]];
    //码框周围4个角的颜色
    style.cornerColor = [UIColor colorWithRed:65./255. green:174./255. blue:57./255. alpha:1.0];
    //矩形框颜色
    style.borderColor = [UIColor colorWithRed:247/255. green:202./255. blue:15./255. alpha:1.0];
    //非矩形框区域颜色
    style.backgroundColor = [UIColor colorWithRed:247./255. green:202./255 blue:15./255 alpha:0.2];
    return style;
}


#pragma mark -框内区域识别
+ (JDScanViewStyle*)style6 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    style.cornerStyle = JDScanViewCornerStyleDefault;
    style.cornerLineWidth = 6;
    style.cornerWidth = 24;
    style.cornerHeight = 24;
    style.borderWidth = 1.0f;
    style.scanAnimation = [JDScanNetAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"]];
    //矩形框离左边缘及右边缘的距离
    style.horizontalMargin = 80;
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}

#pragma mark -改变扫码区域位置
+ (JDScanViewStyle*)style7 {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    //矩形框向上移动
    style.verticalOffset = 60;
    //矩形框离左边缘及右边缘的距离
    style.horizontalMargin = 100;
    style.cornerStyle = JDScanViewCornerStyleDefault;
    style.cornerLineWidth = 6;
    style.cornerWidth = 24;
    style.cornerHeight = 24;
    style.borderWidth = 1.0f;
    style.scanAnimation = [JDScanLineAnimation animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"]];
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}

#pragma mark -非正方形，可以用在扫码条形码界面

+ (UIImage*)createImageWithColor: (UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (JDScanViewStyle*)notSquare {
    //设置扫码区域参数
    JDScanViewStyle *style = [[JDScanViewStyle alloc]init];
    style.verticalOffset = 44;
    style.cornerStyle = JDScanViewCornerStyleInner;
    style.cornerLineWidth = 4;
    style.cornerWidth = 28;
    style.cornerHeight = 16;
    style.borderWidth = 0.0f;
    style.scanAnimation = [JDScanLineAnimation animationWithImage:[[self class] createImageWithColor:[UIColor redColor]]];
    //非正方形
    //设置矩形宽高比
    style.whRatio = 4.3/2.18;
    //离左边和右边距离
    style.horizontalMargin = 30;
    style.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}


+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat {
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
