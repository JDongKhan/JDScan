
//
//  JDScanView.m
//  JDScan
//
//  Created by WJD on 17/5/11.
//  Copyright © 2017年 WJD. All rights reserved.
//

#import "JDScanView.h"


NS_ASSUME_NONNULL_BEGIN

@interface JDScanView()

//扫码区域各种参数
@property (nonatomic, strong,nullable) JDScanViewStyle *viewStyle;

/**
 @brief  启动相机时 菊花等待
 */
@property(nonatomic,strong,nullable)UIActivityIndicatorView* activityView;

/**
 @brief  启动相机中的提示文字
 */
@property(nonatomic,strong,nullable)UILabel *labelReadying;

@end

NS_ASSUME_NONNULL_END

@implementation JDScanView {
    CGRect _scanRect;
}

- (id)initWithFrame:(CGRect)frame style:(JDScanViewStyle*)style {
    if (self = [super initWithFrame:frame]) {
        self.viewStyle = style;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawScanRect];
}

- (void)startDeviceReadyingWithText:(NSString*)text {
    CGRect scanRect = self.scanRect;
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = CGRectGetMinY(scanRect);
    //设备启动状态提示
    if (!_activityView) {
        self.activityView = [[UIActivityIndicatorView alloc]init];
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
      
        self.labelReadying = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, scanRect.size.width, 30)];
        _labelReadying.backgroundColor = [UIColor clearColor];
        _labelReadying.textColor  = [UIColor whiteColor];
        _labelReadying.font = [UIFont systemFontOfSize:18.];
        _labelReadying.text = text;
        [_labelReadying sizeToFit];
        CGRect frame = _labelReadying.frame;
        CGPoint centerPt = CGPointMake(self.frame.size.width/2 + 20, YMinRetangle + scanRect.size.height/2);
        _labelReadying.bounds = CGRectMake(0, 0, frame.size.width,30);
        _labelReadying.center = centerPt;
        
        _activityView.bounds = CGRectMake(0, 0, 30, 30);
        if (text)
            _activityView.center = CGPointMake(centerPt.x - frame.size.width/2 - 24 , _labelReadying.center.y);
        else
            _activityView.center = CGPointMake(self.frame.size.width/2 , _labelReadying.center.y);
        
        [self addSubview:_activityView];
        [self addSubview:_labelReadying];
        [_activityView startAnimating];
    }

}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)stopDeviceReadying {
    if (_activityView) {
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        [_labelReadying removeFromSuperview];
        
        self.activityView = nil;
        self.labelReadying = nil;
    }
}

/**
 *  开始扫描动画
 */
- (void)startScanAnimation {
    [_viewStyle.scanAnimation startAnimatingWithRect:self.scanRect inView:self];
}

/**
 *  结束扫描动画
 */
- (void)stopScanAnimation {
    [_viewStyle.scanAnimation stopAnimating];
}


- (CGRect)scanRect {
    int XRetangleLeft = _viewStyle.horizontalMargin;
    CGSize sizeRetangle = CGSizeMake(self.frame.size.width - XRetangleLeft*2, self.frame.size.width - XRetangleLeft*2);
    if (_viewStyle.whRatio != 1) {
        CGFloat w = sizeRetangle.width;
        CGFloat h = w / _viewStyle.whRatio;
        NSInteger hInt = (NSInteger)h;
        h  = hInt;
        sizeRetangle = CGSizeMake(w, h);
    }
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - _viewStyle.verticalOffset;
     _scanRect = CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
    return _scanRect;
}


- (void)drawScanRect {
    CGRect scanRect = self.scanRect;
    int XRetangleLeft = scanRect.origin.x;
    
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = scanRect.origin.y;
    CGFloat YMaxRetangle = CGRectGetMaxY(scanRect);
    CGFloat XRetangleRight = self.frame.size.width - XRetangleLeft;
    CGSize sizeRetangle = scanRect.size;
    
    NSLog(@"扫码区域:%@",NSStringFromCGRect(scanRect));
    CGContextRef context = UIGraphicsGetCurrentContext();
    //非扫码区域半透明
    {
        //设置非识别区域颜色
        const CGFloat *components = CGColorGetComponents(_viewStyle.backgroundColor.CGColor);
        CGFloat red_notRecoginitonArea = components[0];
        CGFloat green_notRecoginitonArea = components[1];
        CGFloat blue_notRecoginitonArea = components[2];
        CGFloat alpa_notRecoginitonArea = components[3];
        CGContextSetRGBFillColor(context, red_notRecoginitonArea, green_notRecoginitonArea,
                                 blue_notRecoginitonArea, alpa_notRecoginitonArea);
        //扫码区域上面填充
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle);
        CGContextFillRect(context, rect);
        
        //扫码区域左边填充
        rect = CGRectMake(0, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        
        //扫码区域右边填充
        rect = CGRectMake(XRetangleRight, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        
        //扫码区域下面填充
        rect = CGRectMake(0, YMaxRetangle, self.frame.size.width,self.frame.size.height - YMaxRetangle);
        CGContextFillRect(context, rect);
        //执行绘画
        CGContextStrokePath(context);
    }
    
    //中间画矩形(正方形)
    if (_viewStyle.borderWidth > 0) {
        CGContextSetStrokeColorWithColor(context, _viewStyle.borderColor.CGColor);
        CGContextSetLineWidth(context, _viewStyle.borderWidth);
        CGContextAddRect(context, CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height));
        //CGContextMoveToPoint(context, XRetangleLeft, YMinRetangle);
        //CGContextAddLineToPoint(context, XRetangleLeft+sizeRetangle.width, YMinRetangle);
        CGContextStrokePath(context);
    }
    
    //画矩形框4格外围相框角
    //相框角的宽度和高度
    int wAngle = _viewStyle.cornerWidth;
    int hAngle = _viewStyle.cornerHeight;
    
    //4个角的 线的宽度
    CGFloat cornerLineWidth = _viewStyle.cornerLineWidth;// 经验参数：6和4
    
    //画扫码矩形以及周边半透明黑色坐标参数
    CGFloat diffAngle = 0.0f;
    //diffAngle = linewidthAngle / 2; //框外面4个角，与框有缝隙
    //diffAngle = linewidthAngle/2;  //框4个角 在线上加4个角效果
    //diffAngle = 0;//与矩形框重合
    
    switch (_viewStyle.cornerStyle) {
        case JDScanViewCornerStyleOuter: {
            diffAngle = cornerLineWidth/3;//框外面4个角，与框紧密联系在一起
            break;
        }
        case JDScanViewCornerStyleInner: {
            diffAngle = -_viewStyle.cornerLineWidth/2;
             break;
        }
        default: {
            diffAngle = 0;
        }
            break;
    }
    
    CGContextSetStrokeColorWithColor(context, _viewStyle.cornerColor.CGColor);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, cornerLineWidth);
    
    //
    CGFloat leftX = XRetangleLeft - diffAngle;
    CGFloat topY = YMinRetangle - diffAngle;
    CGFloat rightX = XRetangleRight + diffAngle;
    CGFloat bottomY = YMaxRetangle + diffAngle;
    
    //左上角水平线
    CGContextMoveToPoint(context, leftX-cornerLineWidth/2, topY);
    CGContextAddLineToPoint(context, leftX + wAngle, topY);
    
    //左上角垂直线
    CGContextMoveToPoint(context, leftX, topY-cornerLineWidth/2);
    CGContextAddLineToPoint(context, leftX, topY+hAngle);
    
    
    //左下角水平线
    CGContextMoveToPoint(context, leftX-cornerLineWidth/2, bottomY);
    CGContextAddLineToPoint(context, leftX + wAngle, bottomY);
    
    //左下角垂直线
    CGContextMoveToPoint(context, leftX, bottomY+cornerLineWidth/2);
    CGContextAddLineToPoint(context, leftX, bottomY - hAngle);
    
    
    //右上角水平线
    CGContextMoveToPoint(context, rightX+cornerLineWidth/2, topY);
    CGContextAddLineToPoint(context, rightX - wAngle, topY);
    
    //右上角垂直线
    CGContextMoveToPoint(context, rightX, topY-cornerLineWidth/2);
    CGContextAddLineToPoint(context, rightX, topY + hAngle);
    
    
    //右下角水平线
    CGContextMoveToPoint(context, rightX+cornerLineWidth/2, bottomY);
    CGContextAddLineToPoint(context, rightX - wAngle, bottomY);
    
    //右下角垂直线
    CGContextMoveToPoint(context, rightX, bottomY+cornerLineWidth/2);
    CGContextAddLineToPoint(context, rightX, bottomY - hAngle);
    
    CGContextStrokePath(context);
}


//根据矩形区域，获取识别区域
+ (CGRect)getScanRectWithPreView:(UIView*)view scanRect:(CGRect)scanRect {
    int XRetangleLeft = scanRect.origin.x;
    CGSize sizeRetangle = scanRect.size;
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = scanRect.origin.y;
    
    //扫码区域坐标
    CGRect cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
    //计算兴趣区域
    CGRect rectOfInterest;
    
    //ref:http://www.cocoachina.com/ios/20141225/10763.html
    CGSize size = view.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
       
        
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
        
        
    }
    
    
    return rectOfInterest;
}

//根据矩形区域，获取识别区域
+ (CGRect)getZXingScanRectWithPreView:(UIView*)view scanRect:(CGRect)scanRect {
    int XRetangleLeft = scanRect.origin.x;
    CGSize sizeRetangle = scanRect.size;
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = scanRect.origin.y;
    
    XRetangleLeft = XRetangleLeft/view.frame.size.width * 1080;
    YMinRetangle = YMinRetangle / view.frame.size.height * 1920;
    CGFloat width  = sizeRetangle.width / view.frame.size.width * 1080;
    CGFloat height = sizeRetangle.height / view.frame.size.height * 1920;
    
    //扫码区域坐标
    CGRect cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, width,height);
    
    return cropRect;
}


@end
