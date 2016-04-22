//
//  ViewController.m
//  动画展开TableView的cell
//
//  Created by lizhongqiang on 16/3/31.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) CGFloat selectedCellHeight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[@"Cell 1", @"通知", @"Cell 3"];
    
    self.selectedCellHeight = 44;
    
    [self.tableView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        return self.selectedCellHeight;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]init];
    label.text = @"  Section-1";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.row == 1) {
        UISwitch *switchUI = [[UISwitch alloc]init];
        [cell.contentView addSubview:switchUI];
        switchUI.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 67, 5, 55, 37);
        [switchUI addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,44, 375-2*10, 0)];
        label.tag = 100;
        [cell.contentView addSubview:label];
        return cell;
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}
- (void)switchAction:(UISwitch *)switchUI{
    
     UITableViewCell *secondCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel *label = [secondCell.contentView viewWithTag:100];
    CGRect frame = label.frame;
    if (switchUI.on == YES) {
       
        label.numberOfLines = 0;
        label.text = @"我是一个label，在这里只是作为测试的啊！不要为难我啊 .我是一个label，在这里只是作为测试的啊！不要为难我啊 ,我是一个label，在这里只是作为测试的啊！不要为难我啊 ,我是一个label，在这里只是作为测试的啊！不要为难我啊,我是一个label，在这里只是作为测试的啊！不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊 我是一个label，在这里只是作为测试的啊！不要为难我啊";
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor yellowColor];
#pragma mark --- 这里通过改变UILabel的contentMode来，设置动画的时候label文字的顶部不变，文字自上而下显示，而不是从中间显示
        label.contentMode = UIViewContentModeTop;
        [secondCell.contentView addSubview:label];
        self.selectedCellHeight = 44+100;
        
        
        frame.size.height = 100;
    }else{
        self.selectedCellHeight = 44;
        frame.size.height = 0;
    }
   
    [UIView beginAnimations:@"myAnimationId" context:nil];
    [UIView setAnimationDuration:0.5];
    
    /*
     CATransaction is the Core Animation mechanism for batching multiple layer-tree operations into atomic updates to the render tree
     
     1. CATransition继承自CAAnimation
     
     Core Animation supports two types of transactions: implicit transactions and explicit transactions.
     
     2. Core Animation一般分为两种：含蓄过渡和明显过渡
     
     CATransaction allows you to override default animation properties that are set for animatable properties. You can customize duration, timing function, whether changes to properties trigger animations, and provide a handler that informs you when all animations from the transaction group are completed.
     
     3. CATransaction能够让你把继承自animation的default properties改变掉（比如duration、timing function等），也能够通过block，当所有的animations完成时通知你。
     */
    [CATransaction begin];
    
//    [CATransaction setAnimationDuration:10.5];
    [CATransaction setCompletionBlock:^{
        NSLog(@"动画完成");
    }];
    
#pragma mark ----   beginUpdates与endUpdates成对出现，通过对它们的调用，可以实现insertions, deletion, and selection operations操作的同时，进行动画；另外也可以动画改变the row heights 而不用去刷新cell reloading the cell
    //注意：beginUpdates内部会调用cell的代理方法，用于返回cell的高度
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    
    
    [CATransaction commit];
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.5 animations:^{
        label.frame = frame;
    }];
    /*
     2.方法二
    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        label.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
     */
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
