//
//  AppDelegate.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoListTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    DemoListTableViewController *list = [[DemoListTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:list];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

@end
