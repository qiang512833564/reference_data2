//
//  HWLoginViewController.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWLoginViewController.h"
#import "HWLoginPasswordView.h"
#import "HWDealWithImage.h"

#import <IQKeyboardManager.h>
@interface HWLoginViewController ()
@property (nonatomic, strong, readwrite) HWLoginPasswordView *textfieldView;
@property (nonatomic, strong, readwrite) UIImageView *iconImageView;
@property (nonatomic, strong, readwrite) UIButton *loginButton;
@property (nonatomic, strong, readwrite) UIButton *forwardBtn;
@property (nonatomic, strong, readwrite) UIImageView *bgImageView;
@end

@implementation HWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.textfieldView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.forwardBtn];
}
#pragma mark --- 组件配置
- (HWLoginPasswordView *)textfieldView{
    if (_textfieldView == nil) {
        _textfieldView = [[HWLoginPasswordView alloc]init];
        _textfieldView.center = (CGPoint){ CGRectGetWidth(self.view.bounds)/2.0, CGRectGetMaxY(self.iconImageView.frame)+85+110/2.0};
        _textfieldView.bounds = (CGRect){0,0, CGRectGetWidth(self.view.bounds) - 70, 110};
    }
    return _textfieldView;
}
- (UIImageView *)bgImageView{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _bgImageView.image = [UIImage imageNamed:@"Background"];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgImageView;
}
- (UIImageView *)iconImageView{
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.image = [UIImage imageNamed:@"start-up_LOGO1"];
        _iconImageView.center = (CGPoint){CGRectGetWidth(self.view.frame)/2.0, 222/2.0 + kCGImage_Height(_iconImageView)/2.0};
        _iconImageView.bounds = (CGRect){0,0, kCGImage_Width(_iconImageView), kCGImage_Height(_iconImageView)};
    }
    return _iconImageView;
}
- (UIButton *)loginButton{
    if (_loginButton == nil) {
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登陆" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _loginButton.center = (CGPoint){CGRectGetWidth(self.view.bounds)/2.0, CGRectGetMaxY(self.textfieldView.frame) + 64/2.0 + 90/2.0/2.0};
        _loginButton.bounds = (CGRect){0,0, CGRectGetWidth(self.textfieldView.frame), 90/2.0};
        
        UIColor *color = [UIColor redColor];
        kDealWithImage(_loginButton,  _loginButton.bounds, color, CGRectGetHeight(_loginButton.bounds)/2.0);
    }
    return _loginButton;
}
- (UIButton *)forwardBtn{
    if (_forwardBtn == nil) {
        _forwardBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forwardBtn setTitle:@"忘记密码？" forState: UIControlStateNormal];
        [_forwardBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
        CGFloat width = 134/2.0;
        _forwardBtn.frame = CGRectMake(CGRectGetWidth(self.textfieldView.frame)-width, CGRectGetMaxY(self.loginButton.frame) + 30/2.0, width, 50/2.0);
        _forwardBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _forwardBtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
