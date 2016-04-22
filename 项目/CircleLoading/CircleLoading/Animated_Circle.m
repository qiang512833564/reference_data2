//
//  Animated_Circle.m
//  CircleLoading
//
//  Created by lizhongqiang on 16/1/26.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "Animated_Circle.h"

typedef void (^animationCompletionBlock)(void);
#define kAnimationCompletionBlock @"animationCompletionBlock"

@implementation Animated_Circle

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (void)layoutSubviews{
 
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = getPath(self).CGPath;
    layer.lineWidth = 2;
    layer.strokeStart = 0.0f;
    layer.strokeEnd = 1.0f;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor colorWithRed:21/255.0 green:108/255.0 blue:1 alpha:1.0].CGColor;
    [self begin_animation];
 
    
}
- (void)begin_animation{
    CABasicAnimation *start = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    start.duration = 1;
    start.fromValue = @(0.0);
    start.toValue = @(1);
    [start setBeginTime:0];
    
    
    //注意，这里旋转不能直接设置transform来旋转，否则，该动画的旋转，仅仅只是最初与最终角度，之间的旋转（系统会以最小的角度去达到目的）
    CABasicAnimation *roate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    roate.fromValue = @(0);
    roate.toValue = @(M_PI*6-M_PI_4);
    roate.beginTime = start.duration;
    roate.duration = 3;
    
    CABasicAnimation *end = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    end.fromValue = @(0);
    end.toValue = @(1);
    end.duration = 1;
    [end setBeginTime:roate.beginTime+roate.duration+0.1];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[start,roate,end];//end
    group.duration = end.beginTime+end.duration;
    group.delegate = self;
    //方法--监听动画是否结束
    [group setValue:@"animation" forKey:@"animationID--"];
    animationCompletionBlock theBlock = ^(void){
        NSLog(@"动画结束");
    };
    /*
     setValue:forKey: 为指定 key 设置 value，如果原来有值，就用 value 替换。
     如果指定的 key 不存在，就会向 receiver 发送 setValue:forUndefinedKey: 消息，默认返回 NSUndefinedKeyException 异常，subclass 时可以改变该方法的行为。
     但是---目前动画却是个特例-----不清楚其内部实现---目测应该是通过runtime实现
     */
    [group setValue:theBlock  forKey:kAnimationCompletionBlock];
    
    [self.layer addAnimation:group forKey:@"MyGroup"];
    
    [self performSelector:@selector(roateLayer) withObject:nil afterDelay:roate.beginTime+roate.duration];
}
- (void)roateLayer{
//    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
//    layer.strokeStart = 0;
    self.layer.transform = CATransform3DRotate(self.layer.transform,M_PI*4-M_PI_4, 0, 0, 1);
   
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"%s",__func__);
    [self begin_animation];
    NSLog(@"%@",[anim valueForKey:@"animationID--"]);
    
    animationCompletionBlock theBlock = [anim valueForKey:kAnimationCompletionBlock];
    if (theBlock) {
        theBlock();
    }
    //_transform = self.layer.transform;
}
UIBezierPath *getPath(UIView *view){

    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(view.frame)/2.0, CGRectGetHeight(view.frame)/2.0) radius:MIN(CGRectGetHeight(view.frame)/2.0, CGRectGetWidth(view.frame)) startAngle:0 endAngle:M_PI+M_PI_2+M_PI_4 clockwise:YES];
    return path;
}
+(Class)layerClass{
    return [CAShapeLayer class];
}

@end
