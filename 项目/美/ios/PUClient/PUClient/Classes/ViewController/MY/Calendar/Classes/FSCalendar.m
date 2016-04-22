//
//  FScalendar.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <objc/runtime.h>
#import "FSCalendar.h"
#import "FSCalendarPage.h"
#import "FSCalendarUnit.h"
#import "FSCalendarHeader.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"

#define kDayName (@"STHeitiSC Light")
#define kPageSpace (100*kScale)
#define KWeekName (@"ArialMT Regular")
#define kWeekHeight (156.*kScale)
#define kScale (667/2200.f)
#define kBlueText [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]
#define kMonthHeight (800.f*kScale)
const char * flowKey;

@interface FSCalendar ()<UIScrollViewDelegate, FSCalendarUnitDataSource, FSCalendarUnitDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *weekdays;
@property (strong, nonatomic) FSCalendarPage *page0;
@property (strong, nonatomic) FSCalendarPage *page1;
@property (strong, nonatomic) FSCalendarPage *page3;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) CGFloat baseOffset;

@property (readonly, nonatomic) CGSize flowSize;
@property (readonly, nonatomic) CGPoint flowOffset;
@property (readonly, nonatomic) CGFloat flowSide;
@property (readonly, nonatomic) CGFloat flowScrollOffset;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

@end

@implementation FSCalendar

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    NSArray *weekSymbols = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];//[[NSCalendar currentCalendar] shortStandaloneWeekdaySymbols];
    _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
    for (int i = 0; i < weekSymbols.count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.text = weekSymbols[i];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = [UIFont fontWithName:KWeekName size:48*kScale];
        weekdayLabel.textColor = kBlueText;
        [_weekdays addObject:weekdayLabel];
        [self addSubview:weekdayLabel];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = YES;
    _scrollView.opaque = NO;
    //_scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.tag = -1;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    [self addSubview:_scrollView];
    
    _page0 = [[FSCalendarPage alloc] initWithFrame:CGRectZero];
    _page0.tag = 0;
    [_scrollView addSubview:_page0];
    
    _page1 = [[FSCalendarPage alloc] initWithFrame:CGRectZero];
    _page1.tag = 1;
    [_scrollView addSubview:_page1];
    
    _page3 = [[FSCalendarPage alloc]initWithFrame:CGRectZero];
    _page3.tag = 2;
    [_scrollView addSubview:_page3];
    
    _currentDate = [NSDate date];
    
    
    _currentMonth = [_currentDate copy];
    
    
    [_page0.subviews setValue:self forKeyPath:@"dataSource"];
    [_page0.subviews setValue:self forKeyPath:@"delegate"];
    [_page1.subviews setValue:self forKeyPath:@"dataSource"];
    [_page1.subviews setValue:self forKeyPath:@"delegate"];
    [_page3.subviews setValue:self forKeyPath:@"dataSource"];
    [_page3.subviews setValue:self forKeyPath:@"delegate"];
    
    _titleFont = [UIFont systemFontOfSize:0*kScale];
    _subtitleFont = [UIFont systemFontOfSize:11];
    _unitStyle = FSCalendarUnitStyleCircle;
//    
//    _page0.backgroundColor = [UIColor redColor];
//    _page1.backgroundColor = [UIColor greenColor];
//    _page3.backgroundColor = [UIColor blueColor];

}
- (void)setMyHeader:(UILabel *)myHeader
{
    _myHeader = myHeader;
    if(_myHeader) {
        ;
        _myHeader.text = [NSString stringWithFormat:@"%ld.%ld.%ld %@",(long)_currentDate.fs_year,(long)_currentDate.fs_month,_currentDate.fs_day,[NSDate fs_dateFromWeek:_currentDate.fs_weekday]];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_scrollView.tag == -1) {
        if (CGRectEqualToRect(_scrollView.frame, CGRectZero)) {
            // make sure this is called only at initialing
            _scrollView.frame = CGRectMake(0, kWeekHeight, self.fs_width, self.fs_height-kWeekHeight);
            _scrollView.contentInset = UIEdgeInsetsZero;
            _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            self.autoAdjustTitleSize = YES;
            
            [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CGFloat width = self.fs_width/_weekdays.count;
                CGFloat height = kWeekHeight;
                [obj setFrame:CGRectMake(idx*width, 0, width, height)];
            }];
        }
        _page0.frame = CGRectMake(0, 0, _scrollView.fs_width, kMonthHeight);//_scrollView.fs_width
        _page1.frame = CGRectOffset(_page0.frame, self.flowOffset.x, self.flowOffset.y);
        _page3.frame = CGRectOffset(_page1.frame, self.flowOffset.x, self.flowOffset.y);
        [self updatePage:_page0 forIndex:_currentPage];
        [self updatePage:_page1 forIndex:_currentPage + 1];
        [self updatePage:_page3 forIndex:_currentPage + 2];
        
        
        _scrollView.contentSize = self.flowSize;
        _scrollView.tag = 0;
    }
    
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = self.flowScrollOffset;
    if (offset > self.flowSide) {
        _scrollView.bounds = CGRectOffset(_scrollView.bounds, -self.flowOffset.x, -self.flowOffset.y);
        
       // NSLog(@"前%f-------%f----------%f",CGRectGetMaxY(_page0.frame),CGRectGetMaxY(_page1.frame),CGRectGetMaxY(_page3.frame));
        _page0.frame = CGRectOffset(_page1.frame, self.flowOffset.x, self.flowOffset.y);
        _page1.frame = CGRectOffset(_page1.frame, -self.flowOffset.x, -(self.flowOffset.y));
        _page3.frame = CGRectOffset(_page0.frame, -self.flowOffset.x, -(self.flowOffset.y));
        _baseOffset += self.flowOffset.x + self.flowOffset.y;
        offset -= (self.flowOffset.x + self.flowOffset.y);
        [self updatePointer];
        [self updatePage:_page0 forIndex:self.currentPage ];
        [self updatePage:_page1 forIndex:self.currentPage + 1];
        [self updatePage:_page3 forIndex:self.currentPage + 2];
//        NSLog(@"下%ld",self.currentPage);
//        NSLog(@"前%f-------%f----------%f",CGRectGetMaxY(_page0.frame),CGRectGetMaxY(_page1.frame),CGRectGetMaxY(_page3.frame));
    } else if (offset < 0) {
        
       // NSLog(@"前%f-------%f----------%f",CGRectGetMaxY(_page0.frame),CGRectGetMaxY(_page1.frame),CGRectGetMaxY(_page3.frame));
        _scrollView.bounds = CGRectOffset(_scrollView.bounds, self.flowOffset.x, self.flowOffset.y);
        
        _page0.frame = CGRectOffset(_page0.frame, self.flowOffset.x, self.flowOffset.y);
        _page1.frame = CGRectOffset(_page1.frame, self.flowOffset.x, self.flowOffset.y);
        _page3.frame = CGRectOffset(_page0.frame, -self.flowOffset.x, -(self.flowOffset.y));
        _baseOffset -= (self.flowOffset.x + self.flowOffset.y);
        
        // NSLog(@"前%f-------%f----------%f",CGRectGetMaxY(_page0.frame),CGRectGetMaxY(_page1.frame),CGRectGetMaxY(_page3.frame));
        
        offset += (self.flowOffset.x + self.flowOffset.y);
        [self updatePointer];
        
        [self updatePage:_page0 forIndex:self.currentPage - 1];
        [self updatePage:_page1 forIndex:self.currentPage];
        [self updatePage:_page3 forIndex:self.currentPage + 1];
        
        
        //NSLog(@"后%f-------%f----------%f",CGRectGetMaxY(_page0.frame),CGRectGetMaxY(_page1.frame),CGRectGetMaxY(_page3.frame));
        
        //NSLog(@"上%ld",self.currentPage);
    }
    self.currentPage = (roundf(offset/self.flowSide)*self.flowSide+self.baseOffset)/self.flowSide;
    
    
}

#pragma mark - Setter & Getter

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        self.currentMonth = [_currentDate fs_dateByAddingMonths:currentPage];
        if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentMonthDidChange:)]) {
            [_delegate calendarCurrentMonthDidChange:self];
        }
    }
}

- (void)setFlow:(FSCalendarFlow)flow
{
    if (self.flow != flow) {
        objc_setAssociatedObject(self, &flowKey, @(flow), OBJC_ASSOCIATION_COPY_NONATOMIC);
        _scrollView.tag = -1;
        _baseOffset = _currentPage * self.flowSide;
        [self setNeedsLayout];
    }
}

- (FSCalendarFlow)flow
{
    return [objc_getAssociatedObject(self, &flowKey) integerValue];
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    if (!_autoAdjustTitleSize) {
        [_weekdays setValue:weekdayFont forKeyPath:@"font"];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
   [_weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
}

- (void)setHeader:(FSCalendarHeader *)header
{
    if (_header != header) {
        _header = header;
        if (header) {
            header.calendar = self;
        }
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate isEqualToDate:currentDate]) {
        _currentDate = [currentDate copy];
        _currentMonth = [_currentDate copy];
        [self updatePage:_page0 forIndex:0];
        [self updatePage:_page1 forIndex:1];
        [self updatePage:_page3 forIndex:2];
        if (_header) {
            _header.calendar = nil;
            _header.calendar = self;
        }
    }
}

- (void)setHeaderTitleFont:(UIFont *)font
{
    _header.titleFont = font;
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    _header.titleColor = color;
}

- (void)setHeaderDateFormat:(NSString *)dateFormat
{
    _header.dateFormat = dateFormat;
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateNormal];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateNormal];
    }];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateSelected];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateSelected];
    }];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateToday];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateToday];
    }];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStatePlaceholder];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStatePlaceholder];
    }];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateWeekend];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setTitleColor:color forState:FSCalendarUnitStateWeekend];
    }];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateNormal];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateNormal];
    }];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateSelected];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateSelected];
    }];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateToday];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateToday];
    }];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStatePlaceholder];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStatePlaceholder];
    }];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateWeekend];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setSubtitleColor:color forState:FSCalendarUnitStateWeekend];
    }];
}

- (void)setSelectionColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setUnitColor:color forState:FSCalendarUnitStateSelected];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setUnitColor:color forState:FSCalendarUnitStateSelected];
    }];
}

- (void)setTodayColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setUnitColor:color forState:FSCalendarUnitStateToday];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setUnitColor:color forState:FSCalendarUnitStateToday];
    }];
}

- (void)setEventColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setEventColor:color];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setEventColor:color];
    }];
}

- (void)setTitleFont:(UIFont *)font
{
    if (_autoAdjustTitleSize) {
        return;
    }
    if (_titleFont != font) {
        _titleFont = font;
        [_page0.subviews setValue:_titleFont forKeyPath:@"titleFont"];
        [_page1.subviews setValue:_titleFont forKeyPath:@"titleFont"];
    }
}

- (void)setSubtitleFont:(UIFont *)font
{
    if (_autoAdjustTitleSize) {
        return;
    }
    if (_subtitleFont != font) {
        _subtitleFont = font;
        [_page0.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
        [_page1.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
    }
}

- (void)setMinDissolvedAlpha:(CGFloat)minDissolvedAlpha
{
    if (_minDissolvedAlpha != minDissolvedAlpha) {
        _minDissolvedAlpha = minDissolvedAlpha;
       _header.minDissolveAlpha = minDissolvedAlpha;
    }
}

#pragma mark - Public

- (void)reloadData
{
    [self updatePage:_page0 forIndex:_currentPage];
    [self updatePage:_page1 forIndex:_currentPage + 1];
    [self updatePage:_page3 forIndex:_currentPage + 2];
}

#pragma mark - Private

- (void)updatePointer
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            if (_page0.fs_left > _page1.fs_left) {
                id temp0 = _page3;
                self.page1 = _page3;
                self.page1 = temp0;
            }
            break;
        case FSCalendarFlowVertical:
            if (_page0.fs_top > _page1.fs_top) {
                id temp0 = _page0;
                id temp1 = _page3;
                self.page0 = _page1;
                self.page3 = temp0;
                self.page1 = temp1;
            }else
            {
                id temp0 =_page0;

                self.page0 = _page3;
                self.page3 = self.page1;
                self.page1 = temp0;
            }
            break;
        default:
            break;
    }
}

- (CGSize)flowSize
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return CGSizeMake(_scrollView.fs_width * 3, _scrollView.fs_height);
            break;
        case FSCalendarFlowVertical:
            return CGSizeMake(_scrollView.fs_width,  kMonthHeight*3+2*kPageSpace);//_scrollView.fs_height
            break;
        default:
            break;
    }
}

- (CGPoint)flowOffset
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return CGPointMake(_scrollView.fs_width, 0);
            break;
        case FSCalendarFlowVertical:
            return CGPointMake(0, kMonthHeight+kPageSpace/2.f);//_scrollView.fs_height
            break;
        default:
            break;
    }
}
//滚动距离
- (CGFloat)flowSide
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return _scrollView.fs_width;
            break;
        case FSCalendarFlowVertical:
            return kMonthHeight+kPageSpace/2.f;//_scrollView.fs_height;
            break;
        default:
            break;
    }
}

- (CGFloat)flowScrollOffset
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return _scrollView.contentOffset.x;
            break;
        case FSCalendarFlowVertical:
            return _scrollView.contentOffset.y;
            break;
        default:
            break;
    }
}

- (void)updatePage:(FSCalendarPage *)page forIndex:(NSInteger)index
{
    NSDate *destDate = [_currentDate fs_dateByAddingMonths:index];
    page.date = destDate;
}

- (BOOL)shouldSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:shouldSelectDate:)]) {
        return [_delegate calendar:self shouldSelectDate:date];
    }
    return YES;
}

- (void)didSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [_delegate calendar:self didSelectDate:date];
        
        
    }
}

- (NSString *)subtitleForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [_dataSource calendar:self subtitleForDate:date];
    }
    return nil;
}

- (BOOL)hasEventForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [_dataSource calendar:self hasEventForDate:date];
    }
    return NO;
}

- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        if (autoAdjustTitleSize) {
            _titleFont = [_titleFont fontWithSize:kMonthHeight/3/6];
            _subtitleFont = [_subtitleFont fontWithSize:_scrollView.fs_height/4.3/6];
            [_page0.subviews setValue:_titleFont forKeyPath:@"titleFont"];
            [_page1.subviews setValue:_titleFont forKeyPath:@"titleFont"];
            [_page0.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
            [_page1.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
            [_page3.subviews setValue:_titleFont forKeyPath:@"titleFont"];
        
        }
    }
}

- (void)setUnitStyle:(FSCalendarUnitStyle)unitStyle
{
    if (_unitStyle != unitStyle) {
        _unitStyle = unitStyle;
        [_page0.subviews setValue:@(unitStyle) forKeyPath:@"style"];
        [_page1.subviews setValue:@(unitStyle) forKeyPath:@"style"];
    }
}

#pragma mark - Unit DataSource

- (NSString *)subtitleForUnit:(FSCalendarUnit *)unit
{
    return [self subtitleForDate:unit.date];
}

- (BOOL)hasEventForUnit:(FSCalendarUnit *)unit
{
    return [self hasEventForDate:unit.date];
}

- (BOOL)unitIsToday:(FSCalendarUnit *)unit
{
//    FSCalendarPage *page = (FSCalendarPage *)unit.superview;
//    CGFloat offset = self.flowScrollOffset;
//    if (offset > self.flowSide)
//    {
//        if(page == _page3)
//        {
//            return unit.weekend;
//        }
//    }else if(offset < 0)
//    {
//        if (page == _page0) {
//            return unit.weekend;
//        }
//    }
    
    BOOL today = unit.date.fs_year == self.currentDate.fs_year;
    today &= unit.date.fs_month == self.currentDate.fs_month;
    today &= unit.date.fs_day == self.currentDate.fs_day;
    return today&&!unit.placeholder;
}

- (BOOL)unitIsPlaceholder:(FSCalendarUnit *)unit
{
    
    FSCalendarPage *page = (FSCalendarPage *)unit.superview;
    BOOL isPlaceholder = page.date.fs_year != unit.date.fs_year;
    isPlaceholder |= page.date.fs_month != unit.date.fs_month;
    return isPlaceholder;
}

- (BOOL)unitIsSelected:(FSCalendarUnit *)unit
{
    if ([self unitIsPlaceholder:unit]) {
        return NO;
    }
//    FSCalendarPage *page = (FSCalendarPage *)unit.superview;
//    CGFloat offset = self.flowScrollOffset;
//    if (offset > self.flowSide)
//    {
//        if(page == _page3)
//        {
//            return unit.weekend;
//        }
//    }else if(offset < 0)
//    {
//        if (page == _page0) {
//            return unit.weekend;
//        }
//    }
    BOOL selected = unit.date.fs_year == self.selectedDate.fs_year;
    selected &= unit.date.fs_month == self.selectedDate.fs_month;
    selected &= unit.date.fs_day == self.selectedDate.fs_day;
    return selected;
}

#pragma mark - Unit Delegate

- (void)handleUnitTap:(FSCalendarUnit *)unit
{
    if ([self shouldSelectDate:unit.date] && !unit.isSelected) {
        if (unit.isPlaceholder) {
            NSArray *subviews;
            if ([_page0.subviews containsObject:unit]) {
                subviews = _page0.subviews;
            } else {
                subviews = _page1.subviews;
            }
            NSInteger index = [subviews indexOfObject:unit];
            if (index <= 7) {
                [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x-[self flowOffset].x, _scrollView.contentOffset.y-self.flowOffset.y) animated:YES];
            } else {
                [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x+[self flowOffset].x, _scrollView.contentOffset.y+self.flowOffset.y) animated:YES];
            }
        }
        self.selectedDate = unit.date;
        
        NSDate *date = unit.date;
        
        if (_myHeader) {
            
            _myHeader.text = [NSString stringWithFormat:@"%ld.%ld.%ld %@",(long)date.fs_year,(long)date.fs_month,date.fs_day,[NSDate fs_dateFromWeek:date.fs_weekday]];
        }
        [_page0.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [_page1.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [self didSelectDate:unit.date];
    }
}

@end

