//
//  JDScanLineAnimation.h
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDScanAnimation.h"

@interface JDScanLineAnimation : UIImageView <JDScanAnimation>

- (instancetype)initWithAnimationImage:(UIImage *)animationImage;

+ (instancetype)animationWithImage:(UIImage *)image;

@end
