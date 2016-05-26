//
//  HWLoginPasswordView.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWLoginPasswordView.h"
#define kCGImage_Width(imageView)  floor(CGImageGetWidth(imageView.image.CGImage)/kScale)
#define kCGImage_Height(imageView) floor(CGImageGetHeight(imageView.image.CGImage)/kScale)
#define kScale   ([UIScreen mainScreen].scale)
#define kTextfieldWidth (422)
@interface HWLoginPasswordView ()

@property (nonatomic, strong, readwrite) HWLoginTextfield *username_textfield;
@property (nonatomic, strong, readwrite) HWLoginTextfield *password_textfield;

@end

@implementation HWLoginPasswordView
#pragma mark --- 初始化组件
- (HWLoginTextfield *)username_textfield{
    if (_username_textfield == nil) {
        _username_textfield = [[HWLoginTextfield alloc]initWithParams:@{@"leftImage":@"log-in1",@"text":@"请输入手机号"}];
        _username_textfield.textfield.keyboardType = UIKeyboardTypeNumberPad;
        UIView *liner = [self liner];
        liner.tag = 100;
        [_username_textfield addSubview:liner];
    }
    return _username_textfield;
}
- (HWLoginTextfield *)password_textfield{
    if (_password_textfield == nil) {
        _password_textfield = [[HWLoginTextfield alloc]initWithParams:@{@"leftImage":@"log-in2",@"text":@"请输入密码",@"rightImage":@{@"normal":@"log-in_EYE1",@"select":@"log-in_EYE2"}}];
        _password_textfield.textfield.secureTextEntry = true;
        UIView *liner = [self liner];
        liner.tag = 100;
        [_password_textfield addSubview:liner];
    }
    return _password_textfield;
}
- (UIView *)liner{
    UIView *liner = [[UIView alloc]init];
    liner.backgroundColor = [UIColor colorWithRed:248/255.0 green:196/255.0 blue:91/255.0 alpha:1.0];
    return liner;
}
- (instancetype)init{
    if (self = [super init]) {
        [self addSubview: self.username_textfield];
        [self addSubview:self.password_textfield];
    }
    return self;
}
- (void)layoutSubviews{
    CGFloat height = CGRectGetHeight(self.bounds)/2.0;
    self.username_textfield.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), height);
    self.password_textfield.frame = CGRectMake(0, CGRectGetMaxY(self.username_textfield.frame), CGRectGetWidth(self.username_textfield.frame), height);
    
    UIView *liner1 = [self.username_textfield viewWithTag:100];
    UIView *liner2 = [self.password_textfield viewWithTag:100];
    
    liner1.frame = CGRectMake(0, CGRectGetHeight(self.username_textfield.frame)-0.5, CGRectGetWidth(self.username_textfield.frame), 0.5);
    liner2.frame = CGRectMake(0, CGRectGetHeight(self.password_textfield.frame)-0.5, CGRectGetWidth(self.password_textfield.frame), 0.5);
}

@end


@interface HWLoginTextfield () <UITextFieldDelegate>
@property (nonatomic, strong, readwrite) UIImageView *textfield_leftView;
@property (nonatomic, strong, readwrite) UIButton *textfield_rightView;
@property (nonatomic, strong, readwrite) UITextField *textfield;
@property (nonatomic, strong, readwrite) NSDictionary *params;

@property (nonatomic, strong, readwrite) UIImage *rightSelectedImage;
@end

@implementation HWLoginTextfield
#pragma mark --- 初始化组件

- (UIImageView *)textfield_leftView{
    if (_textfield_leftView == nil) {
        _textfield_leftView = [[UIImageView alloc]init];
        _textfield_leftView.image = [UIImage imageNamed:[self.params objectForKey:@"leftImage"]];
    }
    return _textfield_leftView;
}
- (UIButton *)textfield_rightView{
    if (_textfield_rightView == nil) {
        _textfield_rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSDictionary *imageDic = [self.params objectForKey:@"rightImage"];
        self.rightSelectedImage = [UIImage imageNamed:[imageDic objectForKey:@"select"]];
        
        [_textfield_rightView setImage:[UIImage imageNamed:[imageDic objectForKey:@"normal"]] forState:UIControlStateNormal];
        [_textfield_rightView setImage:self.rightSelectedImage forState:UIControlStateSelected];
        [_textfield_rightView addTarget:self action:@selector(password_action:) forControlEvents:UIControlEventTouchUpInside];
        _textfield_rightView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _textfield_rightView;
}
- (void)password_action:(UIButton *)btn{
    self.textfield.secureTextEntry = !self.textfield.secureTextEntry;
    btn.selected = !btn.selected;
    NSString *text = self.textfield.text;
    self.textfield.text = nil;
    self.textfield.text = text;
}
- (UITextField *)textfield{
    if (_textfield == nil) {
        _textfield = [[UITextField alloc]init];
        _textfield.delegate = self;
    }
    return _textfield;
}
- (instancetype)initWithParams:(NSDictionary *)parmas{
    if (self = [super init]) {
        self.params = parmas;
        
        if ([parmas objectForKey:@"leftImage"]) {
            [self addSubview:self.textfield_leftView];
        }
        [self addSubview:self.textfield];
        if ([parmas objectForKey:@"text"]){
            self.textfield.placeholder = [parmas objectForKey:@"text"];
        }
        if ([parmas objectForKey:@"rightImage"]){
            [self addSubview:self.textfield_rightView];
        }
    }
    return self;
}
- (void)layoutSubviews{
    CGFloat offX = 9;
    self.textfield_leftView.center = (CGPoint){ offX+ kCGImage_Width(self.textfield_leftView)/2.0, CGRectGetHeight(self.bounds)/2.0};
    self.textfield_leftView.bounds = (CGRect){0,0, kCGImage_Width(self.textfield_leftView), kCGImage_Height(self.textfield_leftView)};
    
    offX = CGRectGetMaxX(self.textfield_leftView.frame) + 26/2.0;
    self.textfield.center = (CGPoint){ offX + kTextfieldWidth/2.0, CGRectGetHeight(self.bounds)/2.0};
    self.textfield.bounds = (CGRect) {0,0, kTextfieldWidth, CGRectGetHeight(self.bounds)};
    if (_textfield_rightView) {
        offX = CGRectGetMaxX(self.bounds) - 10 - kCGImage_Width(self.textfield_rightView.imageView)/2.0;
        self.textfield_rightView.center = (CGPoint){ offX, CGRectGetHeight(self.bounds)/2.0};
        self.textfield_rightView.bounds = (CGRect){0,0, CGImageGetWidth(self.rightSelectedImage.CGImage)/kScale, CGImageGetHeight(self.rightSelectedImage.CGImage)/kScale};
    }
    
}
#pragma mark --- UITextfiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (_textfield_rightView) {
        if (range.location >= 11 && range.length == 0) {
            return false;
        }
    }else{
        if (range.location >= 20 && range.length == 0) {
            return false;
        }
    }
    return true;
}
@end
