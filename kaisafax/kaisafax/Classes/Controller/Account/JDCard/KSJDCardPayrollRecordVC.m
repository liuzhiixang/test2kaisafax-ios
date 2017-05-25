//
//  KSJDCardPayrollRecordVC.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardPayrollRecordVC.h"
#import "KSJDCardPayrollRecordCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "KSJDProvideListBL.h"
#import "KSJDProvideListEntity.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#define kCellReuseIdentifier @"KSJDCardPayrollRecordCell"


@interface KSJDCardPayrollRecordVC () <UITableViewDelegate, UITableViewDataSource, KSBLDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) KSJDProvideListBL *provideListBL;
@property (strong, nonatomic) KSJDProvideListEntity *listEntity;

@end

@implementation KSJDCardPayrollRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发放记录";
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0.1)];
    [_tableView registerNib:[UINib nibWithNibName:kCellReuseIdentifier bundle:nil] forCellReuseIdentifier:kCellReuseIdentifier];
    
    // 添加动画图片的下拉刷新
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
    
    _provideListBL = [[KSJDProvideListBL alloc]init];
    _provideListBL.delegate = self;
    //[_provideListBL refreshJDProvideList];
    
    [_tableView.mj_header beginRefreshing];
    
}


- (void)refreshing
{
    //请求首页信息
    [_provideListBL refreshJDProvideList];
}

- (void)loadingMore
{
    //请求首页信息
    [_provideListBL requestNextPageJDProvideList];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableView Delegate & DataResource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //TODO
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSJDRecordItemEntity  *entity;
    KSJDCardPayrollRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    if (_listEntity.list.count>0&&(_listEntity.list[indexPath.row]!=nil)) {
        entity = _listEntity.list[indexPath.row];
        [cell updateItem:entity];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //@WeakObj(self);
    KSJDRecordItemEntity  *entity = _listEntity.list[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:kCellReuseIdentifier configuration:^(KSJDCardPayrollRecordCell *cell) {
        [cell updateItem:entity];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listEntity.list.count;
}

#pragma mark -  DZNEmptyDataSet
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;
{
    return YES;
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"暂无发放记录";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:NUI_HELPER.appNormalFontSize],
                                 NSForegroundColorAttributeName: NUI_HELPER.appLightGrayColor};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"account_jd_no_card"];
}


#pragma mark - KSBLDelegate


- (void)didEndLoading
{
    [self hideProgressHUD];
    
    
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    [_tableView reloadData];
}

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{

    if ([result.body isKindOfClass:[KSJDProvideListEntity class]]) {
        KSJDProvideListEntity *entity = (KSJDProvideListEntity *)result.body;
        self.listEntity = entity;
        DEBUGG(@"entity count:%ld", entity.list.count);
    }
    
    [self didEndLoading];
}

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self didEndLoading];
    
    if (result.errorDescription) {
        [self showSimpleAlert:result.errorDescription];
    }
}

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self didEndLoading];
}
@end
