//
//  KSInvestHistoryVC.m
//  kaisafax
//
//  Created by Jjyo on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestHistoryVC.h"
#import "KSInvestHistoryCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSInvestAboutBL.h"
#import "KSInvestRecordEntity.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
@interface KSInvestHistoryVC ()<UITableViewDataSource, UITableViewDelegate, KSBLDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>


@property (nonatomic, strong) KSInvestAboutBL *investAboutBL;
@property (nonatomic, strong) KSInvestRecordEntity *recoredEntity;

@end

@implementation KSInvestHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _tableView.tableHeaderView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:kInvestHistoryCell bundle:nil] forCellReuseIdentifier:kInvestHistoryCell];

    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 0.1)];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    
    [self tableRefreshGif];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 刷新控件
- (void)tableRefreshGif
{
    // 添加动画图片的上拉刷新
    [self scrollView:_tableView headerRefreshAction:nil
                footerRefreshAction:@selector(loadingMore)];
}

-(void)loadingMore
{
//    if(!_investAboutBL)
//    {
//        _investAboutBL = [[KSInvestAboutBL alloc]init];
//        _investAboutBL.delegate = self;
//    }
    [_investAboutBL doGetNextPageInvestRecordByLoanId:_loanId];
}

- (void)setLoanId:(long long)loanId
{
    if (_loanId != loanId)
    {
        _loanId = loanId;
        [self investBLAction];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    INFO(@"====== WebView Frame > %@ ======", NSStringFromCGRect(self.view.bounds));
    INFO(@"--------");
}

#pragma mark - TableView DataSource & Delegate



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:kInvestHistoryCell cacheByIndexPath:indexPath configuration:^(KSInvestHistoryCell *cell) {
        KSInvestRecordItemEntity *entity = _recoredEntity.investData[indexPath.row];
        [cell updateItem:entity];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recoredEntity.investData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSInvestRecordItemEntity *entity = _recoredEntity.investData[indexPath.row];
    KSInvestHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kInvestHistoryCell];
    [cell updateItem:entity];
    return cell;
}

#pragma mark -  DZNEmptyDataSet

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = KInvestHistoryNone;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:24.0f],
                                 NSForegroundColorAttributeName: NUI_HELPER.appLightGrayColor};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    // Do something
    [self investBLAction];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    if (self.isHUDShowing) {
        return NO;
    }
    return YES;
}


#pragma mark - BL 

- (void)investBLAction
{
    [self showProgressHUD];
    [self.tableView reloadEmptyDataSet];
    [self.tableView.mj_footer endRefreshing];

    if(!_investAboutBL)
    {
        _investAboutBL = [[KSInvestAboutBL alloc]init];
        _investAboutBL.delegate = self;
    }
    [_investAboutBL doGetInvestRecordByLoanId:_loanId];
}

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self hideProgressHUD];
    [self.tableView reloadEmptyDataSet];
    [self.tableView.mj_footer endRefreshing];

    id entity = result.body;
    if ([entity isKindOfClass:[KSInvestRecordEntity class]]) {
        self.recoredEntity = entity;
        [self.tableView reloadData];
    }
    INFO(@"finishedHandle result = %@", NSStringFromClass([entity class]));
}


- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [self.tableView reloadEmptyDataSet];
    [self.tableView.mj_footer endRefreshing];

}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [self.tableView reloadEmptyDataSet];
    [self.tableView.mj_footer endRefreshing];

}



@end
