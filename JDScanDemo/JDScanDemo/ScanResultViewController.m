//
//  ScanResultViewController.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "ScanResultViewController.h"

@interface ScanResultViewController ()

@property (strong, nonatomic) UILabel *sourceLabel;

@property (strong, nonatomic) UIImageView *scanImg;
@property (strong, nonatomic) UILabel *labelScanText;
@property (strong, nonatomic) UILabel *labelScanCodeType;
@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scanImg = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200 )/2, 30, 200, 200)];
    [self.view addSubview:self.scanImg];
    
    self.labelScanCodeType = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanImg.frame), self.view.frame.size.width, 50)];
    self.labelScanCodeType.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelScanCodeType];
    
    self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.labelScanCodeType.frame), self.view.frame.size.width, 30)];
    self.sourceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.sourceLabel];
    
    self.labelScanText = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-160, self.view.frame.size.width-20, 150)];
    self.labelScanText.textAlignment = NSTextAlignmentCenter;
    self.labelScanText.numberOfLines = 0;
    self.labelScanText.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.labelScanText];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_imgScan) {
        _scanImg.backgroundColor = [UIColor grayColor];
    }
    _scanImg.image = _imgScan;
    _labelScanText.text = _strScan;
    _labelScanCodeType.text = [NSString stringWithFormat:@"类型:%@",_strCodeType];
    _sourceLabel.text = _source;
}


@end
