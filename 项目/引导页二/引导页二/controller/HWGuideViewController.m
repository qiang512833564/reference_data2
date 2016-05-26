//
//  HWGuideViewController.m
//  引导页二
//
//  Created by lizhongqiang on 16/4/22.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "HWGuideViewController.h"
#import "HWLoginViewController.h"
#import "HWGuideTransitionAnmation.h"
#import "HWGuidePageView.h"
#import "HWGuidePageAnimation.h"

#define UIColorFrom10RGB(rgbValue) [UIColor colorWithRed:(rgbValue/(int)pow(10,6))/255.0 green:((rgbValue/(int)pow(10,6))%(int)pow(10,3))/255.0 blue:(rgbValue%(int)pow(10,3))/255.0 alpha:1.0]

@interface HWGuideViewController ()<UIViewControllerTransitioningDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIButton *enterBtn;

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;

@property (nonatomic, strong, readwrite) UIPageControl *pageCtrl;

@end

@implementation HWGuideViewController


#pragma mark --- 初始化组件

- (UIScrollView *)mainScrollView{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _mainScrollView.showsHorizontalScrollIndicator = false;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
    }
    return _mainScrollView;
}

- (UIPageControl *)pageCtrl{
    if (_pageCtrl == nil) {
        _pageCtrl = [[UIPageControl alloc]init];
        _pageCtrl.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, CGRectGetHeight([UIScreen mainScreen].bounds) - 34/2.0);
        _pageCtrl.bounds = (CGRect){{0,0},{150,18}};
        _pageCtrl.currentPageIndicatorTintColor = UIColorFrom10RGB(153153153);
        _pageCtrl.pageIndicatorTintColor = UIColorFrom10RGB(219219219);
    }
    return _pageCtrl;
}

#pragma mark ----- UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[HWGuideTransitionAnmation alloc]init];
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view addSubview:self.mainScrollView];
    
    [self.view addSubview:self.pageCtrl];
    
    [self configScrollView_SubPageView];
    
    
    HWGuidePageView *view = [self.mainScrollView viewWithTag:100];
    [view startAnimation];
}
#pragma mark --- 配置 mainScrollView 的每一页视图
- (void)configScrollView_SubPageView{
    
    for (int i=0; i<4; i++) {
        NSDictionary *parmas = nil;
        if (i != 3) {
            parmas = @{@"textImage":[NSString stringWithFormat:@"text%d",i+1],@"picImage":[NSString stringWithFormat:@"pic%d",i+1]};
        }else{
            parmas = @{@"textImage":[NSString stringWithFormat:@"text%d",i+1],@"picImage":[NSString stringWithFormat:@"pic%d",i+1],@"enterImage":@"enter"};
        }
        HWGuidePageView *page1 = [[HWGuidePageView alloc]initWithFrame:CGRectOffset(self.mainScrollView.bounds , i*(CGRectGetWidth(self.mainScrollView.bounds)), 0) params:parmas];
        page1.tag = 100 + i;
        page1.vc = self;
        page1.backgroundColor = [UIColor whiteColor];
        [self.mainScrollView addSubview:page1];
        
    }
    
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainScrollView.bounds)*4, 0);
    
    self.pageCtrl.numberOfPages = 4;
}
#pragma mark --- ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int page = (int)scrollView.contentOffset.x/scrollView.bounds.size.width;
    
    self.pageCtrl.currentPage = page;
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = (int)scrollView.contentOffset.x/scrollView.bounds.size.width;
    HWGuidePageView *view = [self.mainScrollView viewWithTag:page+100];
    [view startAnimation];
}

- (void)enterAction{
    HWLoginViewController *vc = [[HWLoginViewController alloc]init];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:^{
        [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    }];
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
