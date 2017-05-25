//
//  JKPageView.m
//  JKPageView
//
//  Created by Jjyo on 16/4/24.
//  Copyright © 2016年 Jjyo. All rights reserved.
//

#import "JKPageView.h"
//#define kStartTag   111000
#define kDefaultScrollInterval  2

typedef NS_ENUM(NSUInteger, JKPageViewPosition) {
    JKPageViewPositionFirst = 0,
    JKPageViewPositionCenter,
    JKPageViewPositionLast,
    JKPageViewSize,
};

@interface JKPageView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic, strong) NSMutableArray *pageControlConstraints;
@property (nonatomic, strong) NSMutableArray *scrollViewConstraints;
@property (nonatomic, copy) NSArray *pageViewArray;
//@property (nonatomic, copy) NSArray *itemViewArray;
@property (nonatomic, assign) NSUInteger showIndex;//显示的索引

@end


@implementation JKPageView

@synthesize scrollEnabled = _scrollEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithDelegate:(id<JKPageViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self _init];
    }
    return self;
}

- (void)_init
{
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.scrollViewConstraints = [NSMutableArray array];
    
    self.scrollInterval = kDefaultScrollInterval;
    
    // scrollview
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] init];
        [self addSubview:self.scrollView];
    }
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    // UIPageControl
    if (!self.pageControl) {
        self.pageControl = [[UIPageControl alloc] init];
    }
//    self.pageControl.userInteractionEnabled = YES;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageControl.numberOfPages = self.count;
    self.pageControl.currentPage = 0;
    self.pageControl.enabled = NO;
//    [self.pageControl addTarget:self action:@selector(handleClickPageControl:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.pageControl];
    
    NSArray *pageControlVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl]-0-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"pageControl": self.pageControl}];
    NSArray *pageControlHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[pageControl]-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"pageControl": self.pageControl}];
    self.pageControlConstraints = [NSMutableArray arrayWithArray:pageControlVConstraints];
    [self.pageControlConstraints addObjectsFromArray:pageControlHConstraints];
    [self addConstraints:self.pageControlConstraints];
    
    self.edgeInsets = UIEdgeInsetsZero;
    
    [self reloadData];
}


- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.scrollView.scrollEnabled = scrollEnabled;
    NSLog(@"%s, scrollEnabled: %d", __FUNCTION__, scrollEnabled);
}

- (BOOL)isScrollEnabled
{
    return self.scrollView.isScrollEnabled;
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
    
    if (self.autoScrollTimer) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    self.scrollView.delegate = nil;
    self.delegate = nil;
    NSLog(@"%s", __FUNCTION__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]) {
        NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
        [self reloadData];
    }
}

- (void)reloadData
{
    // remove subview from scrollview first
    
    NSLog(@"%s, start _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
//    self.itemViewArray = nil;
    self.pageViewArray = nil;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    self.count = [self.delegate numberOfItemsInPageView:self];
    
    self.pageControl.numberOfPages = self.count;
    self.pageControl.currentPage = 0;
    
    if (self.count == 0) {
        return;
    }
    
    int itemCount = (int)self.count;
//    if (self.endlessScroll) {
//        itemCount += 2;
//    }
    
    
    
    CGFloat width = self.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right;
    CGFloat height = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    
//    NSMutableArray *itemArray = [NSMutableArray array];
//    for (int i = 0; i < self.count; i++) {
//        UIView *subView = [self.delegate pageView:self viewAtIndex:i];
//        [itemArray addObject:subView];
//    }
//    self.itemViewArray = itemArray;
    
    /*
     
     创建3个缓存的页面容器
     first | center | last
     
     */
    const int pageCount = JKPageViewSize;//分成3个缓存页
    NSMutableArray *pageArray = [NSMutableArray array];
    for (int i = 0; i < pageCount; i++) {
        UIView *subView = [UIView new];
//        subView.backgroundColor = sliceColors[i];
        subView.userInteractionEnabled = YES;
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [subView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        [self.scrollView addSubview:subView];
        [pageArray addObject:subView];
        
        [subView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
        [subView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    }
    self.pageViewArray = pageArray;
    
    // constraint
    NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *viewNames = [NSMutableArray array];
    for (int i = 0; i < pageCount; i++) {
        NSString *viewName = [NSString stringWithFormat:@"subView%d", i];
        [viewNames addObject:viewName];
        
        UIView *view = _pageViewArray[i];
        [viewsDictionary setObject:view forKey:viewName];
    }
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|-0-[%@]-0-|", (_isVertical? @"H" : @"V") , [viewNames objectAtIndex:0]]
                                                                            options:kNilOptions
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    
    NSMutableString *hConstraintString = [NSMutableString string];
    [hConstraintString appendString:_isVertical ? @"V:" : @"H:"];
    [hConstraintString appendString:@"|-0"];
    for (NSString *viewName in viewNames) {
        [hConstraintString appendFormat:@"-[%@]-0", viewName];
    }
    [hConstraintString appendString:@"-|"];
    
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hConstraintString
                                                                            options:_isVertical ? NSLayoutFormatAlignAllLeft : NSLayoutFormatAlignAllTop
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    if (_isVertical) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width , self.scrollView.frame.size.height * itemCount);

    }else{
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * itemCount, self.scrollView.frame.size.height);
    }
    self.scrollView.contentInset = UIEdgeInsetsZero;
    
    [self.scrollView scrollRectToVisible:[_pageViewArray[JKPageViewPositionCenter] frame] animated:NO];
    [self allocPageView];
    
    if (self.count == 1) {
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = _scrollEnabled;
    }
//    NSLog(@"%s, end _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

- (void)toString
{
    for (UIView *subView in self.scrollView.subviews) {
        NSLog(@"subView rect = %@", NSStringFromCGRect(subView.frame));
    }
}

#pragma mark - actions
- (void)handleTapGesture:(UIGestureRecognizer *)tapGesture
{
//    UIView *view = tapGesture.view;
//    NSInteger index = view.tag - kStartTag;
//    if (index == self.count) {
//        index = 0;
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageView:didTapAtIndex:)]) {
        [self.delegate pageView:self didTapAtIndex:_showIndex];
    }
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

- (void)handleClickPageControl:(UIPageControl *)sender
{
//    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
//        [self.autoScrollTimer invalidate];
//    }
//    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
//    
//    UIView *view = [self.scrollView viewWithTag:(sender.currentPage + kStartTag)];
//    [self.scrollView scrollRectToVisible:view.frame animated:YES];
}

#pragma mark - auto scroll
- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        if (!self.autoScrollTimer || !self.autoScrollTimer.isValid) {
            self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
        }
    } else {
        if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
            [self.autoScrollTimer invalidate];
            self.autoScrollTimer = nil;
        }
    }
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

- (void)setScrollInterval:(NSUInteger)scrollInterval
{
    _scrollInterval = scrollInterval;
    
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

- (void)handleScrollTimer:(NSTimer *)timer
{
    if (self.count > 1) {
        UIView *view = [self.scrollView.subviews lastObject];
        [self.scrollView scrollRectToVisible:view.frame animated:YES];
    }
    
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

#pragma mark - scroll delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // disable v direction scroll
//    if (scrollView.contentOffset.y > 0) {
//        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
//    }
    
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
    [self didEndScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
    [self didEndScroll:scrollView];
}

- (void)didEndScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%s, _pageViewArray: %@, %d", __FUNCTION__, _pageViewArray, (int)_pageViewArray.count);
    // when user scrolls manually, stop timer and start timer again to avoid next scroll immediatelly
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
    }
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
    
    
    // update UIPageControl
    
    CGRect visiableRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height);
    NSInteger currentIndex = JKPageViewPositionLast;//默认方向
    for (int i = 0; i < _pageViewArray.count; i++) {
        UIView *view = _pageViewArray[i];
        if (CGRectContainsPoint(visiableRect, CGPointMake(CGRectGetMidX(view.frame), CGRectGetMinY(view.frame) ))) {
            currentIndex = i;
            break;
        }
    }
    
    if (currentIndex == JKPageViewPositionFirst) {
        _showIndex = (--_showIndex + self.count) % self.count;
    }else if (currentIndex == JKPageViewPositionLast){
        _showIndex = ++_showIndex % self.count;
    }
    
//    NSLog(@"_pageViewArray: %@, %d", _pageViewArray, (int)_pageViewArray.count);
    //奖scroll content 居中
    UIView *centerView = _pageViewArray[JKPageViewPositionCenter];
    [scrollView setContentOffset:centerView.frame.origin];
    
    [self allocPageView];
    
//    NSLog(@"current page = %ld", currentIndex);
    self.pageControl.currentPage = _showIndex;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageView:didScorllIndex:)]) {
        [self.delegate pageView:self didScorllIndex:_showIndex];
    }
    
}


- (UIView *)getItemViewAtIndex:(NSUInteger)idx
{
    UIView *view = view = [self.delegate pageView:self viewAtIndex:idx];
    return view;
}


- (void)allocPageView
{
    if (self.count < 1) {
        return;
    }
    
//    NSLog(@"%s: %@, %d", __FUNCTION__, _pageViewArray, (int)self.count);
//    [_itemViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //left view
    {
        UIView *firstView = [_pageViewArray objectAtIndex:JKPageViewPositionFirst];
        NSInteger idx = (_showIndex + self.count - 1) % self.count;
        UIView *subView = [self getItemViewAtIndex:idx];
        [self parentView:firstView addSubview:subView];
        //NSLog(@"allocPageView leftIndex = %ld", idx);
    }
    
    //center view
    {
        UIView *showView = [_pageViewArray objectAtIndex:JKPageViewPositionCenter];
        NSInteger idx = _showIndex % self.count;
        UIView *subView = [self getItemViewAtIndex:idx];
        [self parentView:showView addSubview:subView];
        //NSLog(@"allocPageView showIndex = %ld", idx);
    }
    
    //right view
    {
        UIView *lastView = [_pageViewArray objectAtIndex:JKPageViewPositionLast];
        NSInteger idx = (_showIndex + 1) % self.count;
        UIView *subView = [self getItemViewAtIndex:idx];
        [self parentView:lastView addSubview:subView];
        //NSLog(@"allocPageView rightIndex = %ld", idx);
    }
    //NSLog(@"===================");
}


- (void)parentView:(UIView *)rootView addSubview:(UIView *)subview
{
    [rootView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [rootView addSubview:subview];
    
    NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
    viewsDictionary[@"subview"] = subview;
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [rootView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary]];
    [rootView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary]];

}


#pragma mark - settings
- (void)setPageControlPosition:(JKPageControlPosition)pageControlPosition
{
    NSString *vFormat = nil;
    NSString *hFormat = nil;
    
    switch (pageControlPosition) {
        case JKPageControlPositionTopLeft: {
            vFormat = @"V:|-0-[pageControl]";
            hFormat = @"H:|-[pageControl]";
            break;
        }
            
        case JKPageControlPositionTopCenter: {
            vFormat = @"V:|-0-[pageControl]";
            hFormat = @"H:|[pageControl]|";
            break;
        }
            
        case JKPageControlPositionTopRight: {
            vFormat = @"V:|-0-[pageControl]";
            hFormat = @"H:[pageControl]-|";
            break;
        }
            
        case JKPageControlPositionBottomLeft: {
            vFormat = @"V:[pageControl]-0-|";
            hFormat = @"H:|-[pageControl]";
            break;
        }
            
        case JKPageControlPositionBottomCenter: {
            vFormat = @"V:[pageControl]-0-|";
            hFormat = @"H:|[pageControl]|";
            break;
        }
            
        case JKPageControlPositionBottomRight: {
            vFormat = @"V:[pageControl]-0-|";
            hFormat = @"H:[pageControl]-|";
            break;
        }
            
        default:
            break;
    }
    
    [self removeConstraints:self.pageControlConstraints];
    
    NSArray *pageControlVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vFormat
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"pageControl": self.pageControl}];
    
    NSArray *pageControlHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hFormat
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"pageControl": self.pageControl}];
    
    [self.pageControlConstraints removeAllObjects];
    [self.pageControlConstraints addObjectsFromArray:pageControlVConstraints];
    [self.pageControlConstraints addObjectsFromArray:pageControlHConstraints];
    
    [self addConstraints:self.pageControlConstraints];
}

- (void)setHidePageControl:(BOOL)hidePageControl
{
    self.pageControl.hidden = hidePageControl;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    
    [self removeConstraints:self.scrollViewConstraints];
    
    NSArray *scrollViewVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[scrollView]-bottom-|"
                                                                              options:kNilOptions
                                                                              metrics:@{@"top": @(self.edgeInsets.top),
                                                                                        @"bottom": @(self.edgeInsets.bottom)}
                                                                                views:@{@"scrollView": self.scrollView}];
    NSArray *scrollViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[scrollView]-right-|"
                                                                              options:kNilOptions
                                                                              metrics:@{@"left": @(self.edgeInsets.left),
                                                                                        @"right": @(self.edgeInsets.right)}
                                                                                views:@{@"scrollView": self.scrollView}];
    
    [self.scrollViewConstraints removeAllObjects];
    [self.scrollViewConstraints addObjectsFromArray:scrollViewHConstraints];
    [self.scrollViewConstraints addObjectsFromArray:scrollViewVConstraints];
    
    [self addConstraints:self.scrollViewConstraints];
    
    // update view constraints
    CGFloat width = self.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right;
    CGFloat height = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    
    for (UIView *subView in self.scrollView.subviews) {
        for (NSLayoutConstraint *constraint in subView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                constraint.constant = width;
            } else if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = height;
            }
        }
    }
}

- (void)stopTimer
{
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
}

@end
