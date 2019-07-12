//
//  NativeTableViewController.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "DemoListTableViewController.h"
#import <objc/message.h>

#import "JDPermission.h"
#import "JDPermissionSetting.h"
#import "JDAlertAction.h"
#import "CodeType.h"
#import "SettingViewController.h"

#import "JDScanViewStyle.h"
#import "DIYScanViewController.h"
#import "ScanResultViewController.h"
#import "CreateBarCodeViewController.h"
#import "StyleDIY.h"

@interface DemoListTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray<NSArray*>* arrayItems;
@end

@implementation DemoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self arrayItems];
    
    //显示配置按钮
    [self showSetttingButton];
}

- (NSArray*)arrayItems {
    if (!_arrayItems) {
        
        //界面DIY list
        NSArray *array1 = @[
                            @[@"模仿支付宝扫码区域",@"ZhiFuBaoStyle"],
                            @[@"模仿微信扫码区域",@"weixinStyle"],
                            @[@"无边框，内嵌4个角",@"InnerStyle"],
                            @[@"4个角在矩形框线上,网格动画",@"OnStyle"],
                            @[@"自定义颜色",@"changeColor"],
                            @[@"只识别框内",@"recoCropRect"],
                            @[@"改变尺寸",@"changeSize"],
                            @[@"条形码效果",@"notSquare"]
                            ];
        
        //条码生成
        NSArray *array2 = @[@[@"二维码/条形码生成",@"createBarCode"]
                            ];
        
        //识别图片
        NSArray *array3 = @[
                            @[@"相册",@"openLocalPhotoAlbum"]
                            ];
        
        _arrayItems = @[array1,array2,array3];
    }
    return _arrayItems;
}

- (void)showSetttingButton {
    //选择码扫码类型的按钮
    //把右侧的两个按钮添加到rightBarButtonItem
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightBtn setTitle:@"配置" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(settingViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightCunstomButtonView = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightCunstomButtonView;
}

- (void)settingViewController {
    SettingViewController *vc = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showError:(NSString*)str {
    [JDAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"当前使用库:ZXing";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return _arrayItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    NSArray *item = _arrayItems[section];
    return item.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* strTitle = @"title";
    switch (section) {
        case 0:
            strTitle = @"  DIY界面效果";
            break;
        case 1:
            strTitle = @"  条码生成";
            break;
        case 2:
            strTitle = @"  条码图片识别";
            break;
        default:
            break;
    }
    return strTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [_arrayItems[indexPath.section][indexPath.row]firstObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    [JDPermission authorizeWithType:JDPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            [weakSelf startWithIndexPath:indexPath];
        }
        else if(!firstTime) {
            [JDPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相机权限，是否前往设置" cancel:@"取消" setting:@"设置" ];
        }
    }];
}

- (void)startWithIndexPath:(NSIndexPath *)indexPath {
    NSArray* array = _arrayItems[indexPath.section][indexPath.row];
    NSString *methodName = array.lastObject;
    SEL normalSelector = NSSelectorFromString(methodName);
    if ([self respondsToSelector:normalSelector]) {
        ((void (*)(id, SEL))objc_msgSend)(self, normalSelector);
    }
}

#pragma mark ---自定义界面

- (void)openScanVCWithStyle:(JDScanViewStyle*)style {
    DIYScanViewController *vc = [DIYScanViewController new];
    vc.style = style;
    vc.isOpenInterestRect = YES;
    vc.scanCodeType = [CodeType sharedManager].scanCodeType;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark --模仿支付宝
- (void)ZhiFuBaoStyle {
    [self openScanVCWithStyle:[StyleDIY ZhiFuBaoStyle]];
}

#pragma mark -无边框，内嵌4个角
- (void)InnerStyle {
    [self openScanVCWithStyle:[StyleDIY InnerStyle]];
}

#pragma mark -无边框，内嵌4个角
- (void)weixinStyle {
    [self openScanVCWithStyle:[StyleDIY weixinStyle]];
}

#pragma mark -框内区域识别
- (void)recoCropRect {
    DIYScanViewController *vc = [DIYScanViewController new];
    vc.scanCodeType = [CodeType sharedManager].scanCodeType;

    vc.style = [StyleDIY recoCropRect];
    //开启只识别框内
    vc.isOpenInterestRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -4个角在矩形框线上,网格动画
- (void)OnStyle {
    [self openScanVCWithStyle:[StyleDIY OnStyle]];
}

#pragma mark -自定义4个角及矩形框颜色
- (void)changeColor {
    DIYScanViewController *vc = [DIYScanViewController new];
    vc.scanCodeType = [CodeType sharedManager].scanCodeType;

    vc.style = [StyleDIY changeColor];
    
    //开启只识别矩形框内图像功能
    vc.isOpenInterestRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -改变扫码区域位置
- (void)changeSize {
    [self openScanVCWithStyle:[StyleDIY changeSize]];
}

#pragma mark -非正方形，可以用在扫码条形码界面
- (void)notSquare {
    [self openScanVCWithStyle:[StyleDIY notSquare]];
}

#pragma mark --生成条码

- (void)createBarCode {
    CreateBarCodeViewController *vc = [[CreateBarCodeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 相册
- (void)openLocalPhotoAlbum {
    __weak __typeof(self) weakSelf = self;
    [JDPermission authorizeWithType:JDPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            [weakSelf openLocalPhoto];
        }
        else if (!firstTime) {
            [JDPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相册权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];
}

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    //部分机型可能导致崩溃
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __weak __typeof(self) weakSelf = self;
    [JDZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        
        JDScanResult *result = [[JDScanResult alloc]init];
        result.strScanned = str;
        result.imgScanned = image;
        result.strBarCodeType = [StyleDIY convertZXBarcodeFormat:barcodeFormat];
        
        [weakSelf scanResultWithArray:@[result]];
    }];
    
}

- (void)scanResultWithArray:(NSArray<JDScanResult*>*)array {
    if (array.count < 1) {
        [self showError:@"识别失败了"];
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (JDScanResult *result in array) {
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    if (!array[0].strScanned || [array[0].strScanned isEqualToString:@""] ) {
         [self showError:@"识别失败了"];
        return;
    }
    JDScanResult *scanResult = array[0];
    
    [self showNextVCWithScanResult:scanResult];
}


- (void)showNextVCWithScanResult:(JDScanResult*)strResult {
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.imgScanned;
    
    vc.strScan = strResult.strScanned;
    
    vc.strCodeType = strResult.strBarCodeType;
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
