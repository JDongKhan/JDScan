//
//  JDScanLineAnimation.h
//  JDScanner
//
//  Created by WJD on 19/4/3.
//  Copyright © 2019 年 WJD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDScanAnimation.h"

@interface JDScanNetAnimation : UIView <JDScanAnimation>

- (instancetype)initWithAnimationImage:(UIImage *)animationImage;

+ (instancetype)animationWithImage:(UIImage *)image;

@end
