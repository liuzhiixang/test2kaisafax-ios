//
//  KSNewAssetsVC.m
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNewAssetsVC.h"
#import "XYPieChart.h"
#import "KSAssetsBL.h"
#import "UIView+Round.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface KSNewAssetsVC ()<XYPieChartDelegate,XYPieChartDataSource,KSBLDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

//外层圆圈
@property (weak, nonatomic) IBOutlet UIView *chartContentView;
//内层圆圈背景
@property (weak, nonatomic) IBOutlet UIView *chartCenterView;
//内层圆圈
@property (weak, nonatomic) IBOutlet UIView *chartCenterCircleView;
//饼状统计图
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;
//饼状统计图内部总金额
@property (weak, nonatomic) IBOutlet UILabel *totalFundLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFundTitleLabel;

//统计参数
//资产明细类型数量
@property (assign, nonatomic) NSInteger fundTypeCount;
//统计图颜色列表
@property (strong, nonatomic) NSArray *fundTypeColors;

//资产信息接口
@property (strong, nonatomic) KSAssetsBL *assetsBL;

@end

@implementation KSNewAssetsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    
    //去掉底部间隔线
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 1.0f)];
    footerView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = footerView;
  
    //颜色
    [self initTypeColors];
    //初始化饼状图
    [self initPieChartView];
    //顶部视图
    [self initHeaderView];
    DEBUGG(@"%s %@", __FUNCTION__, self.userAssets);
    //更新当前数据
    [self updateViewInfoWith:self.userAssets];
    //刷新拉取数据
    [self refreshing];
    //初始化下拉刷新的操作
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //画圈圈
    [self initCircleBorder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DEBUGG(@"%s, %@", __FUNCTION__, self.tableView);
}

//- (BOOL)transparentNavigationBar
//{
//    return YES;
//}

#pragma mark -------------视图初始化-------------
- (void)configNav
{
    //标题
    [self setNavTitleByText:KAssetTitle];
    
//    [self setExtensionWithJudger:NO];
    
    
//     self.edgesForExtendedLayout = UIRectEdgeNone;
//    UIColor *color = self.navigationController.navigationBar.barTintColor;
//    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
//    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
}

//整个顶部视图的尺寸
- (void)initHeaderView
{
    static const CGFloat wh = 3/2.f;
    CGSize mainSize = MAIN_BOUNDS.size;
    CGRect frame = self.headerView.frame;
    CGFloat width = mainSize.width;
    CGFloat height = width/wh;
    frame.size.height = height;
    self.headerView.frame = frame;
    [self.headerView layoutIfNeeded];
    //计算顶部视图的高度
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.separatorColor = UIColorFromHex(0xEBEBEB);
    //金额标题
    self.totalFundTitleLabel.text = KTotalAssetTitle;
    
    //空的情况
//    self.tableView.emptyDataSetSource = self;
//    self.tableView.emptyDataSetDelegate = self;
}

//饼状图
- (void)initPieChartView
{
    [self.pieChartView setDataSource:self];
    [self.pieChartView setDelegate:self];
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setUserInteractionEnabled:NO];
    [self.pieChartView setBackgroundColor:[UIColor clearColor]];
    [self.pieChartView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(self.pieChartView.frame)/2.0f];
}

//画圈圈
- (void)initCircleBorder
{
    //外层圈圈
    [self.chartContentView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(self.chartContentView.frame)/2.0f];
//    self.chartContentView.layer.borderColor = UIColorFromHexA(0xffffff, 0.06f).CGColor;
//    self.chartContentView.layer.borderWidth = 1.0f;
    //内层圈圈背景
    [self.chartCenterView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(self.chartCenterView.frame)/2.0f];
    //内层圈圈
    [self.chartCenterCircleView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(self.chartCenterCircleView.frame)/2.0f];
//    self.chartCenterCircleView.layer.borderColor = UIColorFromHexA(0xffffff, 0.06f).CGColor;
//    self.chartCenterCircleView.layer.borderWidth = 1.0f;
}

//奖励类型统计图颜色
- (void)initTypeColors
{
    //    @appChartOrangeColor:#fe9044;   /*统计图橙色 */
    //    @appChartRedColor:#f15c5c;   /*统计图红色 */
    //    @appChartBlueColor:#44a4fe;   /*统计图蓝色 */
    //    @appChartGreenColor:#14c8b1;   /*统计图绿色 */
    self.fundTypeColors = [NSArray arrayWithObjects:UIColorFromHex(0xfe9044),UIColorFromHex(0xf15c5c),UIColorFromHex(0x44a4fe),UIColorFromHex(0x14c8b1),nil];
}

#pragma mark ------内部操作方法-----------
//刷新奖励数据
-(void)refreshing
{
    if (!_assetsBL)
    {
        _assetsBL = [[KSAssetsBL alloc] init];
        _assetsBL.delegate = self;
    }
    //获取资产明细
    [_assetsBL doGetUserNewAssets];
}

#pragma mark -------刷新当前视图----------
- (void)updateViewInfoWith:(KSNewAssetsEntity *)assets
{
    DEBUGG(@"%s %@", __FUNCTION__, self.userAssets);
    //奖励信息相关数据(页面)
    [self updateAssetsData:assets];
    
    //更新相关视图
    [self updateRewardChart];
    [self updateRewardDetail];
}

//更新顶部视图
- (void)updateRewardChart
{
    //刷新顶部饼状图
    [self.pieChartView reloadData];
    NSString *totalAssets = self.userAssets.totalAssetFormat;
    if (!totalAssets || totalAssets.length <= 0)
    {
        totalAssets = @"0.00";
    }
    //总金额信息
    self.totalFundLabel.text = totalAssets;
}

//更新可提取奖励明细
- (void)updateRewardDetail
{
    DEBUGG(@"%s %@", __FUNCTION__, self.userAssets);
//    NSString *totalAssets = self.userAssets.totalAssetFormat;
//    if (!totalAssets || totalAssets.length <= 0)
//    {
//        [self.tableView reloadEmptyDataSet];
//        return;
//    }
//    else
//    {
//        BOOL flag = [KSBaseEntity isValue1:totalAssets greaterValue2:@"0"];
//        if (!flag)
//        {
//            [self.tableView reloadEmptyDataSet];
//            return;
//        }
//    }
    
    //正常情况
    [self.tableView reloadData];
}

//更新可提取奖励相关数据
- (void)updateAssetsData:(KSNewAssetsEntity *)assets
{
    //本地数据
    self.userAssets = assets;
    
    //明细条数
    //NSArray *validRewardArray = validRewards.dataRatioArray;
    self.fundTypeCount = 4;//validRewardArray.count;
//    NSString *totalAssets = self.userAssets.totalAssetFormat;
//    if (!totalAssets || totalAssets.length <= 0)
//    {
//        self.fundTypeCount = 0;
//    }
//    else
//    {
//        BOOL flag = [KSBaseEntity isValue1:totalAssets greaterValue2:@"0"];
//        if (!flag)
//        {
//            self.fundTypeCount = 0;
//        }
//    }
}

#pragma mark ------饼状图代理-----------
- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    NSInteger count = self.fundTypeCount;
    if (count <= 0)
    {
        count = 1;
    }
    CGFloat ratio = 1.0f/count;
    
    NSString *totalAssets = self.userAssets.totalAssetFormat;
    if (!totalAssets || totalAssets.length <= 0)
    {
        totalAssets = @"0";
    }
    BOOL flag = [KSBaseEntity isValue1:totalAssets greaterValue2:@"0"];
    if (!self.userAssets.fund || !flag)
    {
        return ratio;
    }
    
    KSFundItemEntity *validAssetsItem = nil;
    switch (index) {
        case 0:
        {
            //可用余额
            validAssetsItem = self.userAssets.fund.available;
        }
        break;
        case 1:
        {
            //红包激活
            validAssetsItem = self.userAssets.fund.frozen;
        }
        break;
        case 2:
        {
            //待收本金
            validAssetsItem = self.userAssets.fund.fund;
        }
        break;
        case 3:
        {
            //待收利息
            validAssetsItem = self.userAssets.fund.accrual;
        }
        break;
        default:
        break;
    }
    
    ratio = validAssetsItem.ratio/100.00f;
    
    //默认的比例
    const static CGFloat KDefaultRation = 0.005f;
    if (ratio <= KDefaultRation)
    {
        ratio = KDefaultRation;
    }
    return ratio;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    UIColor *color = UIColor.lightGrayColor;
    if (index <= self.fundTypeColors.count)
    {
        color = self.fundTypeColors[index];
    }
    return color;
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    //奖励类型
    NSInteger count = self.fundTypeCount;
    return count;
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    DEBUGG(@"will select slice at index %ld",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    DEBUGG(@"will deselect slice at index %ld",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    DEBUGG(@"did deselect slice at index %ld",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    DEBUGG(@"did select slice at index %ld",(unsigned long)index);
}

#pragma mark ------UITableView------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.fundTypeCount;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellId];
    }
    //去掉选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0f);
    
    //数据填充
    NSInteger index = indexPath.row;
    KSFundItemEntity *validAssetsItem = nil;
    DEBUGG(@"%s %@", __FUNCTION__, indexPath);
    switch (index) {
        case 0:
        {
            //原点图标
            cell.imageView.image = UIImageFromName(@"ic_orange_dot");
            //奖励类型标题
            cell.textLabel.text = KAvailableBalanceTitle;
            //金额
            validAssetsItem = self.userAssets.fund.available;
        }
        break;
        case 1:
        {
            //原点图标
            cell.imageView.image = UIImageFromName(@"ic_red_dot");
            //奖励类型标题
            cell.textLabel.text = KFrozenBalanceTitle;
            //金额
            validAssetsItem = self.userAssets.fund.frozen;
        }
        break;
        case 2:
        {
            //原点图标
            cell.imageView.image = UIImageFromName(@"ic_blue_dot");
            //奖励类型标题
            cell.textLabel.text = KDueInFundTitle;
            //金额
            validAssetsItem = self.userAssets.fund.fund;
        }
        break;
        case 3:
        {
            //原点图标
            cell.imageView.image = UIImageFromName(@"ic_green_dot");
            //奖励类型标题
            cell.textLabel.text = KDueInInterestTitle;
            //金额
            validAssetsItem = self.userAssets.fund.accrual;
        }
        break;
        default:
        break;
    }
    
    //奖励类型标题样式
    cell.textLabel.nuiClass = NUIAppNormalDarkGrayLabel; 
    //奖励金额
    cell.detailTextLabel.nuiClass = NUIAppNormalLightGrayLabel;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSString *money = [NSString stringWithFormat:@"0.00%@", KUnit];
    NSString *validAssetsStr = validAssetsItem.moneyFormat;
    if (validAssetsStr && validAssetsStr.length > 0)
    {
        money = validAssetsStr;
    }
    cell.detailTextLabel.text = money;
    
    return cell;
}

#pragma mark -------数据为空的显示-------------
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    UIImage *webNoNetworkImg = [UIImage imageNamed:@"web_no_network"];
    return webNoNetworkImg;
}

#pragma mark -
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    NSString *tradeId = result.tradeId;
    //资产明细
    if ([tradeId isEqualToString:KUserNewAssetsTradeId])
    {
        [self.tableView.mj_header endRefreshing];
        [self hideProgressHUD];
        
        id entity = result.body;
        if ([entity isKindOfClass:[KSNewAssetsEntity class]])
        {
            DEBUGG(@"%s %@", __FUNCTION__, self.userAssets);
            //更新当前数据
            [self updateViewInfoWith:entity];
        }
    }
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self.tableView.mj_header endRefreshing];
    [self hideProgressHUD];
    
    NSString *errorMsg = result.errorDescription;
    if (!errorMsg || errorMsg.length <= 0)
    {
        errorMsg = KGetAssetDetailErrorMessage;
    }
    
    [self.view makeToast:errorMsg duration:2.0 position:CSToastPositionCenter];
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self.tableView.mj_header endRefreshing];
    [self hideProgressHUD];
    [self.view makeToast:KRequestNetworkErrorMessage duration:2.0 position:CSToastPositionCenter];
}

@end
