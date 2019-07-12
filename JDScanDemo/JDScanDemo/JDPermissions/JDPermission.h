//
//  JDPermission.h
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDPermissionSetting.h"


typedef NS_ENUM(NSInteger,JDPermissionType) {
    JDPermissionType_Location,
    JDPermissionType_Camera,
    JDPermissionType_Photos,
    JDPermissionType_Contacts,
    JDPermissionType_Reminders,
    JDPermissionType_Calendar,
    JDPermissionType_Microphone,
    JDPermissionType_Health,
    JDPermissionType_DataNetwork,
    JDPermissionType_MediaLibrary
};

@interface JDPermission : NSObject

/**
 only effective for location servince,other type reture YES


 @param type permission type,when type is not location,return YES
 @return YES if system location privacy service enabled NO othersize
 */
+ (BOOL)isServicesEnabledWithType:(JDPermissionType)type;


/**
 whether device support the type

 @param type permission type
 @return  YES if device support

 */
+ (BOOL)isDeviceSupportedWithType:(JDPermissionType)type;

/**
 whether permission has been obtained, only return status, not request permission
 for example, u can use this method in app setting, show permission status
 in most cases, suggest call "authorizeWithType:completion" method

 @param type permission type
 @return YES if Permission has been obtained,NO othersize
 */
+ (BOOL)authorizedWithType:(JDPermissionType)type;


/**
 request permission and return status in main thread by block.
 execute block immediately when permission has been requested,else request permission and waiting for user to choose "Don't allow" or "Allow"

 @param type permission type
 @param completion May be called immediately if permission has been requested
 granted: YES if permission has been obtained, firstTime: YES if first time to request permission
 */
+ (void)authorizeWithType:(JDPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion;





@end
