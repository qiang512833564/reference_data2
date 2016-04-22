//
//  HWPublicRepairTotalVC.m
//  Community
//
//  Created by niedi on 15/6/15.
//  Copyright (c) 2015年 caijingpeng. All rights reserved.
//

#import "HWPublicRepairTotalVC.h"
#import "HWPublicRepairTotalView.h"

@interface HWPublicRepairTotalVC ()
{
    HWPublicRepairTotalView *_mainView;
}
@end

@implementation HWPublicRepairTotalVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [Utility navTitleView:@"全部报修"];
    
    _mainView = [[HWPublicRepairTotalView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CONTENT_HEIGHT)];
    [self.view addSubview:_mainView];
    
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
