//
//  CustomProgressHUD.m
//  CircleLoading
//
//  Created by lizhongqiang on 16/1/26.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "CustomProgressHUD.h"
#import "Animated_Circle.h"
#import <Masonry.h>
@interface CustomProgressHUD()
@property (nonatomic, strong)Animated_Circle *circleView;
@property (nonatomic, strong)UILabel *detailLabel;
@end
@implementation CustomProgressHUD
- (UIView *)circleView{
    if(_circleView == nil){
        _circleView = [[Animated_Circle alloc]initWithFrame:CGRectZero];
    }
    return _circleView;
}
- (UILabel *)detailLabel{
    if(_detailLabel == nil){
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _detailLabel.font = [UIFont systemFontOfSize:17];
        _detailLabel.textColor = [UIColor colorWithRed:66/255.f green:66/255.f blue:66/255.f alpha:1.0];
        _detailLabel.text = @"正在登录...";
        _detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLabel;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.circleView];
        [self addSubview:self.detailLabel];
    }
    return self;
}
-(void)layoutSubviews{
    __weak __typeof(&*self)weakSelf = self;
    
    [self.circleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.mas_centerX);
        make.top.mas_equalTo(weakSelf.mas_top).offset(10);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    [self.circleView layoutIfNeeded];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.mas_centerY).offset(50);
        make.width.mas_equalTo(weakSelf.mas_width);
        make.height.mas_equalTo(25);
    }];
}
@end
