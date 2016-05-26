//
//  HWGuidePageView.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWGuidePageView.h"
#import "HWGuidePageAnimation.h"
#import <objc/runtime.h>

@interface HWGuidePageView ()
{
    dispatch_queue_t _queue;
}
@property (nonatomic, strong, readwrite) NSDictionary *params;

@property (nonatomic, strong, readwrite) UIImageView *textImageView;

@property (nonatomic, strong, readwrite) UIImageView *picImageView;

@property (nonatomic, strong, readwrite) UIButton *enterButton;

@end

@implementation HWGuidePageView

- (UIImageView *)textImageView{
    if (_textImageView == nil) {
        _textImageView = [[UIImageView alloc]init];
        _textImageView.contentMode = UIViewContentModeScaleAspectFill;
        _textImageView.image = [UIImage imageNamed:self.params[@"textImage"]];
    }
    return _textImageView;
}
- (UIImageView *)picImageView{
    if (_picImageView == nil) {
        _picImageView = [[UIImageView alloc]init];
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.image = [UIImage imageNamed:self.params[@"picImage"]];
    }
    return _picImageView;
}
- (UIButton *)enterButton{
    if(_enterButton == nil){
        _enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterButton.tag = 1000;
        [_enterButton setImage:[UIImage imageNamed:self.params[@"enterImage"]] forState:UIControlStateNormal];
        [_enterButton addTarget:self action:NSSelectorFromString(@"enterAction") forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterButton;
}

- (instancetype)initWithFrame:(CGRect)frame params:(NSDictionary *)params{
    if (self = [super initWithFrame:frame]) {
        self.params = params;
        
        self->_queue = dispatch_queue_create("animationController", DISPATCH_QUEUE_SERIAL);
        
        if ([params objectForKey:@"textImage"]) {
            [self addSubview:self.textImageView];
        }
        if ([params objectForKey:@"picImage"]) {
            [self addSubview:self.picImageView];
        }
        if ([params objectForKey:@"enterImage"]) {
            [self addSubview:self.enterButton];
        }
        self.userInteractionEnabled = YES;
        
        [self restartState];
        
        [self layoutSubviews_custom];
        
        
    }
    return self;
}
#pragma mark --- 组件布局
- (void)layoutSubviews_custom{
    
    CGFloat y = 98/2.0;
    
    self.textImageView.center = (CGPoint){ kCenterX, y+floor(kCGImage_Height(self.textImageView)/2.0)};
    self.textImageView.bounds = (CGRect){0,0, kCGImage_Width(self.textImageView), kCGImage_Height(self.textImageView)};
    
    y = CGRectGetMaxY(self.textImageView.frame) + 76/2.0;
    self.picImageView.center = (CGPoint){ kCenterX, y + floor(kCGImage_Height(self.picImageView)/2.0)};
    self.picImageView.bounds = (CGRect){0,0, kCGImage_Width(self.picImageView),kCGImage_Height(self.picImageView)};
    
    if (_enterButton) {
        y = CGRectGetMaxY(self.picImageView.frame) + 62/2.0;
        self.enterButton.center = (CGPoint){ kCenterX, y + floor(kCGImage_Height(self.enterButton.imageView)/2.0)};
        self.enterButton.bounds = (CGRect){0,0, kCGImage_Width(self.enterButton.imageView), kCGImage_Height(self.enterButton.imageView)};
    }
}
#pragma mark --- 

#pragma mark --- 动画
- (void)restartState{
    [HWGuidePageAnimation removeAnimation:self.textImageView];
    if (_enterButton) {
        [HWGuidePageAnimation removeAnimation:self.enterButton];
    }
    [HWGuidePageAnimation removeAnimation:self.picImageView];
}

- (void)startAnimation{
    [self restartState];
    
    [HWGuidePageAnimation startAnimation_scale:self.picImageView queue:self->_queue];
    
    [HWGuidePageAnimation startAnimation_alpha:self.textImageView queue:self->_queue delegate:self];
}
- (void)animationDidStart:(CAAnimation *)anim{
    if (_enterButton){
        _enterButton.alpha = 0;
    }
    _textImageView.alpha = 0;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag == false) {
        return;
    }
    if (objc_getAssociatedObject(_enterButton,"view_key")) {
        _enterButton.alpha = 1;
        return;
    }
    if (_enterButton) {
        [HWGuidePageAnimation startAnimation_alpha:self.enterButton queue:self->_queue delegate:self];
    }
    
}
#pragma mark --- 事件响应
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == NSSelectorFromString(@"enterAction")) {
        objc_removeAssociatedObjects([HWGuidePageAnimation class]);
        return NO;
    }
    return [super resolveInstanceMethod:sel];
}
- (id)forwardingTargetForSelector:(SEL)aSelector{
    return self.vc;
}
@end
