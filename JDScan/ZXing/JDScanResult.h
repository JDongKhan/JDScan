//
//  JDScanResult.h
//  JDScan
//
//  Created by JD on 2019/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDScanResult : NSObject

/**
 识别的文本
 */
@property (nonatomic, copy) NSString *text;

/**
 码类型
 */
@property (nonatomic, copy) NSString *type;

/**
 识别成功的图片
 */
@property (nonatomic, strong, nullable) UIImage *image;

@end

NS_ASSUME_NONNULL_END
