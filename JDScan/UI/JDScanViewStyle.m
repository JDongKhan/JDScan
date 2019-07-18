//
//  JDScanViewStyle.m
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import "JDScanViewStyle.h"
#import "JDScanLineAnimation.h"
#import "JDScanNetAnimation.h"

@implementation JDScanViewStyle

- (id)init {
    if (self =  [super init]) {
        _borderWidth = 1.0f;
        _supportAutoZoom = YES;
        _supportAutoFocus = YES;
        _whRatio = 1.0;
        _borderColor = [UIColor whiteColor];
        _verticalOffset = 44;
        _horizontalMargin = 60;
        _scanAnimation = [JDScanLineAnimation  animationWithImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line"]];
        _cornerStyle = JDScanViewCornerStyleDefault;
        _cornerColor = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        _backgroundColor = [UIColor colorWithRed:0. green:.0 blue:.0 alpha:.5];
        _cornerWidth = 24;
        _cornerHeight = 24;
        _cornerLineWidth = 2;
    }
    return self;
}

@end

