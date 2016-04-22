//
//  HWShareView.m
//  Community
//
//  Created by WeiYuanlin on 15/1/15.
//  Copyright (c) 2015年 caijingpeng. All rights reserved.
//  功能描述：分享视图
//  修改记录
//      李中强 2015-01-17 添加头注释 相关人员补齐注释
//      魏远林 2015-01-15 创建文件
//      魏远林 2015-01-19 规范代码
//      魏远林 2015-01-28 添加枚举类型，区分分享的来源
#import "HWShareView.h"
#import "WXApi.h"

@implementation HWShareView
{
    NSArray *_imageArray;
    NSArray *_nameArray;
    UIButton *_shareButton;
    UILabel *_nameLabel;
}
@synthesize shareContent;
@synthesize shareImage;
@synthesize shareUrl;
@synthesize showView;
@synthesize presentController;
@synthesize superView;
@synthesize shareTitle;

- (id)initWithShareTitile:(NSString *)title content:(NSString *)content image:(UIImage *)image shareUrl:(NSString *)urlStr;
{
    self = [super init];
    if (self)
    {
        self.shareTitle = title;
        self.shareContent = content;
        self.shareImage = image;
        self.shareUrl = urlStr;
        self.gameId = [NSString string];
        self.copiesUrl = [NSString string];
    }
    return self;
}

- (void)showInView:(UIView *)view presentController:(UIViewController *)controller
{
    showView = view;
    presentController = controller;
    int installCase = 0;
    
    if ([Utility isInstalledQQAndInstalledWX])
    {
        installCase = 0;
        _imageArray = @[@"share_weixinfriend161",@"share_weixin161",@"share_weibo161",@"share_qq161",@"share_qzone161",@"share_links161"];
        _nameArray = @[@"朋友圈",@"微信好友",@"新浪微博",@"QQ",@"QQ空间",@"复制链接"];
    }
    else
    {
        if ([Utility isInstalledWX])
        {
            installCase = 1;
            _imageArray = @[@"share_weixinfriend161",@"share_weixin161",@"share_weibo161",@"share_links161"];
            _nameArray = @[@"朋友圈",@"微信好友",@"新浪微博",@"复制链接"];
        }
        else if ([Utility isInstalledQQ])
        {
            installCase = 2;
            _imageArray = @[@"share_weibo161",@"share_qq161",@"share_qzone161",@"share_links161"];
            _nameArray = @[@"新浪微博",@"QQ",@"QQ空间",@"复制链接"];
        }
        else
        {
            installCase = 3;
            _imageArray = @[@"share_weibo161",@"share_links161"];
            _nameArray = @[@"新浪微博",@"复制链接"];
        }
    }
    
    NSInteger cycleCount;
    if (self.shareSource == tianTianTuan)
    {
        cycleCount = _imageArray.count - 1;
    }
    else
    {
        cycleCount = _imageArray.count;
    }
    
    for (int i = 0; i < cycleCount; i++)
    {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:[_imageArray pObjectAtIndex:i]] forState:UIControlStateNormal];
        [_shareButton setButtonRoundStyle];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = [_nameArray pObjectAtIndex:i];
        _nameLabel.font = [UIFont fontWithName:FONTNAME size:THEME_FONT_SMALL13];
        _nameLabel.textColor = THEME_COLOR_TEXT;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        float spaceWidth = (kScreenWidth - 3 * 58.0f) / 4.f;
        NSLog(@"%f",kScreenRate);
        if (i < 3)
        {
            _shareButton.frame = CGRectMake((spaceWidth *(i + 1) + 58.0f * i), 25.0f , 58.0f, 58.0f);
            _nameLabel.frame = CGRectMake((spaceWidth *(i + 1) + 58.0f * i), 83.0f, 58.0f, 35.0f);
            
        }
        else
        {
            _shareButton.frame = CGRectMake((spaceWidth * (i - 3 + 1) + 58.0f * (i - 3 )), 118.0f, 58.0f, 58.0f);
            _nameLabel.frame = CGRectMake((spaceWidth * (i - 3 + 1) + 58.0f * (i - 3 )), 176.0f, 58.0f, 35.0f);
        }
        [_shareButton addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.tag = 1001 + i;
        if (installCase == 1)
        {
            if (i == 3)
            {
                _shareButton.tag = 1001 + 5;//即对应到复制链接
            }
        }
        else if (installCase == 2)
        {
            _shareButton.tag = 1001 + i + 2;//即顺移2位
        }
        else if (installCase == 3)
        {
            if (i == 0)
            {
                _shareButton.tag = 1001 + 2;
            }
            else if (i == 1)
            {
                _shareButton.tag = 1001 + 5;
            }
        }
        [self addSubview:_nameLabel];
        [self addSubview:_shareButton];
    }
}


/**
 *	@brief	点击事件，并设置代理
 *
 *	@param 	button 	传tag值
 *
 *	@return	N/A
 */
- (void)doShare:(UIButton *)button
{
    if ([self.shareImage isEqual:[UIImage imageNamed:IMAGE_BREAK_CUBE]] ||
        [self.shareImage isEqual:[UIImage imageNamed:IMAGE_PLACE]] || self.shareImage == nil)
    {
        self.shareImage = [UIImage imageNamed:@"Icon"];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeSuperView)]) {
        [self.delegate removeSuperView];
    }
    NSString *rowStr =[NSString stringWithFormat:@"%d",(int)button.tag % 1000];
    if (button.tag == 1001)
    {
        if (self.shareSource == tianTianTuan)
        {
            [MobClick event:@"click_group_share_friendcircle"];//1.7
        }
        //朋友圈
        [self shareToFriend:rowStr];
    }
    else if (button.tag == 1002)
    {
        if (self.shareSource == tianTianTuan)
        {
            [MobClick event:@"click_group_share_weixin"];//1.7
        }
        //微信好友
        [self shareToWeiXin:rowStr];
    }
    else if (button.tag == 1003)
    {
        if (self.shareSource == tianTianTuan)
        {
            [MobClick event:@"click_group_share_weibo"];//1.7
        }
        //新浪微博
        [self shareToSina:rowStr];
    }
    else if (button.tag == 1004)
    {
        if (self.shareSource == tianTianTuan)
        {
            [MobClick event:@"click_group_share_qqim"];//1.7
        }
        //QQ
        [self shareToQQ:rowStr];
    }
    else if (button.tag == 1005)
    {
        if (self.shareSource == tianTianTuan)
        {
            [MobClick event:@"click_group_share_qqspace"];//1.7
        }
        //QQ空间
        [self shareToQZone:rowStr];
        
    }
    else if (button.tag == 1006)
    {
        if (self.shareSource == gameOneClickSpread)
        {
            [MobClick event:@"langpress_personalgamelink"]; //maidian_1.2.1
        }
        else if (self.shareSource == gameSingleGameSpread)
        {
            [MobClick event:@"langpress_spreadlink"]; //maidian_1.2.1
        }
        else if (self.shareSource == inviteFriend)
        {
            //
        }
        //复制链接
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (self.copiesUrl.length == 0)
        {
            [Utility showToastWithMessage:@"暂无链接，复制失败" inView:superView];
        }
        else
        {
            pasteboard.string = self.copiesUrl;
            [Utility showToastWithMessage:@"复制链接成功" inView:superView];
        }
    }
    
    //    if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
    //    {
    //        NSLog(@"未绑定手机号，游戏推广页面，不进行分享");
    //    }
    //    else
    //    {
    //
    //
    //    }
}

//新浪分享
- (void)shareToSina:(NSString *)str
{
    //    //    [Utility showMBProgress:showView message:@"分享中"];
    //    //微博的链接地址
    //    [UMSocialData defaultData].urlResource.url = self.shareUrl;
    //    [UMSocialData defaultData].extConfig.sinaData.urlResource.url = self.shareUrl;
    //    [UMSocialData defaultData].extConfig.sinaData.urlResource.resourceType = UMSocialUrlResourceTypeImage;
    NSString *contentStr;
    if ([self.shareUrl rangeOfString:@"http://"].location != NSNotFound)
    {
        contentStr = [NSString stringWithFormat:@"%@ %@ %@",shareTitle,shareContent,self.shareUrl];
    }
    else
    {
        contentStr = [NSString stringWithFormat:@"%@ %@ http://%@",shareTitle,shareContent,self.shareUrl];
    }
    
    if (contentStr.length == 0)
    {
        [Utility showToastWithMessage:@"服务器被口水淹没，排水中" inView:self.superView];
        return;
    }
    
    [[UMSocialControllerService defaultControllerService] setShareText:contentStr shareImage:shareImage socialUIDelegate:self];        //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self.presentController,[UMSocialControllerService defaultControllerService],YES);
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
        {
            [self requestSharedResultByWay:@"3"];
        }
        
        [Utility showToastWithMessage:@"分享成功" inView:self.superView];
    }
}

////实现回调方法（可选）：
//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
//{
//    //根据`responseCode`得到发送结果,如果分享成功
//    if(response.responseCode == UMSResponseCodeSuccess)
//    {
//        //得到分享到的微博平台名
////        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
//        [self requestSharedResultByWay:@"3"];
//    }
//}
//微信分享
- (void)shareToWeiXin:(NSString *)str
{
    if (self.shareTitle.length == 0 || self.shareUrl.length == 0 )
    {
        [Utility showToastWithMessage:@"服务器被口水淹没，排水中" inView:self.superView];
        return;
    }
    if (![WXApi isWXAppInstalled]) {
        return;
    }
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.shareUrl;
    [UMSocialData defaultData].extConfig.title = self.shareTitle;
    [UMSocialData defaultData].urlResource.url = self.shareUrl;
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession] content:shareContent image:shareImage location:nil urlResource:nil presentedController:self.presentController completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
            {
                [self requestSharedResultByWay:str];
                [self shareSucceed];
            }
            else
            {
                [Utility showToastWithMessage:@"分享成功" inView:self.presentController.view];
            }
        }
        else
        {
            [Utility showToastWithMessage:@"分享失败" inView:showView];
        }
    }];
}

//朋友圈分享
- (void)shareToFriend:(NSString *)str
{
    if (self.shareTitle.length == 0 || self.shareUrl.length == 0)
    {
        [Utility showToastWithMessage:@"服务器被口水淹没，排水中" inView:self.superView];
        return;
    }
    if (![WXApi isWXAppInstalled]) {
        return;
    }
    //TODO:微信分享内容点击后跳转到链接地址
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.shareUrl;
    [UMSocialData defaultData].extConfig.title = [NSString stringWithFormat:@"%@\n%@",self.shareTitle,shareContent];
    //    [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.shareTitle;
    //    [UMSocialData defaultData].extConfig.wechatTimelineData.extInfo = self.shareContent;
    [UMSocialData defaultData].urlResource.url = self.shareUrl;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:nil image:self.shareImage location:nil urlResource:nil presentedController:self.presentController completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
            {
                [self requestSharedResultByWay:str];
                [self shareSucceed];
                
            }
            else
            {
                [Utility showToastWithMessage:@"分享成功" inView:self.presentController.view];
            }
        }
        else
        {
            [Utility showToastWithMessage:@"分享失败" inView:showView];
        }
    }];
}

//短信分享
- (void)shareToSMS:(NSString *)str
{
    //分享数据，平台设置   UMSocialQzoneData
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSms] content:shareContent image:shareImage location:nil urlResource:nil presentedController:self.presentController completion:^(UMSocialResponseEntity *response)
     {
         if (response.responseCode == UMSResponseCodeSuccess)
         {
             [self requestSharedResultByWay:str];
             [self shareSucceed];
         }
         else
         {
             [Utility showToastWithMessage:@"分享失败" inView:showView];
         }
     }];
    
}

//QQ空间分享
- (void)shareToQZone:(NSString *)str
{
    // 分享qq title content 至少有一个 有值  image 不能为空 url 可以为空 可以为无效链接
    
    if (self.shareTitle.length == 0 || shareUrl.length == 0 || shareContent.length == 0)
    {
        [Utility showToastWithMessage:@"服务器被口水淹没，排水中" inView:self.superView];
        return;
    }
    
    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qzoneData.title = self.shareTitle;
    [UMSocialData defaultData].extConfig.qzoneData.shareText = shareContent;
    [UMSocialData defaultData].extConfig.qzoneData.shareImage = UIImageJPEGRepresentation(shareImage,0.1f);
    //分享数据，平台设置   UMSocialQzoneData
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContent image:nil location:nil urlResource:nil presentedController:self.presentController completion:^(UMSocialResponseEntity *response)
     {
         if (response.responseCode == UMSResponseCodeSuccess)
         {
             if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
             {
                 [self requestSharedResultByWay:str];
                 [self shareSucceed];
                 
             }
             else
             {
                 [Utility showToastWithMessage:@"分享成功" inView:self.presentController.view];
             }
         }
         else
         {
             [Utility showToastWithMessage:@"分享失败" inView:showView];
         }
     }];
}

//QQ分享
- (void)shareToQQ:(NSString *)str
{
    if (shareUrl.length == 0 || self.shareTitle.length == 0 || shareContent == 0)
    {
        [Utility showToastWithMessage:@"服务器被口水淹没，排水中" inView:self.superView];
        return;
    }
    
    [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qqData.title = self.shareTitle;
    [UMSocialData defaultData].extConfig.qqData.shareText = shareContent;
    [UMSocialData defaultData].extConfig.qqData.shareImage = UIImageJPEGRepresentation(shareImage, 0.1f);
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToQQ] content:shareContent image:nil location:nil urlResource:nil presentedController:self.presentController completion:^(UMSocialResponseEntity *response) {
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            if ((self.shareSource == gameOneClickSpread || self.shareSource == gameSingleGameSpread))
            {
                [self requestSharedResultByWay:str];
                [self shareSucceed];
            }
            else
            {
                [Utility showToastWithMessage:@"分享成功" inView:self.presentController.view];
            }
            
        }
        else
        {
            [Utility showToastWithMessage:@"分享失败" inView:showView];
        }
    }];
}


/**
 *	@brief	从分享处返回
 *
 *	@param 	way 	分享方式
 *
 *	@return	N/A
 */
- (void)requestSharedResultByWay:(NSString *)str
{
    /*
     接口名称：推广游戏--点击分享接口
     接口URL：hw-game-app-web/share/saveGameShareInfo.do
     入参：
     popularizeUserId（必填，推广员id），
     shareChannel（必填，分享渠道）例如：朋友圈：1；微信好友：2；新浪微博：3；QQ好友：4；QQ空间：5
     gameId（单个游戏点分享的时候必填）
     */
    [Utility showMBProgress:self message:@"分享中"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setPObject:[HWUserLogin currentUserLogin].userId forKey:@"popularizeUserId"];
    [param setPObject:str forKey:@"shareChannel"];
    [param setPObject:self.gameId forKey:@"gameId"];
    HWHTTPRequestOperationManager *manager = [HWHTTPRequestOperationManager gameManager];
    [manager POST:kGameSpreadShare parameters:param queue:nil success:^(id responese) {
        [Utility hideMBProgress:self];
    } failure:^(NSString *code, NSString *error) {
        [Utility hideMBProgress:self];
        [Utility showToastWithMessage:error inView:self];
    }];
}

/**
 *	@brief	分享成功描述话语
 *
 *	@return	N/A
 */
- (void)shareSucceed
{
    [Utility showAlertWithMessage:@"分享成功。朋友登录游戏之后可按比例获得佣金"];
}
@end
