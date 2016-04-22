//
//  HWTabBarViewController.m
//  Community
//
//  Created by caijingpeng.haowu on 14-8-28.
//  Copyright (c) 2014年 caijingpeng. All rights reserved.
//
//  功能描述：TabbarController
//
//  修改记录：
//      姓名         日期               修改内容
//     蔡景鹏     2015-01-15           修改回原来 底部四个按钮的形式
//
//

#import "HWTabBarViewController.h"
#import "HWPersonInfoViewController.h"
#import "HWPublishViewController.h"
#import "HWTopicListViewController.h"
#import "AppDelegate.h"
#import "HWCustomGuideAlertView.h"
@interface HWTabBarViewController ()
{
    UIView *neighDotView;
    UIView *mineDotView;
    UIImageView *gView;
    
    UIViewController *currentVC;
}
@end

@implementation HWTabBarViewController
@synthesize serviceVC;
@synthesize shareVC;
@synthesize neighbourVC;
@synthesize personVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 - (id)init
 {
 serviceVC = [[HWServiceViewController alloc] init];
 shareVC = [[HWFuLiSheViewController alloc] init];
 neighbourVC = [[HWNeighbourViewController alloc] init];
 personVC = [[HWPersonInfoViewController alloc] init];
 
 
 NSArray *ctrlArr = [NSArray arrayWithObjects:serviceVC, neighbourVC, shareVC, personVC, nil];
 
 NSArray *imgArr = [NSArray arrayWithObjects:
 @{@"Default" : [UIImage imageNamed:@"tab_new_01"],
 @"Highlighted" : [UIImage imageNamed:@"tab_new_01"],
 @"Seleted" : [UIImage imageNamed:@"tab_new_01_hl"]},
 @{@"Default" : [UIImage imageNamed:@"tab_new_02"],
 @"Highlighted" : [UIImage imageNamed:@"tab_new_02"],
 @"Seleted" : [UIImage imageNamed:@"tab_new_02_hl"]},
 @{@"Default" : [UIImage imageNamed:@"add_icon_01"],
 @"Highlighted" : [UIImage imageNamed:@"add_icon_hl"],
 @"Seleted" : [UIImage imageNamed:@"add_icon_hl"]},
 @{@"Default" : [UIImage imageNamed:@"tab_new_03"],
 @"Highlighted" : [UIImage imageNamed:@"tab_new_03"],
 @"Seleted" : [UIImage imageNamed:@"tab_new_03_hl"]},
 @{@"Default" : [UIImage imageNamed:@"tab_new_04"],
 @"Highlighted" : [UIImage imageNamed:@"tab_new_04"],
 @"Seleted" : [UIImage imageNamed:@"tab_new_04_hl"]}, nil];
 
 NSArray *titleArr = [NSArray arrayWithObjects:
 @"懒生活",
 @"邻里圈",
 @"福利社",
 @"我", nil];
 
 self = [super initWithViewControllers:ctrlArr imageArray:imgArr titleArray:titleArr withFrame:CGRectMake(0, 0, kScreenWidth, CONTENT_HEIGHT) titleTintColor:THEME_COLOR_ORANGE];
 if (self)
 {
 self.delegate = self;
 }
 return self;
 }
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUND_COLOR;
    currentVC = nil;
    
    serviceVC = [[HWServiceViewController alloc] init];
    serviceVC.tabBarItem.image = [UIImage imageNamed:@"lanshenghuo"];
    serviceVC.tabBarItem.selectedImage = [UIImage imageNamed:@"lanshenghuo_hi"];
    serviceVC.title = @"懒生活";
    [serviceVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_ORANGE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateHighlighted];
    [serviceVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_GRAY_MIDDLE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateNormal];
    
    
    shareVC = [[HWFuLiSheViewController alloc] init];
    shareVC.tabBarItem.image = [UIImage imageNamed:@"fulishe"];
    shareVC.tabBarItem.selectedImage = [UIImage imageNamed:@"fulishe_hi"];
    shareVC.title = @"福利社";
    [shareVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_ORANGE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateHighlighted];
    [shareVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_GRAY_MIDDLE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateNormal];
    
    
    neighbourVC = [[HWNeighbourViewController alloc] init];
    neighbourVC.tabBarItem.image = [UIImage imageNamed:@"linliquan"];
    neighbourVC.tabBarItem.selectedImage = [UIImage imageNamed:@"linliquan_hi"];
    neighbourVC.title = @"邻里圈";
    neighbourVC.segmentSelectIndex = 0;
    [neighbourVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_ORANGE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateHighlighted];
    [neighbourVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_GRAY_MIDDLE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateNormal];
    
    
    personVC = [[HWPersonInfoViewController alloc] init];
    personVC.tabBarItem.image = [UIImage imageNamed:@"wo"];
    personVC.tabBarItem.selectedImage = [UIImage imageNamed:@"wo_hi"];
    personVC.title = @"我";
    [personVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_ORANGE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateHighlighted];
    [personVC.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : THEME_COLOR_GRAY_MIDDLE,UITextAttributeFont : [UIFont fontWithName:FONTNAME size:10] }  forState:UIControlStateNormal];
    
    if (IOS7)
    {
        self.tabBar.tintColor = THEME_COLOR_ORANGE;
    }
    else
    {
        self.tabBar.tintColor = [UIColor whiteColor];
    }
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    super.delegate = self;
    self.viewControllers = [NSArray arrayWithObjects:serviceVC, neighbourVC, shareVC, personVC, nil];
    self.selectedIndex = 0;
    [serviceVC viewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (self.navigationItem.rightBarButtonItem != nil)
    {
        [self startAnimateWithView:self.navigationItem.rightBarButtonItem.customView];
    }
    
    if ([[HWUserLogin currentUserLogin].coStatus isEqualToString:@"0"])
    {
        [self.serviceVC checkRefresh];
    }
}

#pragma mark -
#pragma mark            Public  Method

/**
 *	@brief	加小红点
 *
 *	@return
 */
- (void)showTabbarNeighbourDot
{
    float width = self.view.frame.size.width / 4;
    float x = 0;
    if (width > 80)
    {
        x = width * 2 - 35;
    }
    else
    {
        x = width * 2 - 25;
    }
    
    [self hiddenTabbarNeighourDot];
    neighDotView = [[UIView alloc] initWithFrame:CGRectMake(x, 7, 7, 7)];
    neighDotView.layer.cornerRadius = 4;
    neighDotView.layer.masksToBounds = YES;
    [neighDotView setBackgroundColor:THEME_COLOR_ORANGE];
    [self.tabBar addSubview:neighDotView];
}

/**
 *	@brief	隐藏小红点
 *
 *	@return
 */
- (void)hiddenTabbarNeighourDot
{
    if (neighDotView)
    {
        [neighDotView removeFromSuperview];
    }
}

/**
 *	@brief	显示 “我” 按钮上的小红点
 *
 *	@return
 */
- (void)showTabbarMineDot
{
    float width = self.view.frame.size.width / 4;
    float x = 0;
    if (width > 80)
    {
        x = width * 4 - 35;
    }
    else
    {
        x = width * 4 - 25;
    }
    
    [self hiddenTabbarMineDot];
    mineDotView = [[UIView alloc] initWithFrame:CGRectMake(x, 7, 7, 7)];
    mineDotView.layer.cornerRadius = 4;
    mineDotView.layer.masksToBounds = YES;
    [mineDotView setBackgroundColor:THEME_COLOR_ORANGE];
    [self.tabBar addSubview:mineDotView];
}

/**
 *	@brief	隐藏 “我” 按钮上的红点
 *
 *	@return
 */
- (void)hiddenTabbarMineDot
{
    if (mineDotView)
    {
        [mineDotView removeFromSuperview];
    }
}


/**
 *	@brief	选择切换按钮
 *
 *	@param 	selectedIndex 	切换索引
 *
 *	@return
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self tabBarController:self didSelectViewController:[self.viewControllers objectAtIndex:selectedIndex]];
}

#pragma mark -
#pragma mark        Private Method

- (void)toPublish:(id)sender
{
    [MobClick event:@"click_announce"];
    if ([[HWUserLogin currentUserLogin].coStatus isEqualToString:@"0"])
    {
        if ([HWUserLogin verifyBindMobileWithPopVC:self showAlert:YES])
        {
            HWPublishViewController *publishVC = [[HWPublishViewController alloc] init];
            publishVC.publishRoute = NeighbourRoute;
            publishVC.isNeedAudio = NO;
            publishVC.isWriteAndPic = YES;
            
            if ([HWUserLogin verifyIsLoginWithPresentVC:self toViewController:nil])
            {
                if ([HWUserLogin verifyIsAuthenticationWithPopVC:self showAlert:YES])
                {
                    [self.navigationController pushViewController:publishVC animated:YES];
                }
            }
        }
    }
    else
    {
        if ([HWUserLogin verifyBindMobileWithPopVC:self showAlert:YES])
        {
            HWPublishViewController *publishVC = [[HWPublishViewController alloc] init];
            publishVC.publishRoute = NeighbourRoute;
            publishVC.isNeedAudio = NO;
            publishVC.isWriteAndPic = YES;
            if ([HWUserLogin verifyIsLoginWithPresentVC:self toViewController:publishVC])
            {
                [self.navigationController pushViewController:publishVC animated:YES];
            }
        }
    }
}

/**
 *	@brief	邻里圈发布按钮  缩放动画
 *
 *	@param 	targetView 	目标view
 *
 *	@return
 */
- (void)startAnimateWithView:(UIView *)targetView
{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if (![userdefault objectForKey:@"buttonAnimate"])
    {
        [userdefault setObject:@"1" forKey:@"buttonAnimate"];
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnim.fromValue = [NSNumber numberWithFloat:1.0f];
        scaleAnim.toValue = [NSNumber numberWithFloat:1.2f];
        scaleAnim.duration = 1.0f;
        scaleAnim.autoreverses = YES;
        scaleAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnim.repeatCount = CGFLOAT_MAX;
        [targetView.layer addAnimation:scaleAnim forKey:@"scale"];
    }
    else
    {
        [targetView.layer removeAllAnimations];
    }
    
    
}

- (UIBarButtonItem *)navButton:(id)_target image:(NSString *)imgName action:(SEL)selector
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [btn addTarget:_target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
}


#pragma mark -
#pragma mark        UITabBarController Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    currentVC = viewController;
    
    if (viewController == neighbourVC)
    {
        [MobClick event:@"click_neighborhoodcircle"];
        [self hiddenTabbarNeighourDot];
        
        HWCustomSegmentControl *segmentControl = [[HWCustomSegmentControl alloc]initWithTitles:[NSArray arrayWithObjects:@"推荐",@"足迹", nil] fram: CGRectMake(0, 0, kScreenWidth - 150, 30)];
        segmentControl.selectedIndex = neighbourVC.segmentSelectIndex;
        segmentControl.delegate = neighbourVC;
        self.navigationItem.titleView = segmentControl;
        
        self.navigationItem.rightBarButtonItem = [Utility navPublishButton:self action:@selector(toPublish:)];
        
        [self startAnimateWithView:self.navigationItem.rightBarButtonItem.customView];
        self.navigationItem.leftBarButtonItem = nil;
        [MobClick event:@"click_pingdaotab"];
    }
    else if (viewController == shareVC)
    {
        [MobClick event:@"click_kickbacks"];
        
        self.navigationItem.titleView = [Utility navTitleView:@"福利社"];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (viewController == serviceVC)
    {
        [MobClick event:@"click_micro_shop"];
        
        self.navigationItem.titleView = [Utility navTitleView:[HWUserLogin currentUserLogin].villageName];
        if ([[HWUserLogin currentUserLogin].coStatus isEqualToString:@"0"])
        {
            if (serviceVC.isShowMessageCenterRedDot)
            {
                self.navigationItem.rightBarButtonItem = [self navButton:self image:@"xiaoxi-02" action:@selector(messageCenterClick)];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = [self navButton:self image:@"xiaoxi-01" action:@selector(messageCenterClick)];
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (viewController == personVC)
    {
        [MobClick event:@"click_me"];
        [self hiddenTabbarMineDot];
        
        self.navigationItem.titleView = [Utility navTitleView:@"我"];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
}

- (void)showServiceMessageCenterRedDot
{
    if (self.selectedViewController == serviceVC)
    {
        if ([[HWUserLogin currentUserLogin].coStatus isEqualToString:@"0"])
        {
            if (serviceVC.isShowMessageCenterRedDot)
            {
                self.navigationItem.rightBarButtonItem = [self navButton:self image:@"xiaoxi-02" action:@selector(messageCenterClick)];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = [self navButton:self image:@"xiaoxi-01" action:@selector(messageCenterClick)];
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (void)messageCenterClick
{
    [serviceVC messageCenterClick];//服务汇跳信息中心
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
