//
//  HWLoginPasswordView.h
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCenterX floor([UIScreen mainScreen].bounds.size.width/2.0)
#define kScale   ([UIScreen mainScreen].scale)
#define kCGImage_Width(imageView)  floor(CGImageGetWidth(imageView.image.CGImage)/kScale)
#define kCGImage_Height(imageView) floor(CGImageGetHeight(imageView.image.CGImage)/kScale)
@class HWLoginTextfield;

@interface HWLoginPasswordView : UIView

@property (nonatomic, strong, readonly) HWLoginTextfield *username_textfield;
@property (nonatomic, strong, readonly) HWLoginTextfield *password_textfield;

@end

@interface HWLoginTextfield : UIView
@property (nonatomic, strong, readonly) UITextField *textfield;
- (instancetype)initWithParams:(NSDictionary *)parmas;

@end