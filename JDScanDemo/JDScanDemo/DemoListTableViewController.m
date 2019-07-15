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

#import "JDScanViewStyle.h"
#import "DemoScanViewController.h"
#import "ScanResultViewController.h"
#import "DemoCreateBarCodeViewController.h"
#import "DemoStyle.h"

@interface DemoListTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray<NSDictionary *> *arrayItems;
@end

@implementation DemoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self arrayItems];
}

- (NSArray*)arrayItems {
    if (!_arrayItems) {
        
        //界面DIY list
        NSArray *array1 = @[
                            @{
                                @"title" : @"默认样式",
                                @"style" : @"style0"
                                },
                            @{
                                @"title" : @"样式一",
                                @"style" : @"style1"
                                },
                            @{
                                @"title" : @"样式二",
                                @"style" : @"style2"
                                },
                            @{
                                @"title" : @"样式三",
                                @"style" : @"style3"
                                },
                            @{
                                @"title" : @"样式四",
                                @"style" : @"style4"
                                },
                            @{
                                @"title" : @"样式五",
                                @"style" : @"style5"
                                },
                            @{
                                @"title" : @"样式六",
                                @"style" : @"style6"
                                },
                            @{
                                @"title" : @"样式七",
                                @"style" : @"style7"
                                },
                        
                            @{
                                @"title" : @"条形码效果",
                                @"style" : @"notSquare"
                                }
                            ];
        
        //条码生成
        NSArray *array2 = @[
                            @{
                                @"title" : @"二维码/条形码生成",
                                @"style" : @"createBarCode"
                                }
                            ];
        
        //识别图片
        NSArray *array3 = @[
                            @{
                                @"title" : @"相册",
                                @"style" : @"openLocalPhotoAlbum"
                                }
                            ];
        
        _arrayItems = @[@{
                            @"title" : @"扫码",
                            @"items" : array1
                            },
                        @{
                            @"title" : @"生成二维码",
                            @"items" : array2
                            },
                        @{
                            @"title" : @"相册识别",
                            @"items" : array3
                            }];
    }
    return _arrayItems;
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
    NSDictionary *item = _arrayItems[section];
    NSArray *items = item[@"items"];
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *item = _arrayItems[section];
    return item[@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *item = _arrayItems[indexPath.section];
    NSArray *items = item[@"items"];
    NSDictionary *rowItem = items[indexPath.row];
    cell.textLabel.text = rowItem[@"title"];
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
    NSDictionary *item = _arrayItems[indexPath.section];
    NSArray *items = item[@"items"];
    NSDictionary *rowItem = items[indexPath.row];
    NSString *style = rowItem[@"style"];
    [self openScanVCWithStyle:style];
}

#pragma mark ---自定义界面

- (void)openScanVCWithStyle:(NSString *)styleName {
    SEL sel = NSSelectorFromString(styleName);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel];
        return;
    }
    JDScanViewStyle *style = [DemoStyle performSelector:sel];
    DemoScanViewController *vc = [[DemoScanViewController alloc] init];
    vc.style = style;
    vc.onlyScanCenterRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
}














#pragma mark --------- 生成条码 ----------

- (void)createBarCode {
    DemoCreateBarCodeViewController *vc = [[DemoCreateBarCodeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --------- 相册 -----------
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
    [JDScanner recognizeImage:image block:^(JDScanResult *result) {
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
        NSLog(@"scanResult:%@",result.text);
    }
    
    if (!array[0].text || [array[0].text isEqualToString:@""] ) {
         [self showError:@"识别失败了"];
        return;
    }
    JDScanResult *scanResult = array[0];
    
    [self showNextVCWithScanResult:scanResult];
}


- (void)showNextVCWithScanResult:(JDScanResult*)strResult {
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.image;
    vc.strScan = strResult.text;
    vc.strCodeType = strResult.type;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
