//
//  KSPromoteVC.m
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPromoteVC.h"
#import "KSPromoteCell.h"
#import "KSPromoteEntity.h"
#import "KSPromoteBL.h"
#import "KSInviteListBL.h"
#import "KSInviteUserEntity.h"
#import "KSPromoteStatEntity.h"
#import "KSWebVC.h"
#import "XYPieChart.h"
#import "SocialService.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIView+Round.h"
#import "KSNValidRewardVC.h"
#import "KSUserMgr.h"
#import "KSBInviteUserListEntity.h"
#import "Masonry.h"
#import "KSFilterUtils.h"
#import "KSFileUtil.h"

@interface KSPromoteVC ()<UITableViewDataSource, UITableViewDelegate, KSBLDelegate, XYPieChartDelegate, XYPieChartDataSource , DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,SocialDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *empLabel;
//开户
@property (weak, nonatomic) IBOutlet UILabel *r1oLabel;
@property (weak, nonatomic) IBOutlet UILabel *r2oLabel;
@property (weak, nonatomic) IBOutlet UILabel *r3oLabel;
//投资
@property (weak, nonatomic) IBOutlet UILabel *r1iLabel;
@property (weak, nonatomic) IBOutlet UILabel *r2iLabel;
@property (weak, nonatomic) IBOutlet UILabel *r3iLabel;
//收益
@property (weak, nonatomic) IBOutlet UILabel *c1Label;
@property (weak, nonatomic) IBOutlet UILabel *c2Label;
@property (weak, nonatomic) IBOutlet UILabel *c3Label;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *gradleLabel;//等级
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

//累计收益
@property (weak, nonatomic) IBOutlet UILabel *totalCommissionLabel;
//审核中的已提取推广收益
@property (weak, nonatomic) IBOutlet UILabel *invokedCommissionLabel;
//可取推广收益
@property (weak, nonatomic) IBOutlet UILabel *confirmedCommissionLabel;
@property (weak, nonatomic) IBOutlet UIView *confirmedCommissionColorView;
//已结算推广收益
@property (weak, nonatomic) IBOutlet UILabel *payedCommissionLabel;
@property (weak, nonatomic) IBOutlet UIView *payedCommissionColorView;
//结算中推广收益
@property (weak, nonatomic) IBOutlet UILabel *intCommissionLabel;
@property (weak, nonatomic) IBOutlet UIView *intCommissionColorView;

@property (weak, nonatomic) IBOutlet UIView *chartContentView;
@property (weak, nonatomic) IBOutlet UIView *chartCenterView;
@property (weak, nonatomic) IBOutlet UIView *gradleView;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;
@property (copy, nonatomic) NSArray *sliceColors;
//chart


@property (strong, nonatomic) KSPromoteBL *promoteBL;
@property (strong, nonatomic) KSPromoteEntity *promoteEntity;
@property (strong, nonatomic) KSPromoteStatEntity *statEntity;
@property (strong, nonatomic) KSInviteListBL *inviteListBL;
@property (strong, nonatomic) KSBInviteUserListEntity *listData;
@property (weak, nonatomic) NSArray<KSInviteUserEntity *> *investUserArray;
@property (strong, nonatomic) UIButton *noneDataButton;

@property (nonatomic,weak) UIView *sepView;

@end

@implementation KSPromoteVC

- (NSArray*)investUserArray
{
    _investUserArray = _listData.dataList;
    return _investUserArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = KMyPromoteTitle;
    [_tableView registerNib:[UINib nibWithNibName:kPromoteCell bundle:nil] forCellReuseIdentifier:kPromoteCell];
//    _tableView.emptyDataSetSource = self;
//    _tableView.emptyDataSetDelegate = self;
    NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
    self.promoteEntity = [KSPromoteEntity yy_modelWithJSON:json];
    
    [self updatePromote];
    [self updateShareBtn];
    [self setNavRightButtonByText:@"推广规则" titleColor:UIColor.whiteColor imageName:nil selectedImageName:nil navBtnAction:@selector(promoteRuleAction:)];

    [self initPieChartView];
    
    //calc header view height
    CGFloat headerHeight  = [_headerView systemLayoutSizeFittingSize:MAIN_BOUNDS.size].height;
    CGRect frame = _headerView.frame;
    frame.size.height = headerHeight;
    _headerView.frame = frame;
    [_headerView layoutIfNeeded];
    self.tableView.tableHeaderView = _headerView;
    @WeakObj(self);
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
    
//    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        // 进入刷新状态后会自动调用这个block
//    }];
    
    
    _noneDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _noneDataButton.backgroundColor = [UIColor whiteColor];
    _noneDataButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100);
    [_noneDataButton setTitle:KNoPromoteRecordTitle forState:UIControlStateNormal];
    _noneDataButton.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [_noneDataButton setTitleColor:UIColorFromHex(0xa0a0a0) forState:UIControlStateNormal];
    [[_noneDataButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakself showProgressHUD];
        [weakself.inviteListBL refreshInviteList];
    }];
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(MAIN_BOUNDS), CGRectGetWidth(MAIN_BOUNDS), CGRectGetHeight(MAIN_BOUNDS))];
//    view.backgroundColor = UIColorFromHex(0x3e3e40);
//    [_tableView insertSubview:view atIndex:0];
    
    

    
    //     添加分隔线
    UIView *sepView = [[UIView alloc]init];
    sepView.tag = 1000;
    sepView.backgroundColor = UIColorFromHex(0xebebeb);
    [self.view addSubview:sepView];
    [sepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.shareButton.mas_top).offset(-8);
        make.height.equalTo(@0.5);
        make.left.equalTo(weakself.shareButton.mas_left).offset(-8);
        make.width.equalTo(@MAIN_BOUNDS_SCREEN_WIDTH);
    }];
    _sepView=sepView;
//    _sepView.hidden = YES;
    
}

- (void)refreshing
{
    [self requestAction];
}


- (void)loadingMore
{
    //加载更多
    [_inviteListBL requestNextPageInviteList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshing];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [_gradleView makeCorners:UIRectCornerTopRight|UIRectCornerBottomRight radius:CGRectGetHeight(_gradleView.frame) / 2];
    [_chartContentView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(_chartContentView.frame) / 2];
    [_chartCenterView makeCorners:UIRectCornerAllCorners radius:CGRectGetHeight(_chartCenterView.frame) / 2];
}


- (void)initPieChartView
{
    [self.pieChartView setDataSource:self];
    [self.pieChartView setDelegate:self];
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setUserInteractionEnabled:NO];

    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:70/255.0 green:201/255.0 blue:24/255.0 alpha:1],
                       [UIColor colorWithRed:45/255.0 green:129/255.0 blue:244/255.0 alpha:1],
                       [UIColor colorWithRed:247/255.0 green:191/255.0 blue:57/255.0 alpha:1],
                        [UIColor colorWithRed:97/255.0 green:97/255.0 blue:104/255.0 alpha:1],
                       [UIColor colorWithRed:97/255.0 green:97/255.0 blue:104/255.0 alpha:0.75],
                       nil];

    
    _confirmedCommissionColorView.backgroundColor = _sliceColors[0];
    
    _payedCommissionColorView.backgroundColor =_sliceColors[1];
    _intCommissionColorView.backgroundColor = _sliceColors[2];
    
    [self setShadowForView:_confirmedCommissionColorView];
    [self setShadowForView:_payedCommissionColorView];
    [self setShadowForView:_intCommissionColorView];
    
}

//设置阴影
- (void)setShadowForView:(UIView *)view
{
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShadowOpacity:0.8];
    [view.layer setShadowRadius:1.0];
    [view.layer setShadowColor:[[UIColor whiteColor] CGColor]];
 
}


#pragma mark - update ui

- (NSString *)getCacheFileName
{
    return [NSString stringWithFormat:@"%lld.promote.cache", USER_MGR.user.user.userId];
}

- (NSString *)stringFormatNumber:(NSInteger)num
{
    if (num == 0) {
        return @"0";
    }
    return [@(num) stringValue];
}
- (void)updateCommission
{
    _r1oLabel.text = [self stringFormatNumber: _statEntity.r1];
    _r2oLabel.text = [self stringFormatNumber:  _statEntity.r2];
    _r3oLabel.text = [self stringFormatNumber:  _statEntity.r1 + _statEntity.r2];
    
    _r1iLabel.text = [self stringFormatNumber:  _statEntity.r1i];
    _r2iLabel.text = [self stringFormatNumber:  _statEntity.r2i];
    _r3iLabel.text = [self stringFormatNumber:  _statEntity.r1i + _statEntity.r2i];
    
    //推广收益
    _c1Label.text = [KSBaseEntity formatAmount:_statEntity.r1ci.doubleValue];
    _c2Label.text = [KSBaseEntity formatAmount:_statEntity.r2ci.doubleValue];
    _c3Label.text = [KSBaseEntity formatAmount:_statEntity.r1ci.doubleValue  + _statEntity.r2ci.doubleValue];
    
   
    
}

#pragma mark -- decimal calculate
-(NSDecimalNumber *)unionDecimalsWithStr1:(NSString*)str1 Str2:(NSString*)str2
{
    NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:str1];
    NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:str2];
    NSDecimalNumber *uni =[dec1 decimalNumberByAdding:dec2];
    return uni;
}

-(NSString *)outputStringWithDecimalNumber:(NSDecimalNumber*)uni
{
    NSString *tempStr = nil;
    if(!uni)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    tempStr = [numberFormatter stringForObjectValue:uni];
    if (!tempStr) {
        tempStr = @"0.00";
    }
    return tempStr;
}

-(void)updateShareBtn
{
    //我的推广 接口重构（没有的数据）
    
    /*KSFilterUtils *utils = [KSFilterUtils sharedInstance];
    NSArray *platform = self.promoteEntity.platformType;
    NSArray *appVersions = self.promoteEntity.appVersions;
    NSArray *appChannels = self.promoteEntity.appChannels;
    NSString *status = self.promoteEntity.status;
    
    id obj = [utils pickupValidBanner:self.promoteEntity Platform:platform Versions:appVersions Channels:appChannels Status:status];
    
    if (obj)
    {
        _shareButton.enabled = YES;
    }
    else
    {
        _shareButton.enabled = NO;
    }*/
    _shareButton.enabled = YES;

   
}

- (void)updatePromote
{
    _gradleLabel.text =USER_MGR.user.user.refGradeStr;
    NSString *iconName = [USER_MGR.user.user getGradeIconName];
    _levelImageView.image = [UIImage imageNamed:iconName];
    _payedCommissionLabel.text = [KSBaseEntity formatAmount: _promoteEntity.payedCommission.doubleValue];

    _totalCommissionLabel.text = [self formatAmount:_promoteEntity.totalCommission.doubleValue];
//    _payedCommissionLabel.text = [KSBaseEntity formatAmount:_promoteEntity.payedCommission];
    //我的推广 接口重构（没有的数据）
    /*_confirmedCommissionLabel.text = [KSBaseEntity formatAmount:_promoteEntity.confirmedCommission.doubleValue ];*/
    
    _intCommissionLabel.text = [KSBaseEntity formatAmount:_promoteEntity.inItCommission.doubleValue];
//    _pieChartView.hidden = _promoteEntity.totalCommission == 0;
}


- (NSString *)formatAmount:(CGFloat)amount
{
    if (amount > 10000) {
        NSInteger value = amount / 1000;
        return [NSString stringWithFormat:@"%.1f万", value / 10.];
    }
    return [KSBaseEntity formatAmount:amount];
}


#pragma mark  - Action

- (void)promoteRuleAction:(id)sender
{
    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KCommissionRulesPage data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"推广规则"  type:KSWebSourceTypeAccount];
}

//可提取推广收益
- (IBAction)takeCommissionAction:(id)sender {
    
    KSNValidRewardVC *rewardVc = [[KSNValidRewardVC alloc]init];
    rewardVc.type = KSWebSourceTypeAccount;
    rewardVc.hidesBottomBarWhenPushed = YES;
//    rewardVc.userAssetsData = USER_MGR.assets;
    [self.navigationController pushViewController:rewardVc animated:YES];

}

- (IBAction)shareAction:(id)sender
{
    
    
    
    //分享
    SocialService *socialService = [SocialService sharedInstance];
    socialService.platformArray = @[SocialShareToWechatSession,SocialShareToWechatTimeline,SocialShareToQQ,SocialShareToQzone,SocialShareToSina,SocialShareToFaceToFace];
    //分享的数据
    NSString *title = _promoteEntity.shareInfo.title;
    NSString *content = _promoteEntity.shareInfo.content;
    NSString *url = _promoteEntity.shareInfo.url;
    NSString *imgUrl = _promoteEntity.shareInfo.image;
    NSData *data = nil;
    if (imgUrl && imgUrl.length > 0)
    {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    }
    [socialService presentShareDialogWithTitle:title text:content image:data imageURL:imgUrl URL:url delegate:self];
}

#pragma mark - SocialDelegate
- (void)willShowSocialDialog
{
    //将要显示分享框
    DEBUGG(@"%s", __FUNCTION__);
}

- (void)didSelectedSocialPlatform:(NSString *)platformName withSocialData:(SocialEntity *)socialData
{
    //选择了分享平台
    DEBUGG(@"%s", __FUNCTION__);
    if ([platformName isEqualToString:SocialShareToSina])
    {
        //新浪
        
    }
    else if ([platformName isEqualToString:SocialShareToQQ])
    {
        //QQ好友
        
    }
    else if ([platformName isEqualToString:SocialShareToQzone])
    {
        //QQ空间
    }
    else if ([platformName isEqualToString:SocialShareToWechatSession])
    {
        //微信朋友
    }
    else if ([platformName isEqualToString:SocialShareToWechatTimeline])
    {
        //微信朋友圈
    }
    else if ([platformName isEqualToString:SocialShareToFaceToFace])
    {
        //面对面
    }
}

- (void)didCancleSocialDialog
{
    //取消显示
    DEBUGG(@"%s", __FUNCTION__);
}

#pragma mark - TableView DataSource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:kPromoteCell cacheByIndexPath:indexPath configuration:^(KSPromoteCell *cell) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.investUserArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    KSInviteUserEntity *entity = nil;
    if (row >= 0 && row < self.investUserArray.count)
    {
       // entity = self.investUserArray[row];
    entity =[KSInviteUserEntity yy_modelWithJSON:self.investUserArray[row]];
    }
    KSPromoteCell *cell = [tableView dequeueReusableCellWithIdentifier:kPromoteCell];
    [cell updateItem:entity];
    return cell;
}

#pragma mark -  DZNEmptyDataSet
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;
{
    return YES;
}

//TODO 待仔细计算各种屏幕下的字体偏移
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    if (CGRectGetHeight(_tableView.tableHeaderView.frame) > CGRectGetHeight(self.view.frame)) {
        return CGRectGetHeight(_tableView.tableHeaderView.frame) + 20;
    }else{
        return CGRectGetHeight(_tableView.tableHeaderView.frame) /2 ;
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = KNoPromoteRecordTitle;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    if (_promoteEntity) {
        return 2;
    }
    return 0;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    CGFloat initCommission = [_promoteEntity.inItCommission floatValue];
    CGFloat payedCommission = [_promoteEntity.payedCommission floatValue];
    
    CGFloat total = initCommission + payedCommission;
    if (total > 0) {
        /*
         if (index == 0) {
         return _promoteEntity.confirmedCommission / _promoteEntity.totalCommission;
         }else
         */
        if(index == 0){
            return  payedCommission / total;
            
        }else if (index == 1){
            return initCommission / total;
        }
    }
    
    return 1/2.;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return _sliceColors[index+1];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
   DEBUGG(@"will select slice at index %ld",index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
   DEBUGG(@"will deselect slice at index %ld",index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
   DEBUGG(@"did deselect slice at index %ld",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
   DEBUGG(@"did select slice at index %ld",index);
}



#pragma Mark - BL & Delegate


- (void)requestAction
{
    if (!_promoteBL) {
        _promoteBL = [[KSPromoteBL alloc]init];
        _promoteBL.delegate = self;
    }
    [_promoteBL doGetPromoteInfo];
    [_promoteBL doGetPromoteIncomeInfo];
    
    if (!_inviteListBL) {
        _inviteListBL = [[KSInviteListBL alloc]init];
        _inviteListBL.delegate = self;
    }
    [_inviteListBL refreshInviteList];
}

#pragma mark -
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self hideProgressHUD];
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
   id entity = result.body;
    if ([entity isKindOfClass:[KSPromoteEntity class]]) {
        self.promoteEntity = entity;
        NSDictionary *json = [entity yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
        [self updatePromote];
        [self updateShareBtn];
        [self.pieChartView reloadData];
    }
    if ([entity isKindOfClass:[KSPromoteStatEntity class]]) {
        self.statEntity = entity;
        [self updateCommission];
    }
    if ([blEntity isKindOfClass:[KSInviteListBL class]]) {
        if ([entity isKindOfClass:[KSBInviteUserListEntity class]])
        {
            self.listData = entity;
            if (self.investUserArray.count == 0) {
                _tableView.tableFooterView = _noneDataButton;
            }else{
                _tableView.tableFooterView = nil;
            }
        }
        
        [self.tableView reloadData];
    }
    
    INFO(@"finishedHandle entity = %@", NSStringFromClass([entity class]));
}


- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [_tableView reloadData];
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}


- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [_tableView reloadData];
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}


@end
