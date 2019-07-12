//
//  JDScanViewStyle.m
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import "JDScanViewStyle.h"

@implementation JDScanViewStyle

- (id)init {
    if (self =  [super init]) {
        _isNeedShowRetangle = YES;
        
        _whRatio = 1.0;
       
        _colorRetangleLine = [UIColor whiteColor];
        
        _centerUpOffset = 44;
        _xScanRetangleOffset = 60;
        
        _anmiationStyle = JDScanViewAnimationStyle_LineMove;
        _photoframeAngleStyle = JDScanViewPhotoframeAngleStyle_Outer;
        _colorAngle = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        
        _notRecoginitonArea = [UIColor colorWithRed:0. green:.0 blue:.0 alpha:.5];
        
        _photoframeAngleW = 24;
        _photoframeAngleH = 24;
        _photoframeLineW = 7;
    }
    return self;
}

@end

