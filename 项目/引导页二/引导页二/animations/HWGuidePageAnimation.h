//
//  HWGuidePageAnimation.h
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HWGuidePageAnimation : NSObject

+ (void)startAnimation_scale:(UIView *)view queue:(dispatch_queue_t)queue;
+ (void)removeAnimation:(UIView *)view;

+ (void)startAnimation_alpha:(UIView *)view queue:(dispatch_queue_t)queue delegate:(id)target;

@end
