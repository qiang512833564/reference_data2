//
//  HWDealWithImage.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/26.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWDealWithImage.h"

#define kDefaultGlobalQueue (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);)
#define kScale ([UIScreen mainScreen].scale)

@implementation HWDealWithImage

+ (UIImage *)generateImageFromCGRect:(CGRect)frame color:(UIColor *)color corner:(CGFloat)radius{

    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(frame)*kScale, CGRectGetHeight(frame)*kScale, 8, 0, colorRef, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(frame)*kScale);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGFloat width = frame.size.width*kScale;
    CGFloat height = frame.size.height*kScale;
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
     radius =  radius*kScale;
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius, 0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);
    // 填充半透明黑色
    //CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGImageRef ref = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    return [UIImage imageWithCGImage:ref];
}

@end
