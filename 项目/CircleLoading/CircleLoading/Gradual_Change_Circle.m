//
//  Gradual_Change_Circle.m
//  CircleLoading
//
//  Created by lizhongqiang on 16/1/27.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "Gradual_Change_Circle.h"

@implementation Gradual_Change_Circle

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(frame)/2.0, CGRectGetHeight(frame)/2.0) radius:MIN(CGRectGetHeight(frame)/2.0, CGRectGetWidth(frame)) startAngle:0 endAngle:M_PI+M_PI_2+M_PI_4 clockwise:YES];
        layer.path = path.CGPath;
        layer.lineWidth = 8;
        layer.strokeStart = 0.0f;
        layer.strokeEnd = 1.0f;
        layer.lineCap = @"round";
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor colorWithRed:21/255.0 green:108/255.0 blue:1 alpha:1.0].CGColor;
    }
    return self;
}

+(Class)layerClass{
    return [CAShapeLayer class];
}
#
@end
