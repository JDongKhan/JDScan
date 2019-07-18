//
//  ScanResultViewController.h
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanResultViewController : UIViewController

@property (nonatomic, strong) UIImage *imgScan;
@property (nonatomic, copy) NSString *strScan;

@property (nonatomic,copy) NSString *strCodeType;

@property (nonatomic,copy) NSString *source;

@end
