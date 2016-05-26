//
//  HWGuidePageAnimation.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWGuidePageAnimation.h"
#import <objc/runtime.h>
@implementation HWGuidePageAnimation

static void *scale_key = &scale_key;

+ (void)startAnimation_alpha:(UIView *)view queue:(dispatch_queue_t)queue delegate:(id)target{
    
    if([objc_getAssociatedObject(self, [NSStringFromClass([view class]) UTF8String]) isEqualToString: @"lock"]){
        return;
    }
    objc_setAssociatedObject(self, [NSStringFromClass([view class]) UTF8String], @"lock", OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    dispatch_barrier_async(queue, ^{
        if (view.layer.animationKeys) {
            return ;
        }
        CABasicAnimation *alpha_animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alpha_animation.duration = 0.7;
        alpha_animation.fromValue = @(0);
        alpha_animation.toValue = @(1);
        alpha_animation.delegate = target;
        alpha_animation.removedOnCompletion = NO;
        alpha_animation.fillMode = kCAFillModeForwards;
        if (view.tag == 1000) {
            objc_setAssociatedObject(view, "view_key", @(true), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
       dispatch_sync(dispatch_get_main_queue(), ^{
           [view.layer addAnimation:alpha_animation forKey:@"alpha_scale"];
           objc_setAssociatedObject(self, [NSStringFromClass([view class]) UTF8String], @"unlock", OBJC_ASSOCIATION_COPY_NONATOMIC);
       });
    });
    dispatch_barrier_async(queue, ^{
        
    });
}

+ (void)removeAnimation:(UIView *)view{
    view.alpha = 0;
    [view.layer removeAllAnimations];
    objc_removeAssociatedObjects(view);
}

+ (void)startAnimation_scale:(UIView *)view queue:(dispatch_queue_t)queue{
    
    CGFloat duration = 0.7;
    
    if([objc_getAssociatedObject(self,scale_key) boolValue]){
        objc_removeAssociatedObjects(self);
    }
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    CABasicAnimation *scale_animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scale_animation.duration = duration;
    scale_animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1)];
    scale_animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scale_animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *alpha_animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha_animation.duration = duration;
    alpha_animation.fromValue = @(0);
    alpha_animation.toValue = @(1);
    
    group.animations = @[scale_animation,alpha_animation];
    
    [view.layer addAnimation:group forKey:@"alpha_scale"];
    
    dispatch_async(queue, ^{
        BOOL finished = false;
        while (!finished) {
            
            [[NSRunLoop currentRunLoop]addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, duration+0.1, true);//A flag indicating whether the run loop should exit after processing one source
            
            finished = [objc_getAssociatedObject(self,scale_key) isEqualToString:@"start"];
        }
        
    });
}
+ (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim class] == [CABasicAnimation class]) {
        
    }else{
        if (flag) {
            objc_setAssociatedObject(objc_getClass("HWGuidePageAnimation"), scale_key, @"start", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
    }
    
}

@end
