//
//  KSHomeVC.m
//  kaisafax
//
//  Created by semny on 16/7/6.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSHomeVC.h"
#import "KSInvestHeaderView.h"
#import "KSInvestListCell.h"
#import "KSNewbeeCell.h"
//#import "KSAdvertCell.h"
#import "KSInvestOwnerCell.H"
#import "UITableView+FDTemplateLayoutCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UINavigationBar+Awesome.h"
//#import "JKPageView.h"
#import "KSHomeBL.h"
#import "UIView+Round.h"
#import <Masonry/Masonry.h>
#import "KSBannerEntity.h"
#import "KSBusinessEntity.h"
#import "KSNoticeEntity.h"
#import "KSHomeTogetherEntity.h"
#import "KSORLoanEntity.h"
#import "KSUserMgr.h"
#import "KSInvestDetailVC.h"
#import "KSWebVC.h"
#import "KSFileUtil.h"
#import "NSString+Format.h"
#import "JSONKit.h"
#import "KSOwnerLoanVC.h"
#import "KSOpenAccountVC.h"
#import "KSFilterUtils.h"
#import "SDCycleScrollView.h"
#import "KSVersionMgr.h"
#import "KSShareEntity.h"
#import "KSOpenAccountBL.h"

#define CACHE_NEWBEE @"newbee.cache"
#define CACHE_HOME_TOGETHER @"homeTogether.cache"
#define CACHE_OR_LOAN   @"ORLoan.cache"

#define kCellMargin 8
#define kRadius 5
#define HEIGHT_ZERO 0.01
//#define kActivityType  9999
#define kNoticeHeight  36. //通知栏的高度
#define kBannerRatio 350/750. //banner的宽高比
#define kBussiseRatio 720/166.
#define kNoticeNum  3

typedef NS_ENUM(NSInteger, KSSectionType) {
    KSSectionTypeHeader = 0,
    KSSectionTypeNewbee,
    KSSectionTypeAdvert,
    KSSectionTypeInvestList,
    KSSectionTypeInvestOwner,
    KSSectionTypeTotal,//最大类型值
};

typedef NS_ENUM(NSInteger, KSFilterType) {
    KSFilterTypeBanner = 0,
    KSFilterTypeNotice,
    KSFilterTypeBusiness,
    KSFilterTypeTotal,//最大类型值
};


@interface KSHomeVC ()<UITableViewDelegate, UITableViewDataSource, /*JKPageViewDelegate,*/ KSBatchBLDelegate, SDCycleScrollViewDelegate>
{
    CGFloat _headerViewHeight;
    CGFloat _adsCellHeight;
    BOOL _netRefleshing;//网络刷新中...
    
    BOOL _isInit;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noticeViewHeightConstraint;

@property (weak, nonatomic) IBOutlet SDCycleScrollView *bannerPlayerView;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *noticePlayerView;
@property (strong, nonatomic) SDCycleScrollView *businessPlayerView;
@property (strong, nonatomic) UIView *businessHeaderView;

@property (strong, nonatomic) UIView *headerView;
@property (assign, nonatomic) CGSize bannerSize;

//首页请求数据BL
@property (strong, nonatomic) KSHomeBL *homeRequestBL;

//新手标
@property (strong, nonatomic) KSNewbeeEntity *newbeeEntity;
//轮播图
@property (strong, nonatomic) KSBannerEntity *bannerEntity;
//广告图
@property (strong, nonatomic) KSBusinessEntity *businessEntity;

//公告
@property (strong, nonatomic) KSNoticeEntity *noticeEntity;
@property (nonatomic,assign) BOOL needShowNotice;

//推荐标/定期理财
//@property (strong, nonatomic) KSRecomLoanEntity *recomEntity;
@property (nonatomic, strong) KSRecommendDataEntity *recommendData;
//物业宝
@property (nonatomic, strong) NSArray<KSOwnerLoanItemEntity *> *ownerLoansData;

//是否需要刷新动画标志(login)
@property (nonatomic, assign) BOOL needRefreshAnimation1;
//是否需要刷新动画标志(ad check)
@property (nonatomic, assign) BOOL needRefreshAnimation2;

@end

@implementation KSHomeVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.needRefreshAnimation1 = YES;
        self.needRefreshAnimation2 = YES;
        @WeakObj(self);
        //登录启动之前的通知
        [[NOTIFY_CENTER rac_addObserverForName:KBeforePageBeginAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageBeginAnimationNotificationKey111", __FUNCTION__);
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView.mj_footer endRefreshing];
            weakself.needRefreshAnimation1 = NO;
        }];
        [[NOTIFY_CENTER rac_addObserverForName:KAfterPageCloseAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageCloseAnimationNotificationKey", __FUNCTION__);
            weakself.needRefreshAnimation1 = YES;
        }];
        
        //登录AD check之前的通知
        [[NOTIFY_CENTER rac_addObserverForName:KBeforePageBeginAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageBeginAnimationNotificationKey222", __FUNCTION__);
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView.mj_footer endRefreshing];
            weakself.needRefreshAnimation2 = NO;
        }];
        [[NOTIFY_CENTER rac_addObserverForName:KAfterPageCloseAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageCloseAnimationNotificationKey", __FUNCTION__);
            weakself.needRefreshAnimation2 = YES;
        }];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.needRefreshAnimation1 = YES;
        self.needRefreshAnimation2 = YES;
        @WeakObj(self);
        //登录启动之前的通知
        [[NOTIFY_CENTER rac_addObserverForName:KLoginPageBeginAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageBeginAnimationNotificationKey222", __FUNCTION__);
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView.mj_footer endRefreshing];
            weakself.needRefreshAnimation1 = NO;
        }];
        [[NOTIFY_CENTER rac_addObserverForName:KLoginPageCloseAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageCloseAnimationNotificationKey", __FUNCTION__);
            weakself.needRefreshAnimation1 = YES;
        }];
        //登录AD check之前的通知
        [[NOTIFY_CENTER rac_addObserverForName:KBeforePageBeginAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageBeginAnimationNotificationKey222", __FUNCTION__);
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView.mj_footer endRefreshing];
            weakself.needRefreshAnimation2 = NO;
        }];
        [[NOTIFY_CENTER rac_addObserverForName:KAfterPageCloseAnimationNotificationKey object:nil] subscribeNext:^(id x) {
            DEBUGG(@"%s KLoginPageCloseAnimationNotificationKey", __FUNCTION__);
            weakself.needRefreshAnimation2 = YES;
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //检测更新
    [[KSVersionMgr sharedInstance] doCheckUpdate];
    
    [self cacheDataInit];
    
#ifndef __ONLINE__
    [self showToastWithTitle:SX_HOST];
#endif
    KSInvestHeaderView *headerView = ViewFromNib(kInvestHeaderView, 0);
    _headerViewHeight = [headerView getPerfectHeightFittingSize:self.view.frame.size] + kCellMargin;
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-64, 0, 0, 0);
    self.tableView.estimatedRowHeight = 109;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerNib:[UINib nibWithNibName:kInvestListCell bundle:nil] forCellReuseIdentifier:kInvestListCell];
    [_tableView registerNib:[UINib nibWithNibName:kInvestHeaderView bundle:nil] forHeaderFooterViewReuseIdentifier:kInvestHeaderView];
    [_tableView registerNib:[UINib nibWithNibName:kNewbeeCell bundle:nil] forCellReuseIdentifier:kNewbeeCell];
    //[_tableView registerNib:[UINib nibWithNibName:kAdvertCell bundle:nil] forCellReuseIdentifier:kAdvertCell];
    [_tableView registerNib:[UINib nibWithNibName:kInvestOwnerCell bundle:nil] forCellReuseIdentifier:kInvestOwnerCell];
    
    self.headerView = self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, HEIGHT_ZERO)];
    
    
    UILabel *footerLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    footerLable.text = KHomeFooterLabel;
    footerLable.textAlignment = NSTextAlignmentCenter;
    footerLable.nuiClass = NUIAppSmallLightGrayLabel;
    self.tableView.tableFooterView = footerLable;
    
    [self initNoticePlayerView];
    [self initBannerPlayerView];
    [self initBusinessHeaderView];
    
    //刷新动画及操作
    [self tableRefreshGif];
    
    //增加监听事件
    [self addObserver];
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

- (BOOL)transparentNavigationBar
{
    return YES;
}

#pragma mark ------内部方法-----------

//添加 KVO
- (void)addObserver
{
    DEBUGG(@"%s", __FUNCTION__);
    
    @WeakObj(self);
    [RACObserve(USER_MGR, user) subscribeNext:^(KSUserInfoEntity *entity) {
        DEBUGG(@"%s user", __FUNCTION__);
        if (USER_MGR.isLogin)
        {
            weakself.needRefreshAnimation1 = YES;
        }
        [weakself refreshWithAnimation:YES];
    }];
    
    [RACObserve(USER_MGR, assets) subscribeNext:^(KSNewAssetsEntity *entity) {
        DEBUGG(@"%s assets", __FUNCTION__);
        [weakself refreshWithAnimation:YES];
    }];
    
    //业主认证成功刷新
    [[NOTIFY_CENTER rac_addObserverForName:KOwnerAuthenticateSuccessNotificationKey object:nil] subscribeNext:^(id x) {
        DEBUGG(@"%s KOwnerAuthenticateSuccessNotificationKey", __FUNCTION__);
        [weakself refreshWithAnimation:YES];
    }];
}

- (void)initBannerPlayerView
{
    _bannerSize = CGSizeMake(750, 350);//banner默认尺寸
    _bannerPlayerView.delegate = self;
    _bannerPlayerView.autoScrollTimeInterval = 7;
    [_bannerPlayerView setAutoScroll:YES];
    _bannerPlayerView.placeholderImage = [UIImage imageNamed:@"bg_banner_default"];
    
}
    
    
- (void)initBusinessPlayerView
{
    _businessPlayerView = [[SDCycleScrollView alloc]init];
    _businessPlayerView.delegate = self;
    _businessPlayerView.autoScrollTimeInterval = 15;
    _businessPlayerView.pageDotColor = NUI_HELPER.appLightGrayColor;
    _businessPlayerView.currentPageDotColor = NUI_HELPER.appOrangeColor;
    [_businessPlayerView setAutoScroll:YES];
    //默认图
    _businessPlayerView.placeholderImage = [UIImage imageNamed:@"bg_business_default"];
}


- (void)initNoticePlayerView
{
    _noticePlayerView.delegate = self;
    _noticePlayerView.autoScrollTimeInterval = 10;
    _noticePlayerView.backgroundColor =[UIColor clearColor];
    _noticePlayerView.titleLabelBackgroundColor = [UIColor clearColor];
    _noticePlayerView.onlyDisplayText = YES;
    _noticePlayerView.titleLabelHeight = kNoticeHeight;
    _noticePlayerView.titleLabelTextFont = [UIFont systemFontOfSize:NUI_HELPER.appSmallFontSize];
    _noticePlayerView.titleLabelTextColor = NUI_HELPER.appLightGrayColor;
    _noticePlayerView.scrollDirection = UICollectionViewScrollDirectionVertical;
    [_noticePlayerView setAutoScroll:YES];
//    [_noticePlayerView reloadData];
}

- (void)initBusinessHeaderView
{
    [self initBusinessPlayerView];
    UIView *view = [UIView new];
    view.clipsToBounds = YES;
    [view addSubview:_businessPlayerView];
    self.businessHeaderView = view;
}

#pragma mark - action


- (void)newbeeInvestAction:(id)sender
{
    KSInvestDetailVC *vc = [[KSInvestDetailVC alloc]initWithNibName:@"KSInvestDetailVC" bundle:nil];
    vc.entity = _newbeeEntity.loan;
    vc.nbEntity = _newbeeEntity;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)execBussinessItemEntity:(KSBussinessItemEntity *)entity
{
    if(!entity)
        return;
    
    [self jumpToRelativeUrl:entity];

}

-(void)jumpToRelativeUrl:(KSBussinessItemEntity *)entity
{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (entity && entity.shareStatus)
    {
        if (entity.shareInfo)
        {
            dict[kShareStatus] = [NSNumber numberWithBool:entity.shareStatus];
            dict[kShareTitle] = entity.shareInfo.title;
            dict[kShareURL] = entity.shareInfo.url;
            dict[kShareImage] = entity.shareInfo.image;
            dict[kShareContent] = entity.shareInfo.content;
        }

    }
    
    /**
     *  @author semny
     *
     *  调整了webvc的跳转逻辑，增加了syncSessionFlag标记设置
     */
    //不存在url问号后的字符串或者url问号后的字符串不包含needtologin，直接跳转web页面
    
//    KSWebVC *webVC = nil;
    NSString *webTitle = entity.title;
    
    BOOL needToLogin = entity.needToLogin;
    if (needToLogin)
    {
        //判断登录态
        BOOL flag = [USER_MGR judgeLoginForVC:self.navigationController.tabBarController];
        if (!flag)
        {
            return;
        }
    }
    
    NSString *urlStr = nil;
    NSString *tradeId = KBannerAndAdvertiseTradeId;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[kIdKey] = @(entity.ID);
    
    urlStr = [KSRequestBL createGetRequestURLWithTradeId:tradeId data:data error:nil];

    if (!entity.shareStatus)
    {
//        webVC = [[KSWebVC alloc] initWithUrl:urlStr title:webTitle type:KSWebSourceTypeHome];
        [KSWebVC pushInController:self.navigationController urlString:urlStr title:webTitle type:KSWebSourceTypeHome];
    }
    else
    {
//        webVC = [[KSWebVC alloc] initWithUrl:urlStr title:webTitle params:dict type:KSWebSourceTypeHome];
        [KSWebVC pushInController:self.navigationController urlString:urlStr title:webTitle params:dict type:KSWebSourceTypeHome];
    }
//    webVC.syncSessionFlag = YES;
//    webVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:webVC animated:YES];
    
}


- (IBAction)noticeMoreAction:(id)sender {
    if (_noticeEntity) {
        NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KNoticeMoreTradeId data:nil error:nil];
        [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"公告" type:KSWebSourceTypeHome];
    }
}
#pragma mark - 内部方法
/**
 *  设置列表加载刷新数据的图片
 */
- (void)tableRefreshGif
{
    // 添加动画图片的下拉刷新
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];
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
    DEBUGG(@"%s flag: %d", __FUNCTION__, flag);
    if (_netRefleshing) {
        return ;
    }
    _netRefleshing = YES;
    if (flag && self.needRefreshAnimation1 && self.needRefreshAnimation2)
    {
        DEBUGG(@"%s flag111: %d", __FUNCTION__, flag);
        //支持下拉刷新动画
        [_tableView.mj_header beginRefreshing];
    }
    else
    {
        DEBUGG(@"%s flag222: %d", __FUNCTION__, flag);
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
    if(!_homeRequestBL)
    {
        _homeRequestBL = [[KSHomeBL alloc] init];
    }
    _homeRequestBL.batchDelegate = self;

    
    
    //请求首页信息
    [_homeRequestBL doGetHomeInfo];
}

- (void)loadingMore
{
    //加载更多
}
#pragma mark - TableView Delegate & DataSource


- (void)reloadData
{
    [_tableView reloadData];
}

//由于多个请求不同时的剧新..会导致table view 错乱
- (void)reloadDataDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:.2];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return HEIGHT_ZERO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == KSSectionTypeHeader) {
        CGFloat bannerHeight = _bannerSize.height * MAIN_BOUNDS.size.width / _bannerSize.width;
        if (_needShowNotice)
        {
            bannerHeight += kNoticeHeight;
        }
        return bannerHeight;
    }
    
    if (section == KSSectionTypeNewbee && !_newbeeEntity) {
        return HEIGHT_ZERO;
    }
    if (section == KSSectionTypeAdvert) {
        if (self.businessEntity.businessList.count == 0) {
            return HEIGHT_ZERO;
        }
        
        _adsCellHeight = 166 * (CGRectGetWidth(self.view.frame) - kCellMargin * 2) / 720;
        return _adsCellHeight + kCellMargin;
    }
    if (section == KSSectionTypeInvestList && !_recommendData) {
        return HEIGHT_ZERO;
    }
    if (section == KSSectionTypeInvestOwner && _ownerLoansData.count == 0) {
        return HEIGHT_ZERO;
    }
    return _headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == KSSectionTypeHeader) {
        
        return _headerView;
    }
    if (section == KSSectionTypeAdvert) {
        _businessPlayerView.frame = CGRectMake(kCellMargin, kCellMargin, CGRectGetWidth(MAIN_BOUNDS) - 2 * kCellMargin, _adsCellHeight);
        [_businessPlayerView makeCorners:UIRectCornerAllCorners radius:kRadius];
//        [_businessPlayerView reloadData];
        return _businessHeaderView;
    }

    KSInvestHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kInvestHeaderView];
    if (section == KSSectionTypeNewbee) {
        if (!_newbeeEntity) {
            return nil;
        }
        view.titleLabel.text = KHomeNewbeeTitle;
        view.subtitleLabel.text = KHomeNewbeeSubtitle;
        view.tags = @[];
    }
    else if (section == KSSectionTypeInvestList)
    {
        if (_recommendData.recommendList.count == 0) {
            return nil;
        }
        view.titleLabel.text = KHomeRecomTitle;
        view.subtitleLabel.text = nil;
        view.tags = @[];
    }
    else if (section == KSSectionTypeInvestOwner)
    {
        if (_ownerLoansData.count == 0) {
            return nil;
        }
        view.titleLabel.text = KHomeOwnerTitle;
        view.subtitleLabel.text = nil;
        view.tags = @[KHomeOwnerTags];
    }
    
    return view;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return KSSectionTypeTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == KSSectionTypeHeader) {
        return 0;
    }
    if (KSSectionTypeNewbee == section) {
        return _newbeeEntity ? 1 : 0;
    }
    if (KSSectionTypeAdvert == section) {
        return 0;
    }
    if (KSSectionTypeInvestList == section) {
        return _recommendData.recommendList.count;
    }
    if (KSSectionTypeInvestOwner == section) {
        return _ownerLoansData.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == KSSectionTypeHeader) {
        return 0;
    }
    if (indexPath.section == KSSectionTypeNewbee)
    {
        return [tableView fd_heightForCellWithIdentifier:kNewbeeCell cacheByIndexPath:indexPath configuration:nil];
    }
    
    if (indexPath.section == KSSectionTypeAdvert) {
        return 0;
    }
    
    if (indexPath.section == KSSectionTypeInvestList) {
      CGFloat height =  [tableView fd_heightForCellWithIdentifier:kInvestListCell cacheByIndexPath:indexPath configuration:^(KSInvestListCell *cell) {
            KSLoanItemEntity *entity = _recommendData.recommendList[indexPath.row];
            [cell updateItem:entity busssiness:YES];
        }];
        return height;
    }
    
    return [tableView fd_heightForCellWithIdentifier:kInvestOwnerCell cacheByIndexPath:indexPath configuration:^(KSInvestOwnerCell *cell) {
        KSOwnerLoanItemEntity *entity = _ownerLoansData[indexPath.row];
        [cell updateItem:entity.loan];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == KSSectionTypeNewbee) {
        KSNewbeeCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewbeeCell];
        [cell.investButton removeTarget:self action:@selector(newbeeInvestAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.investButton addTarget:self action:@selector(newbeeInvestAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell tableView:tableView setCornerRaduis:kRadius byRoundType:KSCellRoundCornerTypeBottom inLayoutMargins:UIEdgeInsetsMake(0, kCellMargin, 0.5, kCellMargin)];
        [cell updateItem:_newbeeEntity];
        return cell;
    }
    
    KSBaseCell *cell = nil;
    
    if (indexPath.section == KSSectionTypeInvestList) {
        KSLoanItemEntity *entity = _recommendData.recommendList[indexPath.row];
        KSInvestListCell *investCell = [tableView dequeueReusableCellWithIdentifier:kInvestListCell];
        [investCell updateItem:entity busssiness:YES];
        cell = investCell;
    }
    else
    {
        KSOwnerLoanItemEntity *entity = _ownerLoansData[indexPath.row];
        KSInvestOwnerCell *ownerCell = [tableView dequeueReusableCellWithIdentifier:kInvestOwnerCell];
        [ownerCell updateItem:entity.loan];
        [ownerCell updateFreeDuration:entity];
        cell = ownerCell;
    }
    
    
    NSInteger allRows = [tableView numberOfRowsInSection:indexPath.section];
    if (allRows - 1 == indexPath.row) {
        [cell tableView:tableView setCornerRaduis:kRadius byRoundType:KSCellRoundCornerTypeBottom inLayoutMargins:UIEdgeInsetsMake(0, kCellMargin, 0.5, kCellMargin)];
    }else{
        [cell tableView:tableView setCornerRaduis:kRadius byRoundType:KSCellRoundCornerTypeCenter inLayoutMargins:UIEdgeInsetsMake(0, kCellMargin, 0.5, kCellMargin)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KSLoanItemEntity *entity = nil;
    if (indexPath.section == KSSectionTypeInvestList)
    {
        entity = _recommendData.recommendList[indexPath.row];
        
        //普通标的
        if (entity) {
            KSInvestDetailVC *vc = [[KSInvestDetailVC alloc]initWithNibName:@"KSInvestDetailVC" bundle:nil];
            vc.entity = entity;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == KSSectionTypeInvestOwner)
    {
        KSOwnerLoanItemEntity *ownerEntity = _ownerLoansData[indexPath.row];
        //跳转物业宝
        [self turn2OwnerLoanPage:ownerEntity];
    }
}

#pragma mark - SDCycleScrollViewDelegate
    
    /** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)pageView didSelectItemAtIndex:(NSInteger)index
{
    INFO(@"%s, pageView:%@ index: %ld",__FUNCTION__, pageView, index);
    if (pageView == _bannerPlayerView)
    {
        KSBussinessItemEntity *entity = nil;
        if (index >= 0 && index < _bannerEntity.bannerList.count)
        {
            entity = _bannerEntity.bannerList[index];
        }
        INFO(@"%@",entity);
        [self execBussinessItemEntity:entity];
    }
    else if (pageView == _businessPlayerView)
    {
        KSBussinessItemEntity *entity = nil;
        if (index >= 0 && index < _businessEntity.businessList.count)
        {
            entity = _businessEntity.businessList[index];
        }
        [self execBussinessItemEntity:entity];
    }
    else if (pageView == _noticePlayerView)
    {
        KSNoticeItemEntity *entity = nil;
        if (index >= 0 && index < _noticeEntity.noticeList.count)
        {
            entity = _noticeEntity.noticeList[index];
        }
        NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KNoticeDetailTradeId data:@{kIdKey:@(entity.ID)} error:nil];
        [KSWebVC pushInController:self.navigationController urlString:urlStr title:entity.title type:KSWebSourceTypeHome];
    }
}
    

#pragma mark - JKPageViewDelegate

/**
 *  更新tableHeaderView
 */
- (void)updateTableViewHeaderViewHeight
{
    
    CGFloat bannerHeight = 0;
    if (_bannerEntity.bannerList.count > 0 && _bannerSize.width > 0) {
        bannerHeight = _bannerSize.height * MAIN_BOUNDS.size.width / _bannerSize.width;
    }
    
    _headerView.frame =  CGRectMake(0, 0, MAIN_BOUNDS.size.width, bannerHeight + CGRectGetHeight(_noticePlayerView.frame));

    [_headerView setNeedsLayout];
    [_headerView layoutIfNeeded];
    [self reloadDataDelay];
    WARN(@"table view header frame = %@", NSStringFromCGRect(_headerView.frame));
    if (!_tableView.tableHeaderView) {
        _tableView.tableHeaderView = _headerView ;
    }
//    _tableView.tableHeaderView = nil;
}



#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor *color = self.navigationController.navigationBar.barTintColor;
    CGFloat NAVBAR_CHANGE_POINT = CGRectGetHeight(_headerView.frame) - CGRectGetHeight(_noticePlayerView.frame) - 64;
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
        self.navigationItem.title = KHomeTitleText;
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
        self.navigationItem.title = nil;
    }
}

#pragma mark - 内部方法
- (void)turn2OwnerLoanPage:(KSOwnerLoanItemEntity *)ownerEntity
{
    //判断登录态
    BOOL flag = [USER_MGR judgeLoginForVC:self.navigationController.tabBarController];
    if (!flag)
    {
        return;
    }
    
    //判断是否开户
    KSNewAssetsEntity *userAssets = USER_MGR.assets;
    if(![userAssets isOpenAccount])
    {
        //跳转开户页面
        [self turn2OpenAccountPage];
        return;
    }
    //物业宝
    KSLoanItemEntity * entity = ownerEntity.loan;
    if (entity)
    {
//        NSString *imeiStr = USER_SESSIONID;
//        NSString *url = ownerEntity.url;
//        url = [NSString stringWithFormat:@"%@/%@",SX_H5,url];
//        NSString *encodeStr = [url stringByAddingPercentEncodingForFormData:YES];
//        url = [NSString stringWithFormat:@"%@/app/syncSessionForApp?app=1&url=%@&imei=%@",SX_HOST,encodeStr,imeiStr];
        NSString *titleStr = entity.title;
        NSString *url = [KSRequestBL createGetRequestURLWithTradeId:KOwnerLoanDetailPage data:@{kLoanIdKey:@(entity.ID)} error:nil];
        KSOwnerLoanVC *vc = [[KSOwnerLoanVC alloc] initWithUrl:url title:titleStr type:KSWebSourceTypeHome];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 *  @author semny
 *
 *  跳转开户
 */
- (void)turn2OpenAccountPage
{
//    NSString *imeiStr = USER_SESSIONID;
//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@&app=1", KOpenAccountPage, imeiStr];
//  
//    //开托管账户
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:KSWebSourceTypeHome];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeHome];
}

#pragma mark - KSBatchBLDelegate

- (void)failedBatchHandle:(KSBRequestBL *)blEntity
{
    _netRefleshing = NO;
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}

- (void)finishBatchHandle:(KSBRequestBL *)blEntity
{
    _netRefleshing = NO;
    [_tableView.mj_header endRefreshing];
    [self reloadDataDelay];
}

- (void)finishBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result
{
    id entity = result.body;
    INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    if ([entity isKindOfClass:[KSNewbeeEntity class]]) {
        self.newbeeEntity = entity;
        //self.newbeeEntity.loanData.newbee = YES;
        //self.newbeeEntity.loanData.newbeeAmount = self.newbeeEntity.newbeeAmount;
        [self updateNewbee];
        
        NSDictionary *json = [entity yy_modelToJSONObject];
        [KSFileUtil saveFile:CACHE_NEWBEE data:json];
    }
    else if ([entity isKindOfClass:[KSHomeTogetherEntity class]])
    {
        KSHomeTogetherEntity *togetherEntity = (KSHomeTogetherEntity *)entity;
        [self updateHomeTogether:togetherEntity cache:NO];
        
        NSDictionary *json = [togetherEntity yy_modelToJSONObject];
        [KSFileUtil saveFile:CACHE_HOME_TOGETHER data:json];
    }
    else if ([entity isKindOfClass:[KSORLoanEntity class]])
    {
        KSORLoanEntity *loanEntity = (KSORLoanEntity *)entity;
        [self updateORLoan:loanEntity];
        
        NSDictionary *json = [loanEntity yy_modelToJSONObject];
        [KSFileUtil saveFile:CACHE_OR_LOAN data:json];
    }
    
//    DEBUGG(@"%@ <<>> json: %@", entity, [entity yy_modelToJSONString]);
}

- (void)failedBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity*)result
{
    [_tableView.mj_header endRefreshing];
//    ERROR(@"failedBatchHandle %@", NSStringFromClass([blEntity class]));
}

- (void)sysErrorBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result
{
    _netRefleshing = NO;
    //防止同一时间多次弹出
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayToastNetworkError) object:nil];
    [self performSelector:@selector(delayToastNetworkError) withObject:nil afterDelay:2];
}


- (void)delayToastNetworkError
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}


#pragma mark - Update UI


- (void)cacheDataInit
{
    NSDictionary *json = [KSFileUtil openFile:CACHE_NEWBEE];
    if (!json) {
        //加载默认新手标数据
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_newbee" ofType:@"json"]];
        json = [data objectFromJSONData];
    }
    self.newbeeEntity = [KSNewbeeEntity yy_modelWithJSON:json];
    [self updateNewbee];
    
    json = [KSFileUtil openFile:CACHE_HOME_TOGETHER];

    KSHomeTogetherEntity *togetherEntity = [KSHomeTogetherEntity yy_modelWithJSON:json];
//    NSArray *banners = togetherEntity.bannerResult.businessData;
//    NSLog(@"%@",AppVersion);
//    if(banners)
//    {
////        NSInteger count = banners.count;
//        for (KSBussinessItemEntity *item in banners)
//        {
////            for (NSString *version in item.appVersions)
////            {
////                if([AppVersion isEqualToString:version] || [[version lowercaseString] isEqualToString:@"all"])
////                {
//                    [self.bannerDataArray addObject:item];
//                    break;
////                }
////            }
//        }
//    }
    
    [self updateHomeTogether:togetherEntity cache:YES];
    
    json = [KSFileUtil openFile:CACHE_OR_LOAN];
    KSORLoanEntity *loanEntity = [KSORLoanEntity yy_modelWithJSON:json];
    [self updateORLoan:loanEntity];
}


- (void)updateNewbee
{
    //隐藏已经购买的新手标
//    if (![_newbeeEntity.loanData isLoanOpen]) {
//        self.newbeeEntity = nil;
//    }
    
    [self reloadDataDelay];
}


- (void)updateHomeTogether:(KSHomeTogetherEntity *)togetherEntity cache:(BOOL)isCache
{
    if (!togetherEntity)
    {
        return;
    }
    //banner
    self.bannerEntity = togetherEntity.bannerModel;
    //notice
    self.noticeEntity = togetherEntity.noticeModel;
    
    if ([self judgeIfShowNotice])
    {
        self.noticeViewHeightConstraint.constant = kNoticeHeight;
        _noticePlayerView.superview.hidden = NO;
    }
    else
    {
        self.noticeViewHeightConstraint.constant = 0;
        _noticePlayerView.superview.hidden = YES;
    }
 
    // 过滤运营图
    self.businessEntity = togetherEntity.businessModel;
    
    if (_bannerEntity.bannerList.count > 0)
    {
        NSMutableArray *urlArray = [NSMutableArray array];
        for (KSBussinessItemEntity *entity in _bannerEntity.bannerList) {
            [urlArray addObject:entity.imageUrl];
        }
        _bannerPlayerView.imageURLStringsGroup = urlArray;
    }else{
        _bannerPlayerView.imageURLStringsGroup = nil;
    }
    
    if (_businessEntity.businessList.count > 0) {
        NSMutableArray *urlArray = [NSMutableArray array];
        for (KSBussinessItemEntity *entity in _businessEntity.businessList) {
            [urlArray addObject:entity.imageUrl];
        }
        _businessPlayerView.imageURLStringsGroup = urlArray;
    }else{
        _businessPlayerView.imageURLStringsGroup = nil;
    }
    
    if(_needShowNotice && _noticeEntity)
    {
        NSMutableArray *titleArray = [NSMutableArray array];
        /**
         *  后台缓存存在问题，有时候会传多于三条数据，所以选择只取前三条
         */
        NSInteger listCount = _noticeEntity.noticeList.count;
        if(listCount>=kNoticeNum)
        {
            NSArray *first3Array = [_noticeEntity.noticeList subarrayWithRange:NSMakeRange(0, kNoticeNum)];
            if (first3Array)
            {
                for (KSNoticeItemEntity *entity in first3Array)
                {
                    [titleArray addObject:entity.title];
                }
            }
        }
        else
        {
            for (KSNoticeItemEntity *entity in _noticeEntity.noticeList)
            {
                [titleArray addObject:entity.title];
            }
        }
        _noticePlayerView.titlesGroup = titleArray;
    }
    else
    {
        _noticePlayerView.frame = CGRectZero;
    }
    
    

    [self reloadDataDelay];
}

//根据版本号，渠道号，平台类型来决定是否显示公告栏
-(BOOL)judgeIfShowNotice
{

    if (self.noticeEntity.noticeList && self.noticeEntity.noticeList.count>0)
    {
        _needShowNotice = YES;  
    }
    else
    {
        _needShowNotice = NO;
    }
    return _needShowNotice;
}

#if 0
-(void)filterBatchItems:(NSArray*)itemsArray Type:(KSFilterType)type Status:(NSString*)status
{
    // 过滤与版本号，渠道号和平台号匹配的banner
    KSFilterUtils *filterUtils =[KSFilterUtils sharedInstance];
    if (itemsArray && itemsArray.count>0)
    {
        switch (type) {
            case KSFilterTypeBanner:
                {
                    if (self.bannerDataArray && self.bannerDataArray.count)
                    {
                        [self.bannerDataArray removeAllObjects];
                    }
                
                    for (KSBussinessItemEntity *item in itemsArray)
                    {
                        KSBussinessItemEntity *filterItem = [filterUtils pickupValidBanner:item Platform:item.platformType Versions:item.appVersions Channels:item.appChannels Status:nil];
                    
                        if (filterItem)
                        {
                            [self.bannerDataArray addObject:filterItem];
                        }
                    }
                }
                break;
            case KSFilterTypeNotice:
            {

            }
                break;
            case KSFilterTypeBusiness:
                {
                    if (self.businessDataArray && self.businessDataArray.count)
                    {
                        [self.businessDataArray removeAllObjects];
                    }
                
                    for (KSBussinessItemEntity *item in itemsArray)
                    {
                    
                        KSBussinessItemEntity *filterItem = [filterUtils pickupValidBanner:item Platform:item.platformType Versions:item.appVersions Channels:item.appChannels Status:nil];
                    
                        if (filterItem)
                        {
                            [self.businessDataArray addObject:filterItem];
                        }
                    }
                }
                break;
            default:
                break;
        }

        
    }

}
#endif

- (void)updateORLoan:(KSORLoanEntity *)loanEntity
{
    self.recommendData = loanEntity.recommendData;
    for (KSLoanItemEntity *entity in _recommendData.recommendList) {
        [entity calcCountdownTime];
    }
    self.ownerLoansData = loanEntity.ownerLoansData;
    [self reloadDataDelay];
}

@end
