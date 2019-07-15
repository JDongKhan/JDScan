//
//  JDPermission.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//


#import "JDPermission.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>


typedef void(^completionPermissionHandler)(BOOL granted,BOOL firstTime);


@implementation JDPermission


+ (void)authorizeWithType:(JDPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion {
    NSString *strClass = nil;
    switch (type) {
        case JDPermissionType_Location:
            strClass = @"JDPermissionLocation";
            break;
        case JDPermissionType_Camera:
            strClass = @"JDPermissionCamera";
            break;
        case JDPermissionType_Photos:
            strClass = @"JDPermissionPhotos";
            break;
        case JDPermissionType_Contacts:
            strClass = @"JDPermissionContacts";
            break;
        case JDPermissionType_Reminders:
            strClass = @"JDPermissionReminders";
            break;
        case JDPermissionType_Calendar:
             strClass = @"JDPermissionCalendar";
            break;
        case JDPermissionType_Microphone:
            strClass = @"JDPermissionMicrophone";
            break;
        case JDPermissionType_Health:
            strClass = @"JDPermissionHealth";
            break;
        case JDPermissionType_DataNetwork:
            strClass = @"JDPermissionData";
            break;
        case JDPermissionType_MediaLibrary:
            strClass = @"JDPermissionMediaLibrary";
            break;
            
        default:
            break;
    }
    
    if (strClass) {
        SEL sel = NSSelectorFromString(@"authorizeWithCompletion:");
        ((void(*)(id,SEL, completionPermissionHandler))objc_msgSend)(NSClassFromString(strClass),sel, completion);
    }
}

@end
