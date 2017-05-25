//
//  KSInvestVC.m
//  kaisafax
//
//  Created by semny on 16/7/6.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestVC.h"
#import "KSInvestDetailVC.h"
#import "KSInvestListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSInvestBL.h"
#import "KSStatusView.h"
#import "KSNewbeeEntity.h"
#import "JSONKit.h"
#import "KSUserMgr.h"
#import "KSFileUtil.h"
#import "KSBLoanListEntity.h"

#define CACHE_INVEST @"Invest.cache"
#define CACHE_NEWBEE @"newbee.cache"

#define kCellMargin 8
#define kRadius 5
#define HEIGHT_ZERO 0.01

@interface KSInvestVC () <UITableViewDelegate, UITableViewDataSource, KSBatchBLDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//投资列表请求BL
@property (strong, nonatomic) KSInvestBL *investBL;

@property (strong, nonatomic) KSNewbeeEntity *newbeeEntity;
//@property (strong, nonatomic) KSLoanListEntity *listEntity;
//@property (strong, nonatomic) NSArray<KSLoanItemEntity*> *loanList;

@property (strong, nonatomic) KSBLoanListEntity *loanList;
@property (weak, nonatomic) NSArray<KSLoanItemEntity*> *loanItemList;

@end


@implementation KSInvestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = KTabbarInvestTitle;
    
    self.tableView.estimatedRowHeight = 109;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerNib:[UINib nibWithNibName:kInvestListCell bundle:nil] forCellReuseIdentifier:kInvestListCell];

    //刷新动画及操作
    [self tableRefreshGif];

    //刷新数据
    [self refreshWithAnimation:YES];
    
    //增加KVO刷新逻辑
    [self addObserver];
    
    //缓存
    [self cacheDataInit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setFillContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加 KVO
- (void)addObserver
{
    @WeakObj(self);
    [RACObserve(USER_MGR, assets) subscribeNext:^(KSNewAssetsEntity *entity) {
        [weakself refreshWithAnimation:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView Delegate & DataSource


- (BOOL)isNewbeeSection:(NSInteger)section
{
    return section == 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kCellMargin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isNewbeeSection:section] && _newbeeEntity) {
        return kCellMargin;
    }
    return HEIGHT_ZERO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @WeakObj(self);
    return [tableView fd_heightForCellWithIdentifier:kInvestListCell cacheByIndexPath:indexPath configuration:^(KSInvestListCell *cell) {
        if ([weakself isNewbeeSection:indexPath.section])
        {
            cell.newbee = YES;
            DEBUGG(@"%s, section: %ld, loan: %@", __FUNCTION__, (long)indexPath.section, weakself.newbeeEntity.loan);
            [cell updateItem:weakself.newbeeEntity.loan];
        }else{
            NSInteger idx = indexPath.section - 1;
            if (idx < weakself.loanItemList.count) {
                KSLoanItemEntity *entity = weakself.loanItemList[idx];
//                DEBUGG(@"%s, section: %ld, loan: %@", __FUNCTION__, (long)indexPath.section, entity);
                cell.newbee = NO;
                [cell updateItem:entity];
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count = self.loanItemList.count;
    count += 1;//add one newbee entity
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //newbee entity
    if (section == 0 && !_newbeeEntity) {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSInvestListCell *cell = [tableView dequeueReusableCellWithIdentifier:kInvestListCell];
    [cell tableView:tableView setCornerRaduis:kRadius byRoundType:KSCellRoundCornerTypeAll inLayoutMargins:UIEdgeInsetsMake(0, kCellMargin, 0, kCellMargin)];
    //newbee entity
    if (indexPath.section == 0) {
        cell.newbee = YES;
        //DEBUGG(@"%s, section: %ld, loan: %@", __FUNCTION__, (long)indexPath.section, self.newbeeEntity.loanData);
        [cell updateItem:self.newbeeEntity.loan];
    }else{
        cell.newbee = NO;
        NSInteger idx = indexPath.section - 1;
        if (idx < self.loanItemList.count) {
            KSLoanItemEntity *entity = self.loanItemList[idx];
            //DEBUGG(@"%s, section: %ld, loan: %@", __FUNCTION__, (long)indexPath.section, entity);
            [cell updateItem:entity];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KSLoanItemEntity *entity = nil;
    if ([self isNewbeeSection:indexPath.section]) {
        entity = _newbeeEntity.loan;
    }else{
        NSInteger idx = indexPath.section - 1;
        if (idx < self.loanItemList.count) {
            entity = self.loanItemList[idx];
        }
    }
    
    
    KSInvestDetailVC *controller = [[KSInvestDetailVC alloc] initWithNibName:@"KSInvestDetailVC" bundle:nil];
    controller.hidesBottomBarWhenPushed = YES;
    controller.entity = entity;
    controller.nbEntity = _newbeeEntity;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 内部方法
/**
 *  设置列表加载刷新数据的图片
 */
- (void)tableRefreshGif
{
    // 添加动画图片的下拉刷新
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
}

/**
 *  @author semny
 *
 *  刷新操作
 *
 *  @param flag YES:支持动画；NO:不支持动画
 */
- (void)refreshWithAnimation:(BOOL)flag
{
    if (flag)
    {
        //支持下拉刷新动画
        [_tableView.mj_header beginRefreshing];
    }
    else
    {
        //无下拉刷新动画
        [self refreshing];
    }
}

/**
 *  @author semny
 *
 *  刷新当前页面数据
 */
- (void)refreshing
{
    if(!_investBL)
    {
        _investBL = [[KSInvestBL alloc] init];
        _investBL.batchDelegate = self;
    }
    //请求首页信息
    [_investBL refreshInvestList];
}

- (void)loadingMore
{
    //加载更多
    if(!_investBL)
    {
        _investBL = [[KSInvestBL alloc] init];
        _investBL.batchDelegate = self;
    }
    //请求首页信息
    [_investBL requestNextPageInvestList];
}

- (NSArray<KSLoanItemEntity *> *)loanItemList
{
    _loanItemList = (NSArray*) _loanList.dataList;
    return _loanItemList;
}

#pragma mark - KSBatchBLDelegate


- (void)finishBatchHandle:(KSBRequestBL *)blEntity
{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    [self reloadDataDelay];
}

- (void)finishBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result
{
    id entity = result.body;
    NSString *tradeId = result.tradeId;
    INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    
    if([tradeId isEqualToString:KInvestNewBeeTradeId])
    {
        //新手标
        self.newbeeEntity = entity;
//        _newbeeEntity.loanData.newbee = YES;
//        self.newbeeEntity.loan.amount = self.newbeeEntity.amount;
        
//        [self.newbeeEntity.loan calcCountdownTime];
        
        [self reloadDataDelay];
        
        NSDictionary *json = [entity yy_modelToJSONObject];
        [KSFileUtil saveFile:CACHE_NEWBEE data:json];
    }
    else if([tradeId isEqualToString:KInvestListTradeId])
    {
//        KSLoanListEntity *listEntity = (KSLoanListEntity *)result;
        self.loanList = entity;
        //其他投资
        [self reloadDataDelay];
        
        //cache data
        NSDictionary *json = [_loanList yy_modelToJSONObject];
        [KSFileUtil saveFile:CACHE_INVEST data:json];
    }
}

- (void)failedBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity*)result
{
//    [_tableView.mj_header endRefreshing];
    ERROR(@"failedBatchHandle %@", NSStringFromClass([blEntity class]));
}

- (void)sysErrorBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result
{
    //防止同一时间多次弹出
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayToastNetworkError) object:nil];
    [self performSelector:@selector(delayToastNetworkError) withObject:nil afterDelay:2];
}

- (void)failedBatchHandle:(KSBRequestBL *)blEntity
{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

- (void)delayToastNetworkError
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}


#pragma mark - Data Init

- (void)cacheDataInit
{
    NSDictionary *json = [KSFileUtil openFile:CACHE_INVEST];
    //self.listEntity = [KSLoanListEntity yy_modelWithJSON:json];
    self.loanList = [KSBLoanListEntity yy_modelWithJSON:json];
    
    json = [KSFileUtil openFile:CACHE_NEWBEE];
    if (!json) {
        //加载默认新手标数据
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_newbee" ofType:@"json"]];
        json = [data objectFromJSONData];
    }
    self.newbeeEntity = [KSNewbeeEntity yy_modelWithJSON:json];
    
    //隐藏已经购买的新手标
//    if (![_newbeeEntity.loanData isLoanOpen]) {
//        self.newbeeEntity = nil;
//    }
}


- (void)reloadData
{
    [_tableView reloadData];
}

- (void)reloadDataDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:.3];
}
@end
