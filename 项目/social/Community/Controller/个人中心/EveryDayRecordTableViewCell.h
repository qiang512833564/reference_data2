//
//  EveryDayRecordTableViewCell.h
//  TEST
//
//  Created by gusheng on 14-8-29.
//  Copyright (c) 2014年 gusheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EveryDayRecordTableViewCell : UITableViewCell
@property(nonatomic,strong)IBOutlet UILabel *phoneStyle;
@property(nonatomic,strong)IBOutlet UILabel *scanMonthAndDay;
@property(nonatomic,strong)IBOutlet UILabel *activeMonthAndDay;
@property(nonatomic,strong)IBOutlet UILabel *registerTime;

@end
