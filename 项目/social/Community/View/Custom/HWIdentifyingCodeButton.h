//
//  HWIdentifyingCodeButton.h
//  Community
//
//  Created by hw500027 on 15/4/7.
//  Copyright (c) 2015年 caijingpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HWIdentifyingCodeButtonDelegate <NSObject>
-(void)btnPlaySound;
@end

@interface HWIdentifyingCodeButton : UIButton
-(void)btnFirstClick;
@property (nonatomic, weak) id <HWIdentifyingCodeButtonDelegate> identifyingCodeButtonDelegate;
@property (nonatomic, strong) NSTimer *timer;
@end

