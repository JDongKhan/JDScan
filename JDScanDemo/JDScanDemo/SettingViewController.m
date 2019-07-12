//
//  SettingViewController.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "SettingViewController.h"
#import "CodeType.h"
#import "JDAlertAction.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSString*>*>* arrayItems;
@property (nonatomic, strong) NSString *cellIdentifier;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫码配置";
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.cellIdentifier = @"cell";
    [self arrayItems];
    [self tableView];
}

- (NSArray*)arrayItems {
    if (!_arrayItems) {
        
        _arrayItems = @[
                        @[@"ZXing"],
                        [CodeType sharedManager].nativeTypes];
    }
    return _arrayItems;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:_cellIdentifier];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


#pragma mark --DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayItems[section].count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"选择扫码库";
            break;
        case 1:
            return @"选择识别码制(ZXing库默认同时识别多个码制)";
            break;
        default:
            break;
    }
    return  @"";
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1){
            return @"ZXing库支持同时识别多个码制,所以这里全部勾上";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _arrayItems[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0:
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case 1:
            if (indexPath.row == [CodeType sharedManager].scanCodeType) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark --Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1: {
            if (indexPath.row == JDScanCodeTypeBarCodeITF) {
                [JDAlertAction showAlertWithTitle:@"提示" msg:@"只有ZXing支持ITF码制识别" buttonsStatement:@[@"知道了"] chooseBlock:nil];
            } else {
                [CodeType sharedManager].scanCodeType = indexPath.row;
            }
        }
            break;
        default:
            break;
    }
    [tableView reloadData];
}


@end
