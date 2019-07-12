//
//  JDScanVideoZoomView.h
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDScanVideoZoomView : UIView

/**
 @brief 控件值变化
 */
@property (nonatomic, copy,nullable) void (^block)(float value);

- (void)setMaximunValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
