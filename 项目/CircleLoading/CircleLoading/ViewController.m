//
//  ViewController.m
//  CircleLoading
//
//  Created by lizhongqiang on 16/1/26.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD.h>
#import "Gradual_Change_Circle.h"
#import "CustomProgressHUD.h"
#import "GradientProgressView.h"
@interface ViewController ()
{
    GradientProgressView *progressView;
}
//@property (nonatomic, strong)NSArray *INColors;
@end

@implementation ViewController
//@synthesize INColors;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"加载" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(20, 100, 120, 120);
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
    Gradual_Change_Circle *cirle = [[Gradual_Change_Circle alloc]initWithFrame:btn.bounds];
    //[btn addSubview:cirle];
    
    CGRect frame = CGRectMake(0, 22.0f, CGRectGetWidth([[self view] bounds]), 1.0f);
    progressView = [[GradientProgressView alloc] initWithFrame:frame];
    
    UIView *view = [self view];
    [view setBackgroundColor:[UIColor blackColor]];
    [view addSubview:progressView];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(changeColor)
                                   userInfo:nil
                                    repeats:YES];
}
- (void)changeColor
{
    self.view.backgroundColor = INColors[0];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Starts the moving gradient effect
    [progressView startAnimating];
    
    // Continuously updates the progress value using random values
    [self simulateProgress];
    
    [self injected];
}
- (void)injected{
    NSLog(@"I've been idadaadnjected: %@sdadadadada", self);
    
    
}
- (void)simulateProgress {
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        CGFloat increment = (arc4random() % 5) / 10.0f + 0.1;
        CGFloat progress  = [progressView progress] + increment;
        [progressView setProgress:progress];
        if (progress < 1.0) {
            
            [self simulateProgress];
        }
    });
}
- (void)btnAction{
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    progressHUD .removeFromSuperViewOnHide = YES;
    CustomProgressHUD *subView = [[CustomProgressHUD alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    progressHUD.mode = MBProgressHUDModeCustomView;//MBProgressHUDModeAnnularDeterminate;
    progressHUD.progress = 0.5;
    progressHUD.margin = 10;//默认为20
    progressHUD.color = [UIColor whiteColor];
    progressHUD.customView = subView;
    progressHUD.minSize = CGSizeMake(403/1.7, 284/1.9);
    subView.bounds = CGRectMake(0, 0, progressHUD.minSize.width, progressHUD.minSize.height);
    [self.view addSubview:progressHUD];
    [progressHUD show:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
