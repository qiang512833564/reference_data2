//
//  MyLevelVC.m
//  PUClient
//
//  Created by RRLhy on 15/8/4.
//  Copyright (c) 2015年 RRLhy. All rights reserved.
//

#import "MyLevelVC.h"

@interface MyLevelVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *levelWeb;

@end

@implementation MyLevelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"我的等级";

    NSString * token = [UserInfoConfig sharedUserInfoConfig].userInfo.token;
    NSString * url = [NSString stringWithFormat:@"http://42.96.184.91:8080/page/myLevel?token=%@",token];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL(url)];
    [_levelWeb loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
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
