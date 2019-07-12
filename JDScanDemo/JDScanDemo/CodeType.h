//
//  CodeType.h
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDScanViewController.h"


@interface CodeType : NSObject
////当前选择的识别码制
@property (nonatomic, assign) JDScanCodeType scanCodeType;

+ (instancetype)sharedManager;


//返回native选择的识别码的类型
- (NSString*)nativeCodeType;

- (NSString*)nativeCodeWithType:(JDScanCodeType)type;

//返回SCANCODETYPE 类别数组
- (NSArray*)nativeTypes;


@end
