//
//  KSAccountInvestView.m
//  kaisafax
//
//  Created by okline.kwan on 16/12/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInvestView.h"
#import "EasyTableView.h"
#import "KSInvestListCell.h"
#import "KSLoanItemEntity.h"
#import "UITableView+FDTemplateLayoutCell.h"

#define kCellMargin 8
#define kRadius 5

@interface KSAccountInvestView ()<EasyTableViewDelegate>
@property (nonatomic, strong) EasyTableView *horizontalView;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, assign) NSUInteger currentPage;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) UIView *spareView;
@property (nonatomic, strong) UIPageControl *sparePageControl;

@end


@implementation KSAccountInvestView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    if (!_contentView) {
        _spareView = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_spareView];
        _contentView = _spareView;
    }
    
    self.horizontalView	= [[EasyTableView alloc] initWithFrame:_contentView.bounds ofWidth:CGRectGetWidth(_contentView.frame)];
    [_horizontalView.tableView registerNib:[UINib nibWithNibName:kInvestListCell bundle:nil] forCellReuseIdentifier:kInvestListCell];
    _horizontalView.tableView.backgroundColor = [UIColor clearColor];
    _horizontalView.backgroundColor = [UIColor clearColor];
    _horizontalView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _horizontalView.tableView.showsHorizontalScrollIndicator = NO;
    _horizontalView.tableView.showsVerticalScrollIndicator = NO;
    _horizontalView.tableView.pagingEnabled = YES;
    _horizontalView.delegate = self;
    
    [_contentView addSubview:_horizontalView];
    
    
    if (!_pageControl) {
        CGFloat height = 28;
        CGRect frame = CGRectMake(0, CGRectGetHeight(self.bounds) - height, CGRectGetWidth(self.bounds), height);
        _sparePageControl = [[UIPageControl alloc]initWithFrame:frame];
        [_contentView addSubview:_sparePageControl];
        _pageControl = _sparePageControl;
    }
    
    _pageControl.pageIndicatorTintColor = NUI_HELPER.appLightGrayColor;
    _pageControl.currentPageIndicatorTintColor = NUI_HELPER.appOrangeColor;
    
}

- (void)updatePageInPoint:(CGPoint)point
{
    NSInteger page = point.y / CGRectGetWidth(self.contentView.frame);
    if (!_horizontalView.tableView.dragging && !!_horizontalView.tableView.tracking &&  page != _currentPage) {
        //因为easyTable作了旋转..导致字体无法及法更新..所以这里强制更新一遍
        [self reloadPage:page];
    }
    //_pageControl.currentPage = page;
    
}


- (void)reloadPage:(NSInteger)page
{
    [NSObject cancelPreviousPerformRequestsWithTarget:_horizontalView selector:@selector(reload) object:nil];
    [_horizontalView performSelector:@selector(reload) withObject:nil afterDelay:0.1];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_spareView) {
        _contentView.frame = self.bounds;
    }
    _horizontalView.frame = _contentView.frame;
    
}


- (NSArray *)copyArray:(NSArray *)loanItemList
{
    NSMutableArray *array = [NSMutableArray array];
    for (KSLoanItemEntity *entity in loanItemList) {
        KSLoanItemEntity *copy = [entity yy_modelCopy];
        [array addObject:copy];
    }
    return array;
}


- (void)setLoanItemList:(NSArray *)loanItemList
{
    //添加3倍数据, 做无限循环
    if (loanItemList.count > 1) {
         NSMutableArray *array = [NSMutableArray array];
        [array addObjectsFromArray:loanItemList];
        [array addObjectsFromArray:loanItemList];
        [array addObjectsFromArray:loanItemList];
        _loanItemList = array;
    }else{
        _loanItemList = loanItemList;
    }
    _pageControl.numberOfPages = loanItemList.count;
    _pageControl.hidden = loanItemList.count <= 1;
    
    [_horizontalView reload];
    //移动到中间行
    if (loanItemList.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:loanItemList.count inSection:0];
        [_horizontalView.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    if (loanItemList.count > 0) {
        [self reloadPage:0];
    }
}



#pragma mark - EasyTableView

- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSLoanItemEntity *entity = _loanItemList[indexPath.row];
    KSInvestListCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:kInvestListCell];
    cell.backgroundImageView.hidden = NO;
    [cell updateItem:entity busssiness:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell tableView:easyTableView.tableView setCornerRaduis:20 byRoundType:KSCellRoundCornerTypeAll inLayoutMargins:UIEdgeInsetsMake(kCellMargin,0, kCellMargin, 0)];
    if (_rowHeight == 0) {
        CGFloat height = [easyTableView.tableView fd_heightForCellWithIdentifier:kInvestListCell cacheByIndexPath:indexPath configuration:^(KSInvestListCell *cell) {
            cell.backgroundImageView.hidden = NO;
            [cell updateItem:entity busssiness:YES];
        }];
        
        if (_rowHeight != height) {
            self.rowHeight = height;
            if ([_delegate respondsToSelector:@selector(investView:updateHeight:)]) {
                [_delegate investView:self updateHeight:_rowHeight];
            }
        }
    }
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.durationLabel.textColor = [UIColor whiteColor];
    cell.repayLabel.textColor = [UIColor whiteColor];
    cell.topLineView.backgroundColor = UIColorFromHex(0x5c5c65);
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView {
    return 1;
}

- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section {
    return _loanItemList.count;
}

- (CGFloat)easyTableView:(EasyTableView *)easyTableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetWidth(_contentView.frame);
}

- (void)easyTableView:(EasyTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(investView:didSelectEntity:)]) {
        KSLoanItemEntity *entity = _loanItemList[indexPath.row];
        [_delegate investView:self didSelectEntity:entity];
    }
    
}

- (void)easyTableViewDidEndDecelerating:(EasyTableView *)easyTableView
{
    if (_pageControl.numberOfPages > 1) {
        CGFloat pageWidth = CGRectGetWidth(easyTableView.frame);
        NSUInteger page = floor((easyTableView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        //DEBUGG(@"easyTableViewDid page = %ld", page);
        
        CGPoint offset = easyTableView.contentOffset;
        if (page == 0) {
            offset.x = _pageControl.numberOfPages * pageWidth;
            [easyTableView setContentOffset:offset];
        }
        else if (page == _loanItemList.count - 1)
        {
            offset.x = (_loanItemList.count - _pageControl.numberOfPages - 1) * pageWidth;
            [easyTableView setContentOffset:offset];
        }
        
        page = floor((easyTableView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _pageControl.currentPage = page % _pageControl.numberOfPages;
    }
}

- (void)easyTableViewDidScroll:(EasyTableView *)easyTableView
{
    if (_pageControl.numberOfPages > 1) {
        CGFloat pageWidth = CGRectGetWidth(easyTableView.frame);
        NSUInteger page = floor((easyTableView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        page = page % _pageControl.numberOfPages;
        if (_pageControl.currentPage != page) {
            [_horizontalView reload];
        }
        _pageControl.currentPage = page;
    }
}


@end
