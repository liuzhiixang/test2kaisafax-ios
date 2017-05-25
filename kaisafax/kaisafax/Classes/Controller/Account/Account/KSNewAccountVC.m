//
//  KSNewAccountVC.m
//  kaisafax
//
//  Created by Jjyo on 2017/4/25.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNewAccountVC.h"
#import "JXMCSUserManager.h"
#import "KSAccountFooterView.h"
#import "KSAccountInvestVC.h"
#import "KSAccountInvestView.h"
#import "KSAccountSettingVC.h"
#import "KSAccumulatedIncomeEntity.h"
#import "KSAssetsBL.h"
#import "KSAutoLoanVC.h"
#import "KSBankCardsVC.h"
#import "KSConfig.h"
#import "KSContactTFCell.h"
#import "KSCustomLoansBL.h"
#import "KSDepositVC.h"
#import "KSFileUtil.h"
#import "KSFundRecordVC.h"
#import "KSInvestDetailVC.h"
#import "KSJDCardReceiveVC.h"
#import "KSJDCardVC.h"
#import "KSLoginVC.h"
#import "KSMoreVC.h"
#import "KSNValidRewardVC.h"
#import "KSNewAssetsEntity.h"
#import "KSNewAssetsVC.h"
#import "KSORLoanEntity.h"
#import "KSOpenAccountVC.h"
#import "KSPromoteVC.h"
#import "KSRechargeVC.h"
#import "KSRedpacketVC.h"
#import "KSRewardBL.h"
#import "KSUserInfoBL.h"
#import "KSUserInfoItemModel.h"
#import "KSUserMgr.h"
#import "KSValidRewardsEntity.h"
#import "KSWebVC.h"
#import "KSWholeInvestVC.h"
#import "KSWholeNewRedPacketVC.h"
//#import "MJExtension.h"
#import "MJRefresh.h"
#import "UINavigationBar+Awesome.h"
#import "WMPageController.h"
#import "YYText.h"

#define KNavSpace 5.0
#define KImageRatio (360.0 / 750)
#define TopImgHeight (MAIN_BOUNDS_SCREEN_WIDTH * KImageRatio)

@interface KSNewAccountVC () <UIScrollViewDelegate, KSBLDelegate,
							  KSAccountInvestViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *eyeButton;

@property (nonatomic, weak) IBOutlet UIView *unloginView; //未登录

@property (nonatomic, weak) IBOutlet UIView *assetsView; //资产

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
//总资产
@property (weak, nonatomic) IBOutlet UILabel *totalAssetLabel;
//可用余额
@property (weak, nonatomic) IBOutlet UILabel *availableAssetLabel;
//累计收益
@property (weak, nonatomic) IBOutlet UILabel *totalEarnLabel;
//回款日历
@property (nonatomic, weak) IBOutlet UILabel *undueInvestCountLabel;
//银行卡数
@property (nonatomic, weak) IBOutlet UILabel *bankCardsCountLabel;
//我的红包
@property (nonatomic, weak) IBOutlet UILabel *ticketsCountLabel;
//可提奖励
@property (nonatomic, weak) IBOutlet UILabel *validRewardsLabel;
//定制标
@property (weak, nonatomic) IBOutlet KSAccountInvestView *customInvestView;
@property (weak, nonatomic) IBOutlet UIView *investSpanView;

//顶部图片
@property (strong, nonatomic) UIImageView *topImgView;
//庶罩层
@property (strong, nonatomic) UIView *topBackgroundView;
//名字显示label
@property (strong, nonatomic) UILabel *nameLabel;

//定制标BL
@property (strong, nonatomic) KSCustomLoansBL *customLoanBL;
//累计收益BL
@property (strong, nonatomic) KSAssetsBL *assetBL;
//可提奖励BL
@property (strong, nonatomic) KSRewardBL *rewardBL;

//累计奖励 Entity
@property (strong, nonatomic) KSAccumulatedIncomeEntity *incomeEntity;
//可提奖励 Entity
@property (strong, nonatomic) KSValidRewardsEntity *validRewards;

//定制标数据
@property (strong, nonatomic) NSArray *investArray;

// navigation items
@property (strong, nonatomic) NSArray *navItems;

//跳转到资产中心
- (IBAction)assetDetailAction:(UIButton *)sender;

@end

@implementation KSNewAccountVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	_scrollView.delegate = self;

	//因为这里用了setNavigationBarHidden, 所以不设置edgesForExtendedLayout
	self.edgesForExtendedLayout				  = UIRectEdgeTop;
	self.automaticallyAdjustsScrollViewInsets = NO;

	_eyeButton.selected =
		[USER_MGR getUserAssetsHiddenFlagForUser:USER_MGR.user.user.userId];

	_customInvestView.delegate = self;

	[self addHeaderBackgroundView];
	[self setNavConfig];

	[self tableRefreshGif];
	[self addObserver];
}

/*
//添加定制标测试数据
- (void)setInvestTestData
{

	NSDictionary *json = [KSFileUtil openFile:@"ORLoan.cache"];
	KSORLoanEntity *loanEntity = [KSORLoanEntity yy_modelWithJSON:json];
	KSRecomLoanEntity *recomEntity = loanEntity.recommendData;
	for (KSLoanItemEntity *entity in recomEntity.data) {
		[entity calcCountdownTime];

	}
	self.investArray = recomEntity.data;
}
*/

//添加背景拉伸图片
- (void)addHeaderBackgroundView
{
	// TopImgHeight-->宏定义的图片高度
	_topImgView = [[UIImageView alloc]
		initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH,
								 TopImgHeight)];
	_topImgView.image		  = [UIImage imageNamed:@"account_center"];
	_topImgView.clipsToBounds = YES;

	_topBackgroundView = [[UIView alloc]
		initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH,
								 TopImgHeight)];
	_topBackgroundView.backgroundColor = self.view.backgroundColor;
	_topBackgroundView.clipsToBounds   = YES;
	[_topBackgroundView addSubview:_topImgView];

	//重点（不设置那将只会被纵向拉伸）
	[self.view insertSubview:_topBackgroundView atIndex:0];
}

- (BOOL)transparentNavigationBar
{
	return YES;
}

//添加 KVO
- (void)addObserver
{
	@WeakObj(self);
	//账户信息
	[RACObserve(USER_MGR, assets) subscribeNext:^(id x) {
		// 更新页面

		[weakself updateUIData];
		//定指标
		[weakself updateCustomLoans];

		if ([USER_MGR isLogin])
		{
			//累计收益
			[weakself updateAcculateAssets];
			//可提奖励
			[weakself updateRewards];
			//用户信息更新
			[USER_MGR doGetUserInfo];
		}
	}];

	//账户信息
	[RACObserve(USER_MGR, user.user) subscribeNext:^(id x) {
		//用户信息变化
		[weakself updateUIData];
	}];

	[RACObserve(self, validRewards) subscribeNext:^(id x) {
		[weakself updateUIData];
	}];

	[RACObserve(self, incomeEntity) subscribeNext:^(id x) {
		[weakself updateUIData];
	}];

	//添加登录态监听器
	[[NOTIFY_CENTER rac_addObserverForName:KLoginStatusNotification object:nil]
		subscribeNext:^(NSNotification *notify) {
			[weakself.scrollView scrollRectToVisible:MAIN_BOUNDS animated:NO];
		}];

	[[NOTIFY_CENTER rac_addObserverForName:KChangeAccountEyeFlagKey object:nil]
		subscribeNext:^(NSNotification *notify) {
			NSDictionary *dict	= notify.userInfo;
			NSNumber *	eyeFlag = dict[@"eyeBtnFlag"];
			_eyeButton.selected   = [eyeFlag boolValue];
			[weakself updateUIData];
		}];
}

//更新业务数据
- (void)updateUIData
{
	BOOL isLogin		= USER_MGR.isLogin;
	_unloginView.hidden = isLogin;
	_assetsView.hidden  = !isLogin;
	if (isLogin)
	{
		_nameLabel.text = [USER_MGR.user.user getFormateName].length > 0
							  ? [USER_MGR.user.user getFormateName]
							  : [USER_MGR.user.user getFormateLoginName];
		self.navigationItem.leftBarButtonItems = _navItems;
	}
	else
	{
		_validRewards						   = nil;
		_incomeEntity						   = nil;
		_investArray						   = nil;
		self.navigationItem.leftBarButtonItems = nil;
	}

	_availableAssetLabel.text = USER_MGR.assets.fund.available.moneyFormat;
	_undueInvestCountLabel.text =
		[NSString stringWithFormat:@"%ld", USER_MGR.assets.undueInvestCount];
	_bankCardsCountLabel.text =
		[NSString stringWithFormat:@"%ld", USER_MGR.assets.bankCards];
	_ticketsCountLabel.text =
		[NSString stringWithFormat:@"%ld", USER_MGR.assets.ticketsCount];

	_totalAssetLabel.text = [NSString
		stringWithFormat:@"%@%@",
						 [KSBaseEntity
							 formatAmountString:USER_MGR.assets.totalAsset],
						 KUnit];
	;
	_validRewardsLabel.text =
		_validRewards ? _validRewards.totalExtractableAmt : @"0.00";
	_totalEarnLabel.text = [NSString
		stringWithFormat:@"%@%@",
						 [KSBaseEntity
							 formatAmountString:_incomeEntity.totalEarn],
						 KUnit];

	//获取新的userid

	if (_eyeButton.selected)
	{
		_totalAssetLabel.text	 = KHiddenStarTitle;
		_totalEarnLabel.text	  = KHiddenStarTitle;
		_availableAssetLabel.text = KHiddenStarTitle;
	}

	[self reloadCustomLoans];
}

//定制标
- (void)reloadCustomLoans
{
	_customInvestView.loanItemList = _investArray;
	_customInvestView.hidden	   = _investArray.count == 0;
	_investSpanView.hidden		   = _customInvestView.hidden;
}

- (void)setNavConfig
{
	UIView *customView = [[UIView alloc]
		initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH,
								 navBarHeight)];

	UIImageView *imageview = [[UIImageView alloc] init];
	imageview.image		   = [UIImage imageNamed:@"account_3dot"];
	CGFloat imageW		   = imageview.image.size.width;
	CGFloat imageH		   = imageview.image.size.height;
	imageview.frame =
		CGRectMake(0, (navBarHeight - imageH) / 2, imageW, imageH);
	//    UIBarButtonItem *dot = [[UIBarButtonItem
	//    alloc]initWithCustomView:imageview];
	[customView addSubview:imageview];

	UIBarButtonItem *offsetSpacer = [[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
							 target:nil
							 action:nil];
	offsetSpacer.width = -KNavSpace;

	UIButton *btn = [[UIButton alloc] init];
	CGFloat btnW  = 30;
	[btn setBackgroundImage:[UIImage imageNamed:@"ic_account_set"]
				   forState:UIControlStateNormal];
	[btn addTarget:self
				  action:@selector(accountSetting)
		forControlEvents:(UIControlEventTouchUpInside)];
	btn.frame = CGRectMake(imageW + KNavSpace, (navBarHeight - btnW) / 2,
						   btnW, btnW);
	//    UIBarButtonItem *user = [[UIBarButtonItem
	//    alloc]initWithCustomView:btn];
	[customView addSubview:btn];

	UILabel *label		= [[UILabel alloc] init];
	label.textAlignment = NSTextAlignmentLeft;
	CGFloat lebelH		= 12.0;
	label.font			= [UIFont systemFontOfSize:12.0];
	label.textColor		= WhiteColor;
	label.frame			= CGRectMake(imageW + KNavSpace + btnW + KNavSpace,
							 (navBarHeight - lebelH) / 2,
							 MAIN_BOUNDS_SCREEN_WIDTH, lebelH);
	[customView addSubview:label];
	_nameLabel = label;
	UIBarButtonItem *customer =
		[[UIBarButtonItem alloc] initWithCustomView:customView];

	_navItems = @[ offsetSpacer, customer ];
}

/**
 *  设置列表加载刷新数据的图片
 */
- (void)tableRefreshGif
{
	// 添加动画图片的下拉刷新
	[self scrollView:_scrollView
		headerRefreshAction:@selector(refreshing)
		footerRefreshAction:nil];
}

- (void)refreshing
{
	if ([self.scrollView.mj_header isRefreshing])
	{
		//关闭动画效果
		[self.scrollView.mj_header endRefreshing];
	}
	if ([USER_MGR isLogin])
	{
		//帐户信息
		[USER_MGR updateUserAssets];
	}
}

- (void)updateCustomLoans
{
	if (!_customLoanBL)
	{
		_customLoanBL		   = [[KSCustomLoansBL alloc] init];
		_customLoanBL.delegate = self;
	}
	[_customLoanBL doGetCustomLoans];
}

- (void)updateAcculateAssets
{
	if (!_assetBL)
	{
		_assetBL		  = [[KSAssetsBL alloc] init];
		_assetBL.delegate = self;
	}
	[_assetBL doGetUserAccumulatedIncome];
}

- (void)updateRewards
{
	if (!_rewardBL)
	{
		_rewardBL		   = [[KSRewardBL alloc] init];
		_rewardBL.delegate = self;
	}
	[_rewardBL doGetValidRewardsForDetail];
}

#pragma mark - 子界面控制器跳转

//判断是否弹出登录界面
- (BOOL)needLogin
{
	BOOL isLogin = [USER_MGR isLogin];
	if (!isLogin)
	{
		[USER_MGR judgeLoginForVC:self];
	}
	return !isLogin;
}

#pragma mark - Action

- (IBAction)eyeAction:(id)sender
{
	_eyeButton.selected ^= 1;
	[self updateUIData];
	[USER_MGR setUserAssetsHiddenFlagForUser:USER_MGR.user.user.userId
										With:_eyeButton.selected];
}

//我的投资
- (IBAction)pushInvest:(id)sender
{
	if (![self needLogin])
	{
		KSWholeInvestVC *wholeVc =
			[[KSWholeInvestVC alloc] initWithIndex:WMPageControllerTypeAccount];
		[self.navigationController pushViewController:wholeVc animated:YES];
	}
}

//回款日历
- (IBAction)pushPayCalendar:(id)sender
{
	if (![self needLogin])
	{
		NSString *urlStr =
			[KSRequestBL createGetRequestURLWithTradeId:KPayCalendarTradeId
												   data:nil
												  error:nil];
		NSString *title = KRepayCalendarText;
		[KSWebVC pushInController:self.navigationController
						urlString:urlStr
							title:title
							 type:KSWebSourceTypeAccount];
	}
}

//我的红包
- (IBAction)pushRedpacket:(id)sender
{
	if (![self needLogin])
	{
		KSWholeNewRedPacketVC *wholeVC   = [[KSWholeNewRedPacketVC alloc] init];
		wholeVC.type					 = KSWebSourceTypeAccount;
		wholeVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:wholeVC animated:YES];
	}
}

//可提取奖励
- (IBAction)pushReward:(id)sender
{
	if (![self needLogin])
	{
		KSNValidRewardVC *rewardVc		  = [[KSNValidRewardVC alloc] init];
		rewardVc.type					  = KSWebSourceTypeAccount;
		rewardVc.hidesBottomBarWhenPushed = YES;
		rewardVc.validRewards			  = _validRewards;
		//    rewardVc.qualified = [NSString
		//    stringWithFormat:@"%.2f",USER_MGR.assets.avaliableRewardTotal];
		[self.navigationController pushViewController:rewardVc animated:YES];
	}
}

//我的推广
- (IBAction)pushPromote:(id)sender
{
	if (![self needLogin])
	{
		UIViewController *vc		= [[KSPromoteVC alloc] init];
		vc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

//资金记录
- (IBAction)pushFundRecord:(id)sender
{
	if (![self needLogin])
	{
		UIViewController *recordVC		  = [[KSFundRecordVC alloc] init];
		recordVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:recordVC animated:YES];
	}
}

//更多
- (IBAction)pushMore:(id)sender
{
	if (![self needLogin])
	{
		KSMoreVC *moreVc				= [[KSMoreVC alloc] init];
		moreVc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:moreVc animated:YES];
	}
}

//安全
//-(void)pushSafe
//{
//    KSSafetyVC *safeVc = [[KSSafetyVC alloc]init];
//    safeVc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:safeVc animated:YES];
//}

//银行卡
- (IBAction)pushBanks:(id)sender
{
	if (![self needLogin])
	{
		KSBankCardsVC *bankVc			= [[KSBankCardsVC alloc] init];
		bankVc.type						= KSWebSourceTypeAccount;
		bankVc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:bankVc animated:YES];
	}
}
//自动投资
- (IBAction)pushAutoLoan:(id)sender
{
	if (![self needLogin])
	{
		KSAutoLoanVC *vc			= [[KSAutoLoanVC alloc] init];
		vc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:vc animated:YES];
	}
}
//京东卡
- (IBAction)pushJDCards:(id)sender
{
	if (![self needLogin])
	{
		KSJDCardVC *jdVC			  = [[KSJDCardVC alloc] init];
		jdVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:jdVC animated:YES];
	}
}

//客服
- (IBAction)pushCustomerCenter:(id)sender
{
	JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];

	if ([mgr isLogin])
	{
		[self jumpToCustomerCenter];
	}
	else
	{
		[self loginJXCustomer];
	}
}

//登录
- (IBAction)loginAction:(id)sender
{
	[self needLogin];
}

//充值
- (IBAction)rechargeAction:(id)sender
{
	if (![self needLogin])
	{
		KSRechargeVC *controller			= [[KSRechargeVC alloc] init];
		controller.type						= KSWebSourceTypeAccount;
		controller.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:controller animated:YES];
	}
}

//提现
- (IBAction)takeCashAction:(id)sender
{
	if (![self needLogin])
	{
		KSDepositVC *controller				= [[KSDepositVC alloc] init];
		controller.type						= KSWebSourceTypeAccount;
		controller.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (IBAction)assetDetailAction:(UIButton *)sender
{
	if (![USER_MGR isLogin])
		return;

	//跳转到资产详情页
	KSNewAssetsVC *assetVC			 = [[KSNewAssetsVC alloc] init];
	assetVC.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:assetVC animated:YES];
}

//个人设置
- (void)accountSetting
{
	UIViewController *vc		= [[KSAccountSettingVC alloc] init];
	vc.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 佳信客服
#pragma mark - 调用客服API

- (void)jumpToCustomerCenter
{
	[[JXMCSUserManager sharedInstance] requestCSForUI:self.navigationController
											indexPath:1];
}

- (void)loginJXCustomer
{
	JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
	@WeakObj(self);
	[mgr loginWithAppKey:KJXAppkey
		  responseObject:^(BOOL success, id responseObject) {
			  if (success)
			  {
				  [weakself loginJXSuccessed];
			  }
			  else
			  {
				  dispatch_after(
					  dispatch_time(DISPATCH_TIME_NOW,
									(int64_t)(0.f * NSEC_PER_SEC)),
					  dispatch_get_main_queue(), ^{
						  JXError *error = responseObject;
						  if (error)
						  {
							  [sJXHUD showMessage:@"佳信客服登录失败"
										 duration:1.f];
						  }

					  });
			  }
		  }];
}

- (void)loginJXSuccessed
{
	[self jumpToCustomerCenter];
}

#pragma mark - KSAccountInvestViewDelegate

- (void)investView:(KSAccountInvestView *)investView
	didSelectEntity:(KSLoanItemEntity *)entity
{
	KSInvestDetailVC *controller		= [[KSInvestDetailVC alloc] init];
	controller.hidesBottomBarWhenPushed = YES;
	controller.entity					= entity;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)investView:(KSAccountInvestView *)investView
	  updateHeight:(CGFloat)height
{
	DEBUGG(@"investView updateHeight:%f", height);
}

#pragma mark - KSBLDelegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	NSString *tradeId = result.tradeId;
	if ([tradeId isEqualToString:KCustomLoansTradeId])
	{
		//定制标
		KSLoansEntity *loans = (KSLoansEntity *) result.body;
		self.investArray	 = loans.loanList;

		//添加测试数据
		//        if (!_investArray) {
		//            [self setInvestTestData];
		//        }
		[self reloadCustomLoans];
	}
	else if ([tradeId isEqualToString:KGetUserAccumulatedIncomeTradeId])
	{
		//累计收益
		self.incomeEntity = (KSAccumulatedIncomeEntity *) result.body;
	}
	else if ([tradeId isEqualToString:KGetValidRewardsDetailTradeId])
	{
		self.validRewards = (KSValidRewardsEntity *) result.body;
	}
}

#pragma mark----UIScrollView------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat y = scrollView.contentOffset.y;
	if (y < 0)
	{
		/** 让其XYWH都‘拉伸’ */
		/** Ky --> 正值的下拉多少距离的值，Kx--> 根据Ky成比例的让x变 */
		CGFloat Ky = TopImgHeight - y;
		CGFloat Kx = Ky / KImageRatio;
		//        CGFloat Kx = (Ky/TopImgHeight)*KWidth/2;

		self.topImgView.frame =
			CGRectMake(0 - (Kx - MAIN_BOUNDS_SCREEN_WIDTH) / 2, 0, Kx, Ky);
		//        self.topImgView.frame = CGRectMake(0, 0,KWidth, Ky);
	}
	else
	{
		self.topImgView.frame =
			CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, TopImgHeight);
	}

	//计算庶罩层的大小
	//    CGRect rect =  [scrollView convertRect:_headerView.frame
	//    toView:self.view];
	//    _topBackgroundView.frame = CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH,
	//    CGRectGetMaxY(rect));

	CGRect rect =
		CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, TopImgHeight + 56 - y);
	_topBackgroundView.frame = rect;
	// DEBUGG(@"------ rect = %@ ||| y = %f -------", NSStringFromCGRect(rect),
	// y);
	//上滑nav bar效果

	if (USER_MGR.isLogin)
	{
		UIColor *color				 = self.navigationController.navigationBar.barTintColor;
		CGFloat  NAVBAR_CHANGE_POINT = 0 /*TopImgHeight - 64*/;
		CGFloat  offsetY			 = scrollView.contentOffset.y;
		if (offsetY > NAVBAR_CHANGE_POINT)
		{
			CGFloat alpha =
				MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
			[self.navigationController.navigationBar
				lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
		}
		else
		{
			[self.navigationController.navigationBar
				lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
		}
	}
}

@end
