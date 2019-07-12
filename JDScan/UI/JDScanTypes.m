//
//  JDScanTypes.m
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import "JDScanTypes.h"

@implementation JDScanResult

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type {
    if (self = [super init]) {
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }
    return self;
}

@end

