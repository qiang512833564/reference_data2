//
//  HWGuidePageView.h
//  引导页二
//
//  Created by lizhongqiang on 16/4/25.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWLoginPasswordView.h"

@interface HWGuidePageView : UIView

@property (nonatomic, strong, readonly) NSDictionary *params;

@property (nonatomic, strong, readwrite) UIViewController *vc;

- (instancetype)initWithFrame:(CGRect)frame params:(NSDictionary *)params;

- (void)startAnimation;

//- (void)endAnimation;

@end
