//
//  LoginOutApi.m
//  PUClient
//
//  Created by RRLhy on 15/7/28.
//  Copyright (c) 2015年 RRLhy. All rights reserved.
//

#import "LoginOutApi.h"

@implementation LoginOutApi
{
    NSString * _token;
}
- (id)initWithUserToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (NSString*)requestUrl
{
    return @"/user/logout";
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPost;
}

- (id)requestArgument
{
    return @{@"token":_token};
}

/**
 *  设置缓存
 *
 *  @return 返回缓存持续的时间
 */
- (NSInteger)cacheTimeInSeconds {
    // 3分钟 = 180 秒
    return 0;
}

@end
