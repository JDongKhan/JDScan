//
//  JDScanAnimation.h
//  JDScanner
//
//  Created by WJD on 19/4/3.
//  Copyright (c) 2019 年 WJD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JDScanAnimation <NSObject>

/**
 *  开始扫码网格效果
 *
 *  @param animationRect 显示在parentView中得区域
 *  @param parentView    动画显示在UIView
 */
- (void)startAnimatingWithRect:(CGRect)animationRect inView:(UIView*)parentView;

/**
 *  停止动画
 */
- (void)stopAnimating;



@end

NS_ASSUME_NONNULL_END
