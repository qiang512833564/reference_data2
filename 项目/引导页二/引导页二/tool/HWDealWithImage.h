//
//  HWDealWithImage.h
//  引导页二
//
//  Created by lizhongqiang on 16/4/26.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDealWithImage(view,frame,color,radius) \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{\
UIImage *image = [HWDealWithImage generateImageFromCGRect:frame color:color corner:radius];\
dispatch_sync(dispatch_get_main_queue(), ^{\
      if ([view class] == [UIButton class]) {\
        [view performSelector:@selector(setBackgroundImage:forState:) withObject:image withObject:UIControlStateNormal];\
     }else if([view class] == [UIImageView class]){\
        [view performSelector:@selector(image) withObject:image];\
     }\
});\
});

@interface HWDealWithImage : NSObject

+ (UIImage *)generateImageFromCGRect:(CGRect)frame color:(UIColor *)color corner:(CGFloat)radius;

@end
