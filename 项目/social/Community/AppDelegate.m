
//
//  AppDelegate.m
//  Community
//
//  Created by caijingpeng.haowu on 14-8-27.
//  Copyright (c) 2014年 caijingpeng. All rights reserved.
//

#import "AppDelegate.h"
#import "HWHomePageViewController.h"
#import "HWCoreDataManager.h"
#import "SBJson.h"
#import "HWCallDetectCenter.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "APService.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TuiGuangYuanUI.h"
#import "IPDetector.h"
//#import "AlixPayResult.h"
#import "HWPraiseView.h"
#import "HWGuideFactory.h"
#import "HWGameSpreadRecordViewController.h"
#import "HWShareViewController.h"
#import "HWNetWorkManager.h"
#import "HWPersonDynamicViewController.h"
#import "HWWuYePublishNoticeVC.h"
#import "HWMyWuYeMViewController.h"
#import "HWPublicRepairVC.h"
#import "HWServiceListDetailViewController.h"
#import "HWInviteCustomRecordDetailVC.h"
#import "HWPerpotyComplaintVC.h"
#import "HWAuthenticateConfirmViewController.h"
#import "HWTreasureDetailViewController.h"
#import "HWCommondityDetailView.h"
#import <TAESDK/TAESDK.h>
#import "HWTianTianTuanDetailVC.h"

#define PUSHALERT   1001
#define FORCEUPDATE 1002

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize manager;
@synthesize tabBarVC;
@synthesize activeURL;
@synthesize gameBanner;
@synthesize checkUpdateWidget;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@",NSHomeDirectory());
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [MobClick startWithAppkey:UMENG_APP_KEY];
    [self getWANIPAddress];
    [self readSystemConfig];
    _isForceUpdate = @"";
    
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    [APService setupWithOption:launchOptions];
    
    if (!IOS7)
    {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            [self performSelector:@selector(handlePushInfo:) withObject:userInfo afterDelay:1.0f];
        }
    }
    if (IOS8)
    {
        //1.创建消息上面要添加的动作(按钮的形式显示出来)
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = @"action";//按钮的标示
        action.title = @"Accept";//按钮的标题
        action.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        action.authenticationRequired = NO;
        action.destructive = NO;
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        action2.identifier = @"action2";
        action2.title = @"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action.destructive = YES;
        
        //2.创建动作(按钮)的类别集合
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"alert";//这组动作的唯一标示
        [categorys setActions:@[action,action2] forContext:UIUserNotificationActionContextDefault];
        
        //3.创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    }
    self.checkUpdateWidget = [[HWCheckForceUpdateWidget alloc] initWithDependView:self.window];
    //加载用户数据
    [self loadCityData];
    [HWCoreDataManager loadUserInfo];
    [HWCallDetectCenter shareInstance];
    [self limitWebviewCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    //    [self checkNetworkConnection];
    
    [application setApplicationIconBadgeNumber:0];
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert
     | UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:kFirstCheckTouchID])
    {
        [userDefault setObject:@"0" forKey:kFirstCheckTouchID];
    }
    
    // Override point for customization after application launch.
    
    tabBarVC = [[HWTabBarViewController alloc] init];
    // [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_APP_DATA object:nil];
#pragma mark --- ----------tabbar
    HWBaseNavigationController *nav = [[HWBaseNavigationController alloc] initWithRootViewController:tabBarVC];
    
    self.window.rootViewController = nav;
    [self initialUMeng];
    [self initialBaiChuan];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self initRentsValue];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if (![userdefault objectForKey:kFirstLaunch])//首次打开新应用 进引导
    {
        HWHomePageViewController *homePageVC = [[HWHomePageViewController alloc] init];
        HWBaseNavigationController *nav = [[HWBaseNavigationController alloc] initWithRootViewController:homePageVC];
        [self.window.rootViewController presentViewController:nav animated:NO completion:nil];
    }
    else
    {
        if (![Utility isUserLogin] || [HWUserLogin currentUserLogin].villageId.length <= 0)
        {
            HWHomePageViewController *homePageVC = [[HWHomePageViewController alloc] init];
            HWBaseNavigationController *nav = [[HWBaseNavigationController alloc] initWithRootViewController:homePageVC];
            [self.window.rootViewController presentViewController:nav animated:NO completion:nil];
        }
        else
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self getWalletMoney];
        }
    }
    
    [HWUserLogin currentUserLogin].notificationOnOrOff = @"0";//默认应用接收通知关闭的
    [self checkCall];
    [self getPersonInfoRequest];
    
    [HWUserLogin currentUserLogin].locationFailureFlag = YES;
    
    //add by gusheng--添加激活帮助的KEY--9月20发版
    [TuiGuangYuanUI activeTuiGuangYuanWithAppKey:TuiGuangYuan_APP_KEY andAppScrect:TuiGuangYuan_APP_SECRECT];
    
    UIImageView *coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, [UIScreen mainScreen].bounds.size.height)];
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        coverIV.image = [UIImage imageNamed:@"Default"];
    }else{
        coverIV.image = [UIImage imageNamed:@"Default-568h"];
    }
    [self.window addSubview:coverIV];
    [UIView animateWithDuration:0.5 animations:^{
        coverIV.frame = CGRectMake(-20, -20, kScreenWidth + 40, [UIScreen mainScreen].bounds.size.height + 40);
        coverIV.alpha = 0;
    } completion:^(BOOL finished) {
        [coverIV removeFromSuperview];
    }];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:@"draft"];
    
    return YES;
}

#pragma - mark 获取钱包余额
- (void)getWalletMoney
{
    HWUserLogin *user = [HWUserLogin currentUserLogin];
    HWHTTPRequestOperationManager *requestManager = [HWHTTPRequestOperationManager accountManager];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setPObject:user.key forKey:@"key"];
    
    [requestManager POST:kWalletRemainMoney parameters:dict queue:nil success:^(id responseObject) {
        NSDictionary *respDic = (NSDictionary *)[responseObject dictionaryObjectForKey:@"data"];
        [HWUserLogin currentUserLogin].totalMoney = [respDic stringObjectForKey:@"amount"];
        NSString * _walletMoneyStr = [respDic stringObjectForKey:@"amount"];
        if([_walletMoneyStr length]==0)
        {
            _walletMoneyStr = @"0";
            [HWUserLogin currentUserLogin].totalMoney = _walletMoneyStr;
        }
        else
        {
            [HWUserLogin currentUserLogin].totalMoney = _walletMoneyStr;
        }
    } failure:^(NSString *code, NSString *error) {
        [HWUserLogin currentUserLogin].totalMoney = @"0";
    }];
}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

/**
 *  用来检测第一次查看租售房屋
 */
- (void)initRentsValue
{
    NSString *firstRents = @"1";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:firstRents forKey:kFirstRent];
    [defaults synchronize];
}

- (void)initialBaiChuan
{
    [[TaeSDK sharedInstance] setAppVersion:[Utility getLocalAppVersion]];
    [[TaeSDK sharedInstance] setDebugLogOpen:NO];//打开SDK警告提示以及日志输出，方便排查错误，app发布时务必关闭此开关
    //    [[TaeSDK sharedInstance]setCloudPushSDKOpen:YES];//开启阿里云云推送功能，默认不开启
    //    [[TaeSDK sharedInstance] closeCrashHandler];//关闭SDK设置的crashHandler
    
    //sdk初始化
    [[TaeSDK sharedInstance] asyncInit:^{
        NSLog(@"初始化成功");
    } failedCallback:^(NSError *error) {
        NSLog(@"初始化失败:%@",error);
    }];
    
}

- (void)initialUMeng
{
    // ********   友盟   *********
    [UMSocialData setAppKey:UMENG_APP_KEY];
    [UMSocialWechatHandler setWXAppId:WECHAT_KEY appSecret:WECHAT_SECRET url:@"http://www.umeng.com/social"];
    //打开新浪微博的SSO开关
    
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:QZONE_APPID appKey:QZONE_APPKEY url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setSupportWebView:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //百川回跳
    //该URL是否已经被TAE处理过
    BOOL wasHandled=[[TaeSDK sharedInstance] handleOpenURL:url];
    //开发者继续自己处理
    
    //--------------------------------------------------
    
    
    //    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@", resultDic);         //返回的支付结果
        NSString *resultStatus = [resultDic stringObjectForKey:@"resultStatus"];
        if ([resultStatus isEqualToString:@"9000"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PaySuccess" object:nil];
            //            if (_paySuccessReturn)
            //            {
            //                _paySuccessReturn();
            //            }
        }
        else
        {
            //            [Utility showToastWithMessage:@"支付失败" inView:self];
        }
    }];
    //    [self parse:url application:application];           //支付宝回调1.2.0
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken: %@",[NSString stringWithFormat:@"%@", deviceToken]);
    [HWUserLogin currentUserLogin].notificationOnOrOff = @"1";
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)handlePushInfo:(NSDictionary *)userInfo
{
    //推送类型：主题            0
    //推送类型：主题回复         4
    //推送类型：点赞            40
    //推送类型：店铺通过         1
    //推送类型：店铺认证         2
    //推送类型：福利活动         3
    //推送类型：物业上门         5
    //推送类型：物业租售         6
    //推送类型：物业建议留言      7
    //推送类型：小区主题         8
    //推送类型：游戏推广 推广记录         50
    //推送类型：物业发布公告       778
    //推送类型：物业推送消息       777
    //推送类型：报修被服务人员接单    60
    //推送类型：报修处理完成       61
    //推送类型：报修被关闭    76
    //推送类型：上门服务被物业服务人员接单      64
    //推送类型：上门服务被服务人员完成，线上付款/线下付款    62
    //推送类型：访客当天内首次通过验证  63
    //推送类型：投诉/二次投诉开始处理  75
    //推送类型：投诉/二次投诉处理完成  77
    //推送类型：邮寄认证时，明信片发出 65
    //推送类型：无底线奖品寄出      本版本暂时不做（1.6.0）
    //推送类型：天天团后台标记发货  70
    //推送类型：天天团后台完成退款  71
    
    if (![Utility isUserLogin])
    {
        return;
    }
    
    NSString *type = [userInfo stringObjectForKey:@"type"];
    
    if (![self.window.rootViewController isKindOfClass:[HWBaseNavigationController class]])
    {
        return;
    }
    
    
    HWBaseNavigationController *nav = (HWBaseNavigationController *)self.window.rootViewController;
    
    if ([type isEqualToString:@"0"] ||
        [type isEqualToString:@"4"] ||
        [type isEqualToString:@"40"])    //新主题或回复或点赞
    {
        HWPersonDynamicViewController *personCenterView = [[HWPersonDynamicViewController alloc]init];
        [nav pushViewController:personCenterView animated:YES];
    }
    else if ([type isEqualToString:@"1"] ||
             [type isEqualToString:@"2"] ||
             [type isEqualToString:@"5"] ||
             [type isEqualToString:@"6"] ||
             [type isEqualToString:@"7"] ||
             [type isEqualToString:@"8"])//1、2店铺申请，5、6、7物业相关，8小区活动
    {
        [nav popToRootViewControllerAnimated:YES];
        self.tabBarVC.selectedIndex = 1;
        
        [self.tabBarVC.neighbourVC refreshList];
    }
    else if ([type isEqualToString:@"3"])//红包
    {
        HWShareViewController *shareVC = [[HWShareViewController alloc] init];
        [nav pushViewController:shareVC animated:YES];
    }
    else if ([type isEqualToString:@"50"])//游戏推广记录页
    {
        HWGameSpreadRecordViewController *gameSpreadRecordVC = [[HWGameSpreadRecordViewController alloc]init];
        [nav pushViewController:gameSpreadRecordVC animated:YES];
    }
    else if ([type isEqualToString:@"777"])//物业推送消息
    {
        HWMyWuYeMViewController *wuYeMessageVC = [[HWMyWuYeMViewController alloc] init];
        [nav pushViewController:wuYeMessageVC animated:YES];
    }
    else if ([type isEqualToString:@"778"])//物业发布公告
    {
        HWWuYePublishNoticeVC *publishNoticeVC = [[HWWuYePublishNoticeVC alloc] init];
        [nav pushViewController:publishNoticeVC animated:YES];
    }
    else if ([type isEqualToString:@"60"] || [type isEqualToString:@"61"] || [type isEqualToString:@"76"])
    {
        HWPublicRepairVC *repairVC = [[HWPublicRepairVC alloc] init];
        [nav pushViewController:repairVC animated:YES];
    }
    else if ([type isEqualToString:@"64"] || [type isEqualToString:@"62"])
    {
        HWServiceListDetailViewController *detailVC = [[HWServiceListDetailViewController alloc] init];
        NSString *orderId = [userInfo stringObjectForKey:@"workOrderId"];
        detailVC.orderID = orderId;
        detailVC.pushType = pushHomeServiceDetailTypeList;
        [nav pushViewController:detailVC animated:YES];
    }
    else if ([type isEqualToString:@"63"])
    {
        HWInviteCustomRecordDetailVC *detailVC = [[HWInviteCustomRecordDetailVC alloc] init];
        NSString *dataStr = [userInfo stringObjectForKey:@"data"];
        NSDictionary *dataDic=[dataStr JSONValue];
        HWInviteCustomRecordModel *model = [[HWInviteCustomRecordModel alloc] init];
        model.visitorMobile = [dataDic stringObjectForKey:@"visitorMobile"];
        model.villageName = [dataDic stringObjectForKey:@"villageName"];
        model.visitorDate = [dataDic stringObjectForKey:@"visitorDate"];
        model.dateCount = [dataDic stringObjectForKey:@"dateCount"];
        model.zxing = [dataDic stringObjectForKey:@"zxing"];
        model.visitorName = [dataDic stringObjectForKey:@"visitorName"];
        model.relationship = [dataDic stringObjectForKey:@"relationship"];
        model.isVisit = [dataDic stringObjectForKey:@"isVisit"];
        model.isPast = [dataDic stringObjectForKey:@"isPast"];
        model.isValid = [dataDic stringObjectForKey:@"isValid"];
        model.tvId = [dataDic stringObjectForKey:@"tvId"];
        model.buttonStatus = [dataDic stringObjectForKey:@"buttonStatus"];
        model.SixConunt = [dataDic stringObjectForKey:@"SixConunt"];
        model.visitorCount = [dataDic stringObjectForKey:@"visitorCount"];
        detailVC.model = model;
        [nav pushViewController:detailVC animated:YES];
    }
    else if ([type isEqualToString:@"75"] || [type isEqualToString:@"77"])
    {
        HWPerpotyComplaintVC *complainVC = [[HWPerpotyComplaintVC alloc] init];
        [nav pushViewController:complainVC animated:YES];
    }
    else if ([type isEqualToString:@"65"])
    {
        HWAuthenticateConfirmViewController *vc = [[HWAuthenticateConfirmViewController alloc] init];
        NSString *applyId = [userInfo stringObjectForKey:@"applyId"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:applyId forKey:kAuthApplyId];
        [nav pushViewController:vc animated:YES];
    }
    else if ([type isEqualToString:@"70"] || [type isEqualToString:@"71"])
    {
        HWTianTianTuanDetailVC *detailVC = [[HWTianTianTuanDetailVC alloc] init];
        detailVC.orderId = [userInfo stringObjectForKey:@"orderId"];
        [nav pushViewController:detailVC animated:YES];
    }
    //    else if ([type isEqualToString:@"66"])
    //    {
    //        HWTreasureDetailViewController *detailVC = [[HWTreasureDetailViewController alloc] init];
    ////        detailVC.wuDiXianChannelId = [userInfo stringObjectForKey:@"productId"];
    ////        detailVC.productId = [userInfo stringObjectForKey:@"productId"];
    //        [nav pushViewController:detailVC animated:YES];
    //    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Required
    [APService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@", userInfo);
    
    NSString *msg = [[userInfo objectForKey:@"aps"] stringObjectForKey:@"alert"];
    if ([Utility isUserLogin])
    {
        NSString *shopId = [userInfo stringObjectForKey:@"shopId"];
        //        [Utility showAlertWithMessage:[NSString stringWithFormat:@"%@",shopId]];
        if (shopId.length != 0)
        {
            [HWUserLogin currentUserLogin].shopId = shopId;
            [HWCoreDataManager saveUserInfo];
        }
        
        if (/*application.applicationState == UIApplicationStateActive ||*/
            application.applicationState == UIApplicationStateBackground)
        {
            pushInfo = userInfo;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
            alert.tag = PUSHALERT;
            [alert show];
        }
        else if (application.applicationState == UIApplicationStateActive)
        {
            
            if (![Utility isUserLogin])
            {
                return;
            }
            
            NSString *type = [userInfo stringObjectForKey:@"type"];
            if ([type isEqualToString:@"0"] ||
                [type isEqualToString:@"4"] ||
                [type isEqualToString:@"40"])
            {
                [self.tabBarVC showTabbarMineDot];
            }
            else if ([type isEqualToString:@"1"] ||
                     [type isEqualToString:@"2"] ||
                     [type isEqualToString:@"5"] ||
                     [type isEqualToString:@"6"] ||
                     [type isEqualToString:@"7"] ||
                     [type isEqualToString:@"8"])
            {
                [self.tabBarVC showTabbarNeighbourDot];
            }
            else
            {
                pushInfo = userInfo;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
                alert.tag = PUSHALERT;
                [alert show];
            }
            
        }
        else if (application.applicationState == UIApplicationStateInactive)
        {
            [self handlePushInfo:userInfo];
        }
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSString *msg = [[userInfo objectForKey:@"aps"] stringObjectForKey:@"alert"];
    if ([Utility isUserLogin])
    {
        NSString *shopId = [userInfo stringObjectForKey:@"shopId"];
        //        [Utility showAlertWithMessage:[NSString stringWithFormat:@"%@",shopId]];
        if (shopId.length != 0)
        {
            [HWUserLogin currentUserLogin].shopId = shopId;
            [HWCoreDataManager saveUserInfo];
        }
        
        if (application.applicationState == UIApplicationStateBackground)
        {
            pushInfo = userInfo;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
            alert.tag = PUSHALERT;
            [alert show];
        }
        else if (application.applicationState == UIApplicationStateActive)
        {
            if (![Utility isUserLogin])
            {
                return;
            }
            
            NSString *type = [userInfo stringObjectForKey:@"type"];
            if ([type isEqualToString:@"4"])
            {
                [self.tabBarVC showTabbarMineDot];
            }
            else if ([type isEqualToString:@"0"] ||
                     [type isEqualToString:@"1"] ||
                     [type isEqualToString:@"2"] ||
                     [type isEqualToString:@"3"] ||
                     [type isEqualToString:@"5"] ||
                     [type isEqualToString:@"6"] ||
                     [type isEqualToString:@"7"] ||
                     [type isEqualToString:@"8"] ||
                     [type isEqualToString:@"-1"] ||
                     [type isEqualToString:@"-2"])
            {
                [self.tabBarVC showTabbarNeighbourDot];
            }
            else if ([type isEqualToString:@"40"] ||
                     [type isEqualToString:@"50"])
            {
                pushInfo = userInfo;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
                alert.tag = PUSHALERT;
                [alert show];
            }
        }
        else if (application.applicationState == UIApplicationStateInactive)
        {
            //            [self handlePushInfo:userInfo]; iOS8
            [self performSelector:@selector(handlePushInfo:) withObject:userInfo afterDelay:1.0f];
        }
    }
    
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    //在没有启动本App时，收到服务器推送消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮
    
    NSLog(@"%@ %@",identifier,userInfo);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //    UIUserNotificationSettings *settings = [application currentUserNotificationSettings];
    //    UIUserNotificationType types = [settings types];
    //    //只有5跟7的时候包含了 UIUserNotificationTypeBadge
    //    if (types == 5 || types == 7) {
    //        application.applicationIconBadgeNumber = 0;
    //    }
    //注册远程通知
    [application registerForRemoteNotifications];
}

#endif

#pragma - mark  本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [APService showLocalNotificationAtFront:notification identifierKey:nil];
    
    NSDictionary *dict = [notification userInfo];
    NSString *productId = [dict stringObjectForKey:@"goodsId"];
    
    [[HWUserLogin currentUserLogin] removeAlertItemById:productId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HWAlertItemNotification object:nil];
    
    [Utility removeAlertItemWithProductId:productId];
    
    
    //    UIApplication * app = [UIApplication sharedApplication];
    //    NSArray *localArr = [app scheduledLocalNotifications];
    //    UILocalNotification *localNoti;
    //    if (localArr) {
    //        for (localNoti in localArr) {
    //            NSDictionary * dict = localNoti.userInfo;
    //            if (dict)
    //            {
    //                NSString * inKey = [dict objectForKey:@"key"];
    //
    //                if ([inKey isEqualToString:@"商品1"])
    //                {
    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接收到本地提醒 in app"
    //                                                                    message:notification.alertBody
    //                                                                   delegate:nil
    //                                                          cancelButtonTitle:@"确定"
    //                                                          otherButtonTitles:nil];
    //                    [alert show];
    //                    [app cancelLocalNotification:notification];
    //                }
    //            }
    //        }
    //    }
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkCall];
    [APService resetBadge];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    
    if (self.checkUpdateWidget != nil)
    {
        [self.checkUpdateWidget checkForceUpdateVersion];
    }
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self checkCall];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
- (void)paymentResult:(NSString *)resultd
{
    
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)limitWebviewCache
{
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
}

#pragma mark -
#pragma mark Advertise
- (void)getWANIPAddress
{
    [IPDetector getWANIPAddressWithCompletion:^(NSString *IPAddress){
        [self activeAdvertise:IPAddress];
    }];
}

- (void)activeAdvertise:(NSString *)ipAddress
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"advertise"])
    {
        NSArray *arr = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
        NSString *osV = @"7";
        if (arr.count > 0)
        {
            osV = [arr pObjectAtIndex:0];
        }
        HWHTTPRequestOperationManager *managerTemp = [HWHTTPRequestOperationManager adManager];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setPObject:APPLEID forKey:@"appId"];
        [dict setPObject:[[Utility getMacAddress] uppercaseString] forKey:@"mac"];
        [dict setPObject:[Utility getIDFA] forKey:@"ifa"];
        [dict setPObject:ipAddress forKey:@"ip"];
        [dict setPObject:[Utility getLocalAppVersion] forKey:@"appVersion"];
        [dict setPObject:osV forKey:@"osVersion"];
        
        [managerTemp POST:kActiveAdvertise parameters:dict queue:nil success:^(id responseObject){
            
            NSLog(@"%@",responseObject);
            
            //            NSString *msg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"detail"]];
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"激活" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //            [alert show];
            
            NSDictionary *dic = [responseObject dictionaryObjectForKey:@"data"];
            self.activeURL = [dic stringObjectForKey:@"url"];
            //            NSString *source = [dic numberObjectForKey:@"source"];
            [self sendActiveSuccess:self.activeURL];
            
        } failure:^(NSString *code, NSString *error) {
            
            NSLog(@"%@",error);
            if ([error isEqualToString:@"设备信息不存在"])
            {
                [userDefault setObject:@"1" forKey:@"advertise"];
            }
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"激活" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //            [alert show];
        }];
    }
}
- (void)sendActiveSuccess:(NSString *)url
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    HWHTTPRequestOperationManager *managerTemp = [HWHTTPRequestOperationManager manager];
    [managerTemp advertizeGET:url success:^(id responseObject) {
        
        //        NSString *msg = [NSString stringWithFormat:@"%@",responseObject];
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"多盟" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert show];
        [userDefault setObject:@"1" forKey:@"advertise"];
        
        if ([responseObject objectForKey:@"success"])
        {
            [userDefault setObject:@"1" forKey:@"advertise"];
            
        }
        
    } failure:^(NSString *error) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"多盟" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alert show];
    }];
}

#pragma mark -
#pragma mark Check Call

- (void)checkCall
{
    [[NSNotificationCenter defaultCenter]postNotificationName:HWNeighbourDragRefresh object:nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:kHaveDialing] isEqualToString:@"1"])
    {
        // 接通电话后 提示有新消息
        HWCallPhoneAlert *tipAlert = [[HWCallPhoneAlert alloc]initWithMessage:@" 你收到了一条新消息" closeEnable:NO];
        [tipAlert setHideAlert:^()
         {
             
         }];
        [tipAlert show];
        [self.window addSubview:tipAlert];
        
        [userDefault setObject:@"0" forKey:kHaveDialing];
    }
}

#pragma mark -
#pragma mark Prepare Data

- (void)loadCityData
{
    [self getCityNewestList];
}
//更新用户个人信息
//发送获取未读消息的请求
-(void)getPersonInfoRequest
{
    HWHTTPRequestOperationManager *managerTemp = [HWHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setPObject:[HWUserLogin currentUserLogin].key forKey:@"key"];
    [dict setPObject:[HWUserLogin currentUserLogin].telephoneNum forKey:@"mobileNumber"];
    [managerTemp POST:kPersonInfo parameters:dict queue:nil success:^(id responseObject){
        NSDictionary *dataDic = [responseObject objectForKey:@"data"];
        //用户数据保存本地
        [[HWUserLogin currentUserLogin]initUserLogin:dataDic];
        [HWCoreDataManager saveUserInfo]; // 保存数据库
        
    } failure:^(NSString *code, NSString *error) {
        NSLog(@"error");
    }];
}
//获取城市列表
////获取城市列表
-(void)getCityNewestList
{
    //    NSString *dataVersion = @"";
    //获取所在城市的区域
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"city.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSMutableArray *fileDataArry = [NSMutableArray arrayWithContentsOfFile:filePath];
        [self handleDataWithArry:fileDataArry];
        
    }
    else
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"txt"];
        NSMutableArray *fileDataArry = [NSMutableArray arrayWithContentsOfFile:path];
        [self handleDataWithArry:fileDataArry];
    }
    NSLog(@"%@",filePath);
    HWHTTPRequestOperationManager *managerTemp = [HWHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *dataVersionStr  =  [HWUserLogin currentUserLogin].dataVersion;
    if (!dataVersionStr) {
        [dict setPObject:@"1" forKey:@"dateVersion"];
    }
    else
    {
        [dict setPObject:dataVersionStr forKey:@"dateVersion"];
    }
    [HWUserLogin currentUserLogin].dataVersion = dataVersionStr;
    [dict setPObject:[HWUserLogin currentUserLogin].key forKey:@"key"];
    [managerTemp POST:kGetCityList parameters:dict queue:nil success:^(id responseObject){
        NSDictionary *dataDic = (NSDictionary*)[responseObject objectForKey:@"data"];     NSMutableArray *allCitys = [dataDic objectForKey:@"cityList"];
        [self handleDataWithArry:allCitys];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *savedPath=[documentsDirectory stringByAppendingPathComponent:@"city.txt"];
        [allCitys writeToFile:savedPath atomically:YES];
        [HWUserLogin currentUserLogin].dataVersion = [dataDic stringObjectForKey:@"dataVersion"];
        [HWCoreDataManager saveUserInfo];
        [self startLocating];
    } failure:^(NSString *code, NSString *error) {
        NSLog(@"error");
        [self startLocating];
    }];
}

- (void)readSystemConfig
{
    self.gameBanner = @"1"; // 默认 显示
    HWHTTPRequestOperationManager *httpManager = [HWHTTPRequestOperationManager manager];
    [httpManager POST:kReadConfig parameters:nil queue:nil success:^(id responese) {
        
        NSLog(@"%@",responese);
        
        NSString *gameBanner = [[responese dictionaryObjectForKey:@"data"] stringObjectForKey:@"game_banner"];
        self.gameBanner = gameBanner;
        
    } failure:^(NSString *code, NSString *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - Locate
- (void)startLocating {
    
    //    //nslog(@"%d",[CLLocationManager authorizationStatus]);
    
    if([CLLocationManager locationServicesEnabled]) {
        self.manager = [[CLLocationManager alloc] init];
        if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.manager requestWhenInUseAuthorization];
        }
        //设置定位的精度
        [self.manager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        self.manager.delegate = self;
        if (IOS8)
        {
            //            [self.manager requestAlwaysAuthorization];
            [self.manager requestWhenInUseAuthorization];
        }
        
        //开始实时定位
        [self.manager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    [HWUserLogin currentUserLogin].longitude = coordinate.longitude;
    [HWUserLogin currentUserLogin].latitude = coordinate.latitude;
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       
                       if (error)
                       {
                           
                           NSLog(@"location is error");
                       }
                       for (CLPlacemark *place in placemarks)
                       {
                           NSString *city = place.locality;
                           //            if (city == nil)
                           //            {
                           city = [place.addressDictionary objectForKey:@"State"];
                           // }
                           //保存本地
                           [HWUserLogin currentUserLogin].saveFrontGpsCityIdStr = [Utility getCityId:city];
                           //[HWUserLogin currentUserLogin].cityName = city;
                           [HWUserLogin currentUserLogin].gpsCityName = city;
                           [HWUserLogin currentUserLogin].gpsCityId = [Utility getCityId:city];
                           [HWCoreDataManager saveUserInfo];
                           //NSLog(@"当前城市ID是%@,区域id是%@",cityId,areaId);
                       }
                   }];
    [self.manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [HWUserLogin currentUserLogin].longitude = 0.0;
    [HWUserLogin currentUserLogin].latitude = 0.0;
    //[HWUserLogin currentUserLogin].cityName = @"切换城市";
    [HWUserLogin currentUserLogin].gpsCityName = @"切换城市";
    [HWUserLogin currentUserLogin].gpsCityId = nil;
    [HWCoreDataManager saveUserInfo];
}

- (void)handleDataWithArry:(NSMutableArray *)dataArry
{
    NSMutableArray *allCity = [NSMutableArray array];
    NSMutableArray *hotCity = [NSMutableArray array];
    for (int j = 0; j < dataArry.count; j++)
    {
        NSDictionary *cityDic = [dataArry pObjectAtIndex:j];
        HWCityClass *cityClass = [[HWCityClass alloc] initWithDictionary:cityDic];
        [allCity addObject:cityClass];
        
        if ([cityClass.hotStr isEqualToString:@"1"]) {
            [hotCity addObject:cityClass];
        }
    }
    [HWUserLogin currentUserLogin].cities = allCity;
    [HWUserLogin currentUserLogin].hotArry = hotCity;
}

#pragma mark -
#pragma mark Network

///**
// *	@brief	检查网络连接
// *
// *	@return
// */
//- (void)checkNetworkConnection
//{
//    self.reachabiltiy = [Reachability reachabilityWithHostName:@"www.haowu.com"];
//    [self.reachabiltiy startNotifier];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChangedNotify:) name:kReachabilityChangedNotification object:nil];
//}
//
///**
// *	@brief	网络变化 回调函数
// *
// *	@param 	notify 	通知
// *
// *	@return
// */
//- (void)networkChangedNotify:(NSNotification *)notify
//{
//    [[HWNetWorkManager currentManager] postSavedZan];   //上传本地保存的赞
//
//    Reachability *curReach = [notify object];
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//    NetworkStatus networkStatus = [curReach currentReachabilityStatus];
//    switch (networkStatus)
//    {
//        case NotReachable:
//        {
//            [Utility showToastWithMessage:@"网络打瞌睡了，稍后再试" inView:self.window];
//            break;
//        }
//        case ReachableViaWiFi:
//        {
//
//            break;
//        }
//        case ReachableViaWWAN:
//        {
//
//            break;
//        }
//        default:
//            break;
//    }
//}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CURUPDATE_TAG)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ITUNSE_DOWNLOAD_URL]];
        }
    }
    else if (alertView.tag == PUSHALERT)
    {
        if (buttonIndex == 1)
        {
            if (pushInfo != nil)
            {
                [self handlePushInfo:pushInfo];
            }
        }
    }
    else if (alertView.tag == FORCEUPDATE)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ITUNSE_DOWNLOAD_URL]];
    }
}

#pragma mark -
#pragma mark Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Community" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Community.sqlite"];
    
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

- (void)networkDidSetup:(NSNotification *)notification {
    [_infoLabel setText:@"已连接"];
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    [_infoLabel setText:@"未连接。。。"];
    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    [_infoLabel setText:@"已注册"];
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    [_infoLabel setText:@"已登录"];
    NSLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    [_infoLabel setText:[NSString stringWithFormat:@"收到消息\ndate:%@\ntitle:%@\ncontent:%@", [dateFormatter stringFromDate:[NSDate date]],title,content]];
    
}

@end
