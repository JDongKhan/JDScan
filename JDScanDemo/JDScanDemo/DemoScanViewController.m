//
//  DemoScanViewController.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "DemoScanViewController.h"
#import "JDAlertAction.h"
#import "ScanResultViewController.h"


@interface DemoScanViewController ()

@end

@implementation DemoScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraWakeMessage = @"相机启动中";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"调试" style:UIBarButtonItemStyleDone target:self action:@selector(setting)];
}

- (void)setting {
    self.isNeedScanImage = !self.isNeedScanImage;
}

#pragma mark -实现类继承该方法，作出对应处理

- (void)scanResultWithArray:(NSArray<JDScanResult*>*)array {
    if (!array ||  array.count < 1) {
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    JDScanResult *scanResult = array[0];
    NSString *strResult = scanResult.text;
//    self.scanImage = scanResult.imgScanned;
    if (!strResult) {
        [self popAlertMsgWithScanResult:nil];
        return;
    }
    
    //TODO: 这里可以根据需要自行添加震动或播放声音提示相关代码
    //...
    
    [self showNextVCWithScanResult:scanResult];
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult {
    if (!strResult) {
        strResult = @"识别失败";
    }
    __weak __typeof(self) weakSelf = self;
    [JDAlertAction showAlertWithTitle:@"扫码内容" msg:strResult buttonsStatement:@[@"知道了"] chooseBlock:^(NSInteger buttonIdx) {
        [weakSelf start];
    }];
}

- (void)showNextVCWithScanResult:(JDScanResult*)strResult {
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.image;
    vc.strScan = strResult.text;
    vc.strCodeType = strResult.type;
    [self.navigationController pushViewController:vc animated:YES];
}

@end


