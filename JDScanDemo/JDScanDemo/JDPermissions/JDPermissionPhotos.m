//
//  JDPermissionPhotos.m
//  JDScanDemo
//
//  Created by JD on 2019 /5/7.
//  Copyright © 2019 年 JD. All rights reserved.
//

#import "JDPermissionPhotos.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


@implementation JDPermissionPhotos

+ (BOOL)authorized {
    return [self authorizationStatus] == 3;
}


/**
 photo permission status

 @return
 0 :NotDetermined
 1 :Restricted
 2 :Denied
 3 :Authorized
 */
+ (NSInteger)authorizationStatus {
    if (@available(iOS 8,*)) {
        return  [PHPhotoLibrary authorizationStatus];
    } else {
        return  [ALAssetsLibrary authorizationStatus];
    }
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion {
    if (@available(iOS 8.0, *)) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                if (completion) {
                    completion(YES,NO);
                }
            }
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(status == PHAuthorizationStatusAuthorized,YES);
                        });
                    }
                }];
            }
                break;
            default: {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
        }
        
    } else {
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusAuthorized: {
                if (completion) {
                    completion(YES, NO);
                }
            }
                break;
            case ALAuthorizationStatusNotDetermined: {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                
                [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
                                           if (*stop) {
                                               if (completion) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(YES, NO);
                                                   });
                                                   
                                               }
                                           } else {
                                               *stop = YES;
                                           }
                                       }
                                     failureBlock:^(NSError *error) {
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(NO, YES);
                                             });
                                         }
                                     }];
            } break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied: {
                if (completion) {
                    completion(NO, NO);
                }
            }
            break;
        }
    }
  
}

@end
