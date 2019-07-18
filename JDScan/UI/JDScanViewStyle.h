//
//  JDScanViewStyle.h
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JDScanAnimation.h"

/**
 扫码区域4个角位置类型
 */
typedef NS_ENUM(NSInteger, JDScanViewCornerStyle) {
    JDScanViewCornerStyleDefault,  //在矩形框的4个角上，覆盖
    JDScanViewCornerStyleInner,//内嵌，一般不显示矩形框情况下
    JDScanViewCornerStyleOuter,//外嵌,包围在矩形框的4个角
};


NS_ASSUME_NONNULL_BEGIN

@interface JDScanViewStyle : NSObject


#pragma mark -中心位置矩形框
/**
 支持自动缩放
 */
@property (nonatomic, assign) BOOL supportAutoZoom;

/**
 支持自动对焦
 */
@property (nonatomic, assign) BOOL supportAutoFocus;

/**
 *  默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
 */
@property (nonatomic, assign) CGFloat whRatio;

/**
 @brief  矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，< 0 表示扫码区域下移, >0 表示扫码区域上移
 */
@property (nonatomic, assign) CGFloat verticalOffset;

/**
 *  矩形框(视频显示透明区)离界面左边及右边距离，默认60
 */
@property (nonatomic, assign) CGFloat horizontalMargin;

/**
 @brief  是否需要绘制扫码矩形框，默认YES
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 @brief  矩形框线条颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

#pragma mark -矩形框(扫码区域)周围4个角
/**
 @brief  扫码区域的4个角类型
 */
@property (nonatomic, assign) JDScanViewCornerStyle cornerStyle;

//4个角的颜色
@property (nonatomic, strong) UIColor *cornerColor;

//扫码区域4个角的宽度和高度
@property (nonatomic, assign) CGFloat cornerWidth;
@property (nonatomic, assign) CGFloat cornerHeight;
/**
 @brief  扫码区域4个角的线条宽度,默认2
 */
@property (nonatomic, assign) CGFloat cornerLineWidth;


/**
 must be create by [UIColor colorWithRed: green: blue: alpha:]
 背景颜色，非扫描区，默认 RGBA (0,0,0,0.5)
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 扫描器
 */
@property (nonatomic ,strong) id<JDScanAnimation> scanAnimation;


@end

NS_ASSUME_NONNULL_END
