//
//  KSInvestDetailVC.m
//  kaisafax
//
//  Created by Jjyo on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestDetailVC.h"
#import "AppDelegate.h"
#import "BEMCheckBox.h"
#import "IQKeyboardManager.h"
#import "JKScaleSlider.h"
#import "KSCalcuatorView.h"
#import "KSInvestAboutBL.h"
#import "KSInvestBL.h"
#import "KSInvestHistoryVC.h"
#import "KSLabel.h"
#import "KSLoanDetailEntity.h"
#import "KSLoanItemEntity.h"
#import "KSNewBeeBL.h"
#import "KSNewbeeEntity.h"
#import "KSOpenAccountVC.h"
#import "KSProgressBar.h"
#import "KSRechargeVC.h"
#import "KSRedpacketVC.h"
#import "KSRulesEntity.h"
#import "KSStatusView.h"
#import "KSTextField.h"
#import "KSUserMgr.h"
#import "KSWebVC.h"
#import "KSWholeNewRedPacketVC.h"
#import "MJRefresh.h"
#import "MZTimerLabel.h"
#import "SocialService.h"
#import "WMPageController.h"

#import "KSOpenAccountBL.h"

//刻度尺的列数, 为了优化性能, 这里要设置一个最大值
#define SLIDER_COLUMNS 100000
//理财计算器相关的宏
#define KInvestMaxLength 10
#define kCannotSelectError @"只有一次性还款才能选择天数"

@interface KSInvestDetailVC () <WMPageControllerDataSource, WMPageControllerDelegate, UIScrollViewDelegate, MZTimerLabelDelegate, JKScaleSliderDelegate, KSBLDelegate, BEMCheckBoxDelegate>

//loaninfo
//年利率
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *repayMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableAmoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *ruleLabel;
@property (weak, nonatomic) IBOutlet UILabel *revenueLabel; //预计收益
//标签父控件
@property (weak, nonatomic) IBOutlet UIStackView *stackView; //tags stack view

//剩余金额, 可投金额
@property (weak, nonatomic) IBOutlet UILabel *amountExplanLabel;
//起息日, 期限
@property (weak, nonatomic) IBOutlet UILabel *durationExplanLabel;

@property (weak, nonatomic) IBOutlet UIView *page1View; //标的信息
@property (weak, nonatomic) IBOutlet UIView *page2View; //标详情与投资记录

@property (weak, nonatomic) IBOutlet JKScaleSlider *investSlider;
@property (weak, nonatomic) IBOutlet KSTextField *investTextField;

@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *investScrollView;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;
@property (weak, nonatomic) IBOutlet UIButton *payAllButton; //全额投
@property (weak, nonatomic) IBOutlet UIButton *protrolButton;

@property (weak, nonatomic) IBOutlet KSProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *investButton;
@property (weak, nonatomic) IBOutlet KSStatusView *statusView;
@property (weak, nonatomic) IBOutlet MZTimerLabel *timerLabel;

//项目详情&投资记录
@property (strong, nonatomic) NSArray *			titleArray;
@property (strong, nonatomic) WMPageController *pageController;

@property (strong, nonatomic) KSInvestAboutBL *investDetailBL;
@property (strong, nonatomic) KSNewBeeBL *	 newbeeBL;

@property (assign, nonatomic) BOOL hasReadProtrol;	 //是否已经阅读了投资协议
@property (assign, nonatomic) BOOL hasRechargeSuccess; //是否充值成功
@property (assign, nonatomic) BOOL hasReplenishChrage; //是否差额充值状态
//@property (strong, nonatomic) KSNewbeeEntity *nbEntity;

//理财计算器view
@property (weak, nonatomic) KSCalcuatorView *finanCaluatorView;
@end

@implementation KSInvestDetailVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = _entity.title;

	//    [self setNavRightButtonByImage:@"ic_share"  selectedImageName:nil navBtnAction:@selector(shareAction:)];
	//    self.title = @"我是标题";
	self.hasReadProtrol = _checkBox.isSelected;

	//金额输入框
	_investTextField.maxValue = AMOUNT_MAX_VALUE;
	//隐藏placeholder解决键盘不显示提示信息的问题
	//    [_investTextField setPlaceholderHidden:YES];
	//解决光标的问题
	//    [_investTextField setPlaceholderTextFont:[UIFont systemFontOfSize:40.0f]];

	_mainScrollView.delegate   = self;
	_investScrollView.delegate = self;

	if ([_entity isNewBee])
	{
		_durationExplanLabel.text = @"投资期限";
		_amountExplanLabel.text   = @"可投金额(元)";
		_newbeeBL				  = [[KSNewBeeBL alloc] init];
		_newbeeBL.delegate		  = self;
	}

	@WeakObj(self);
	//只有第一次使用
	MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		// 进入刷新状态后会自动调用这个block
		[weakself showDetailPage];

	}];
	[footer setTitle:@" " forState:MJRefreshStateIdle];
	[footer setTitle:@" " forState:MJRefreshStatePulling];
	[footer setTitle:@" " forState:MJRefreshStateRefreshing];
	[footer setTitle:@" " forState:MJRefreshStateWillRefresh];
	_investScrollView.mj_footer = footer;

	UIView *view		 = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(MAIN_BOUNDS), CGRectGetWidth(MAIN_BOUNDS), CGRectGetHeight(MAIN_BOUNDS))];
	view.backgroundColor = UIColorFromHex(0x3e3e40);
	[_investScrollView insertSubview:view atIndex:0];

	UIView *view2		 = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(MAIN_BOUNDS), CGRectGetWidth(MAIN_BOUNDS), CGRectGetHeight(MAIN_BOUNDS))];
	view.backgroundColor = UIColorFromHex(0x3e3e40);
	[_mainScrollView insertSubview:view2 atIndex:0];

	//    [self updateLoanInfo];

	_investDetailBL			 = [[KSInvestAboutBL alloc] init];
	_investDetailBL.delegate = self;

	[self addObserver];

	/**
     *  Semny 20161117 详情页面由于改了监听逻辑导致未能在进入页面时请求detail接口
     */
	[self updateLoanDetail];

	_investSlider.lineColor		  = UIColorFromHex(0xc8c8c8);
	_investSlider.textColor		  = UIColorFromHex(0xa0a0a0);
	_investSlider.centerLineColor = NUI_HELPER.appOrangeColor;
}

- (void)updateLoanDetail
{
	[_investDetailBL doGetInvestDetailByLoanId:_entity.ID];
	if ([_entity isNewBee])
	{
		[_newbeeBL doGetNewBeeDetail];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar hideBottomHairline];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (_hasRechargeSuccess && _hasReplenishChrage)
	{
		_hasRechargeSuccess = NO;
		_hasReplenishChrage = NO;
		[self showRechargeSuccessAlert];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.navigationController.navigationBar showBottomHairline];
}

- (void)dealloc
{
	_investSlider.delegate = nil;
	[_pageController removeFromParentViewController];
	_pageController = nil;
	[NOTIFY_CENTER removeObserver:self];
}

#pragma mark - 内部方法
//添加 KVO
- (void)addObserver
{
	@WeakObj(self);
	//监听登录态
	[[NOTIFY_CENTER rac_addObserverForName:KLoginStatusNotification object:nil] subscribeNext:^(id x) {
		[weakself updateLoanDetail];
	}];

	//监听账户信息
	[RACObserve(USER_MGR, assets) subscribeNext:^(KSNewAssetsEntity *entity) {
		[weakself updateLoanInfo];
	}];

	//投资按钮
	RAC(_investButton, enabled) = [RACSignal combineLatest:@[ RACObserve(self, entity), _investTextField.rac_textSignal, RACObserve(self, hasReadProtrol), RACObserve(_investTextField, text) ]
													reduce:^id(KSLoanItemEntity *entity, NSString *input, NSNumber *check, NSNumber *sliderValue) {
														BOOL canBuy = YES;

														if ([USER_MGR isLogin])
														{
															canBuy = [weakself.entity isLoanOpen];
														}

														BOOL isOpenAccount	 = [USER_MGR.assets isOpenAccount];
														NSString *defaultTitle = (!isOpenAccount ? @"请开通第三方托管账户" : @"立即投资");
														if (![USER_MGR isLogin])
														{
															defaultTitle = @"立即投资";
														}

														[weakself updateRevenue];
														[weakself.investButton setTitle:defaultTitle forState:UIControlStateNormal];
														if ([weakself.entity isNewBee])
														{
															[weakself.investButton setTitle:([_nbEntity isCanInvest] ? defaultTitle : @"") forState:UIControlStateDisabled];
														}
														else
														{
															[weakself.investButton setTitle:([_entity isLoanOpen] ? defaultTitle : @"") forState:UIControlStateDisabled];
														}

														if (isOpenAccount || ![USER_MGR isLogin])
														{
															if ([weakself.entity isNewBee])
															{
																canBuy = [_nbEntity isCanInvest] && check.boolValue;
															}
															else
															{
																canBuy = [weakself.entity isLoanOpen] && check.boolValue;
															}
														}

														return @(canBuy);
													}];

	[[_checkBox rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		weakself.checkBox.selected ^= 1;
		weakself.hasReadProtrol = weakself.checkBox.selected;
	}];

	//充值成功提示
	[[NOTIFY_CENTER rac_addObserverForName:KRechargeNotification object:nil] subscribeNext:^(id x) {
		weakself.hasRechargeSuccess = YES;
	}];
}

//懒加载 项目详情/投资记录界面
- (void)addPageController
{
	if (!_pageController)
	{
		NSMutableArray *viewControllers = [NSMutableArray array];
		NSMutableArray *titles			= [NSMutableArray array];
		[viewControllers addObject:[KSWebVC class]];
		[titles addObject:@"项目详情"];
		if (![_entity isNewBee])
		{
			[viewControllers addObject:[KSInvestHistoryVC class]];
			[titles addObject:KInvestHistoryTitle];
		}
		_titleArray = [titles copy];

		_pageController = [[WMPageController alloc] init]; //initWithViewControllerClasses:viewControllers andTheirTitles:titles];
														   //        _pageController.view.nuiClass = NUIAppBackgroundView;

		NSInteger count				  = viewControllers.count;
		_pageController.menuItemWidth = 100; //(MAIN_BOUNDS_SCREEN_WIDTH-40)/count;
		_pageController.delegate	  = self;
		_pageController.dataSource	= self;
		[self addChildViewController:_pageController];
		if (count == 1)
		{
			_pageController.menuHeight = 0;
		}
		else
		{
			_pageController.menuHeight = 45;
		}
		_pageController.menuBGColor		  = [UIColor whiteColor];
		_pageController.pageAnimatable	= YES;
		_pageController.menuViewStyle	 = 1;
		_pageController.titleSizeSelected = NUI_HELPER.appLargeFontSize;
		_pageController.titleSizeNormal   = NUI_HELPER.appLargeFontSize;
		_pageController.bounces			  = YES;
		//        _pageController.delegate = self;
		_pageController.titleColorNormal   = NUI_HELPER.appDarkGrayColor;
		_pageController.titleColorSelected = NUI_HELPER.appOrangeColor;
		//        _pageController.progressHeight = 2;
		//        _pageController.menuViewBottomSpace = 1;

		_pageController.viewFrame = _page2View.bounds;
		[_page2View addSubview:_pageController.view];
	}
}

- (void)setTags:(NSArray *)tags
{
	for (UIView *subView in _stackView.arrangedSubviews)
	{
		[_stackView removeArrangedSubview:subView];
		[subView removeFromSuperview];
	}
	if (tags.count == 0)
	{
		return;
	}
	for (NSString *tag in tags)
	{
		KSLabel *label = [KSLabel new];
		label.text	 = tag;
		label.nuiClass = @"RoundBgLabel";
		[_stackView addArrangedSubview:label];
	}
}

//更新标的文本信息
- (void)updateLoanInfo
{
	KSFundItemEntity *available = USER_MGR.assets.fund.available;
	_availableAmoutLabel.text   = available.moneyFormat; //[NSString stringWithFormat:@"%@%@", available.moneyFormat, KUnit];//[KSBaseEntity formatAmount:fund.available withUnit:KUnit];

	BOOL loanOpen = NO; /*[_entity isLoanOpen]*/
	;

	_rateLabel.text		= [KSBaseEntity formatAmount:_entity.rate / 100.];
	_durationLabel.text = [_entity getDurationText];
	if ([_entity isNewBee])
	{
		loanOpen			  = [_nbEntity isCanInvest];
		_progressBar.hidden   = YES;
		_leftAmountLabel.text = [KSBaseEntity formatAmountNotFloat:_nbEntity.newbeeAmount];
		//_ruleLabel.text = [NSString stringWithFormat:@"%ld元起投", _entity.investRule.minAmount];
		//_investTextField.placeholder = [NSString stringWithFormat:@"%ld元起投", _entity.investRule.minAmount];
		//设置默认的输入框信息
		NSString *ph	= [self investMoneyInputPlaceHolderWith:_entity.investRule.minAmount projectBalance:-1];
		_ruleLabel.text = ph;
		[self setInvestTextFieldPlaceHolder:ph];
	}
	else
	{
		loanOpen			  = [_entity isLoanOpen];
		_progressBar.hidden   = NO;
		_leftAmountLabel.text = [KSBaseEntity formatAmountNotFloat:_entity.amount];
		//_ruleLabel.text = [NSString stringWithFormat:@"%ld元起投, 项目余额%ld元", _entity.investRule.minAmount, _entity.leftAmount];
		//_investTextField.placeholder = [NSString stringWithFormat:@"%ld元起投, 项目余额%ld元", _entity.investRule.minAmount, _entity.leftAmount];

		//设置默认的输入框信息
		NSString *ph	= [self investMoneyInputPlaceHolderWith:_entity.investRule.minAmount projectBalance:_entity.leftAmount];
		_ruleLabel.text = ph;
		[self setInvestTextFieldPlaceHolder:ph];
	}
	_repayMethodLabel.text = [_entity getRepayMethodText];

	//显示标签
	NSMutableArray *tags = [NSMutableArray array];
	//加息标签
	if (_entity.additionalRate > 0)
	{
		NSString *rateTag = [NSString stringWithFormat:@"已加息 +%@%%", [KSBaseEntity formatAmount:_entity.additionalRate / 100.]];
		[tags addObject:rateTag];
	}
	//提前还款标签
	if (_entity.advanceRepayAble)
	{
		[tags addObject:@"可提前还款"];
	}
	//自定议标签
	if (_entity.recommendLabel > 0 && ![_entity isNewBee])
	{

		NSString *customTag = [_entity getTextFormRecommendTag:_entity.recommendLabel];
		if (customTag)
		{
			[tags addObject:customTag];
		}
	}
	[self setTags:tags];

	_progressBar.progress = [_entity getProgress];
	//    _progressBar.hidden = _progressBar.progress == 0;

	NSUInteger minAmount  = 0; // _entity.investRule.minAmount;
	NSUInteger stepAmount = _entity.investRule.stepAmount;
	NSInteger  maxValue   = MIN(_entity.investRule.maxAmount, _entity.leftAmount);
	if ([_entity isNewBee])
	{
		maxValue = _nbEntity.newbeeAmount;
	}
	//为了优化性能. 刻度尺最大只能分成N份
	NSInteger stepValue	= MAX((maxValue - minAmount) / (stepAmount * SLIDER_COLUMNS), 1) * stepAmount;
	_investSlider.minValue = minAmount;
	_investSlider.maxValue = maxValue - maxValue % stepValue; // MIN(_entity.investRule.maxAmount, _entity.leftAmount);//TODO由于collectionview 没有回收内存, 数值会造成OOM, 所以这里先设定最大值. 近期会解决问题

	_investSlider.stepValue = stepValue;

	_investSlider.userInteractionEnabled = loanOpen;
	_investTextField.enabled			 = loanOpen;
	_payAllButton.enabled				 = loanOpen;
	_protrolButton.enabled				 = loanOpen;
	_rechargeButton.enabled				 = loanOpen;
	_checkBox.userInteractionEnabled	 = loanOpen;

	_timerLabel.hidden = YES;
	_statusView.hidden = YES;
	long countdownTime = [_entity getCountdownTime];
	if (countdownTime > 0)
	{
		_timerLabel.hidden	= NO;
		_timerLabel.delegate  = self;
		_timerLabel.timerType = MZTimerLabelTypeTimer;
		[_timerLabel setCountDownTime:countdownTime / 1000];
		[_timerLabel start];
	}
	else
	{
		if (!loanOpen)
		{
			_statusView.hidden		= NO;
			_statusView.statusStyle = (loanOpen ? KSStatusStyleProgress : KSStatusStyleStatus);
			_statusView.statusText  = [_entity getStatusText];
			if (![_nbEntity isCanInvest] && [_entity isNewBee])
				_statusView.statusText = [_nbEntity getNewbeeStatusText];
			_statusView.progress	   = [_entity getProgress];
			_statusView.disable		   = YES; //
		}
	}

	//默认全额投
	//    if (loanOpen && USER_MGR.assets.fund.available > 0) {
	//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(payAllAction:) object:nil];
	//        [self performSelector:@selector(payAllAction:) withObject:nil afterDelay:0.2];
	//    }
}

//计算刻度尺的范围值
- (void)adapterValueScaleSlider:(JKScaleSlider *)slider
{
	NSUInteger minAmount  = 0; // _entity.investRule.minAmount;
	NSUInteger stepAmount = _entity.investRule.stepAmount;
	NSInteger  maxValue   = MIN(_entity.investRule.maxAmount, _entity.leftAmount);
	if ([_entity isNewBee])
	{
		maxValue = _nbEntity.newbeeAmount;
	}

	NSUInteger estimateValue = 0;
	NSUInteger adx			 = 0;
	while (estimateValue < maxValue)
	{
		++adx;
		estimateValue = stepAmount * adx * SLIDER_COLUMNS;
	}

	NSInteger stepValue = stepAmount * adx;
	if (stepValue <= 0)
	{
		stepValue = 1;
	}
	slider.minValue  = minAmount;
	slider.maxValue  = maxValue - maxValue % stepValue; // MIN(_entity.investRule.maxAmount, _entity.leftAmount);//TODO由于collectionview 没有回收内存, 数值会造成OOM, 所以这里先设定最大值. 近期会解决问题
	slider.stepValue = stepValue;
}

//更新投资收益
- (void)updateRevenue
{
	CGFloat value	  = [_investTextField.text floatValue];
	_revenueLabel.text = [_entity getRevenueFromAmount:value];
	_ruleLabel.hidden  = (_investTextField.text.length > 0);
}

/**
 *  显示详情/役资记录视图
 */
- (void)showDetailPage
{
	[self addPageController];
	[_mainScrollView scrollRectToVisible:_page2View.frame animated:YES];
	_investScrollView.mj_footer = nil;
}

/**
 *  显示投资视图
 */
- (void)showInvestPage
{
	_mainScrollView.scrollEnabled = YES;
	[_investScrollView scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(_investScrollView.frame), 10) animated:NO];
	[_mainScrollView scrollRectToVisible:_page1View.frame animated:YES];
}

/**
 *  检测, 只有在invest scrollview已经到滚动到底部时..main scrollview才可以滚动
 */
- (void)checkMainScrollView
{
	//    DEBUGG(@"%s, 111_investScrollView: %@", __FUNCTION__, _investScrollView);
	if (_investScrollView.contentOffset.y + CGRectGetHeight(_investScrollView.frame) > _investScrollView.contentSize.height)
	{
		_mainScrollView.scrollEnabled = YES;
	}
	else
	{
		_mainScrollView.scrollEnabled = NO;
	}
}

/**
 *  @author semny
 *
 *  跳转到开托管账户页面
 */
- (void)turn2OpenAccountPage
{
	//    NSString *imeiStr = USER_SESSIONID;
	//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@&app=1", KOpenAccountPage, imeiStr];
	//NSString *urlStr = [NSString stringWithFormat:@"%@", KOpenAccountPage];

	//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	//    NSInteger selectedIndex = appDelegate.tabbarVC.selectedIndex;
	//    NSInteger type = KSWebSourceTypeInvestDetail;
	//    if (selectedIndex == 2)
	//    {
	//        type = KSWebSourceTypeAccount;
	//    }
	//
	//    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KOpenAccountTradeId data:nil error:nil];
	//    //开托管账户
	//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:type];
	//    openAccountVC.hidesBottomBarWhenPushed = YES;
	//    [self.navigationController pushViewController:openAccountVC animated:YES];
	[KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES];
}

/**
 *  @author semny
 *
 *  生成投资金额输入框固定格式的placeholder
 *
 *  @param start          大于等于0的起投金额
 *  @param projectBalance 项目余额
 *
 *  @return 金额输入框固定格式的placeholder
 */
- (NSString *)investMoneyInputPlaceHolderWith:(NSInteger)start projectBalance:(NSInteger)projectBalance
{
	//    [_textField setValue:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
	NSString *ph = nil;
	if (start < 0)
	{
		return ph;
	}
	if (projectBalance < 0)
	{
		//%ld元起投
		ph = [NSString stringWithFormat:@"%ld元起投　　　　　　　　　　", start];
	}
	else
	{
		//%ld元起投, 项目余额%ld元
		ph = [NSString stringWithFormat:@"%ld元起投, 项目余额%@元", start, [KSBaseEntity formatAmountNotFloat:projectBalance]];
	}
	return ph;
}

/**
 *  @author semny
 *
 *  设置placeholder,并且隐藏
 *
 *  @param placeHolder placeHolder文字
 */
- (void)setInvestTextFieldPlaceHolder:(NSString *)placeHolder
{
	NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:40],
								 NSForegroundColorAttributeName : [UIColor clearColor]};

	NSMutableAttributedString *attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:placeHolder attributes:attributes];
	_investTextField.attributedPlaceholder			 = attributedPlaceholder;
}

#pragma mark - control action

/**
 *  路转到充值
 *
 *  @param available 充值的金额
 */
- (void)rechargeNumber:(NSString *)available
{
	KSRechargeVC *controller			= [[KSRechargeVC alloc] initWithNibName:@"KSRechargeVC" bundle:nil];
	controller.hidesBottomBarWhenPushed = YES;
	controller.type						= KSWebSourceTypeInvestDetail;
	controller.available				= available;
	if (_hasReplenishChrage)
	{
		//controller.actionFlag = @"4";
		controller.actionFlag = KSRechargeTypeBalance;
	}
	else
	{
		controller.actionFlag = KSRechargeTypeOther;
	}

	//去充值之前将标志置为NO，解决历史充值成功回到详情页面然后投资谈差额框去充值然后直接回到详情弹充值成功去投资的alert的问题
	_hasRechargeSuccess = NO;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)shareAction:(id)sender
{
	//分享测试
	//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.kaisafax.com/images/logo_share_kaisa.png"]];
	//    SocialService *socialService = [SocialService sharedInstance];
	//    socialService.platformArray = nil;
	//    [socialService presentShareDialogWithTitle:@"郑志文的投资分享" text:@"亲，我是郑志文，终于让我找到一个靠谱的互联网理财平台，您也快来试试吧！佳兆业金服采用资金托管模式，100元起投，期限灵活，现在注册享受更高投资收益，点击链接注册体验啦！" image:data imageURL:nil URL:@"http://www.kaisafax.com/m/register?ref=XG5XRL" delegate:nil];
}

- (IBAction)textDidEndAction:(id)sender
{

	NSInteger value = [_investTextField.text integerValue];
	//    _investSlider.value = value;
	[_investSlider setValue:value callback:NO];
}

- (IBAction)investAction:(id)sender
{
	//判断用户登录
	BOOL isLogin = [USER_MGR judgeLoginForVC:self];
	if (!isLogin)
	{
		return;
	}

	//判断账户
	if (![USER_MGR.assets isOpenAccount])
	{
		//开通托管账户
		[self turn2OpenAccountPage];
	}
	else
	{
		//输入金额int
		NSString *inputMoneyStr = _investTextField.text;
		NSInteger value			= inputMoneyStr.integerValue;
		//判断输入格式
		//判断是否 输入金额>=起投金额
		NSString *minAmountStr = [KSBaseEntity formatFloat:(CGFloat) _entity.investRule.minAmount];
		BOOL	  flag		   = [KSBaseEntity isValue1:minAmountStr greaterValue2:inputMoneyStr];
		if (flag)
		{
			[self showLGAlertTitle:@"投资金额不得小于起投金额"];
			return;
		}

		//判断是否满足投资金额间隔金额限制，比如间隔100，将格式化后的金额设置到输入框
		NSInteger stepAmount = _entity.investRule.stepAmount;
		if (value % stepAmount != 0)
		{
			[self showLGAlertTitle:[NSString stringWithFormat:@"投标金额必须为%ld整数倍", (long) stepAmount]];
			return;
		}

		//根据新手标判断项目余额
		NSUInteger loanLeftTotal = [_entity isNewBee] ? _entity.amount : _entity.leftAmount;

		//可投金额=MIN(项目余额，最大可投金额)
		NSUInteger loanAvailableTotal = MIN(loanLeftTotal, _entity.investRule.maxAmount);

		//判断是否 输入金额<=可投金额
		if (value > loanAvailableTotal)
		{
			[self showLGAlertTitle:@"投资金额不得超出可投金额"];
			return;
		}

		//用户可用余额
		NSString *available = USER_MGR.assets.fund.available.money;
		//全额投 全额投金额=MIN(用户可用余额，可投金额) 在全额投输入逻辑方法判断
		NSInteger availabelAmount	= MIN(available.integerValue, loanAvailableTotal);
		NSString *availabelAmountStr = [KSBaseEntity formatFloat:availabelAmount];
		//差额投 输入金额>账户余额
		//余额不足
		if ([KSBaseEntity isValue1:inputMoneyStr greaterValue2:availabelAmountStr])
		{
			[self showAlertRchargeMoney:value available:availabelAmount];
			return;
		}
		//        if (value > availabelAmount)
		//        {
		//            [self showAlertRchargeMoney:value available:availabelAmount];
		//            return;
		//        }
		AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
		NSInteger selectedIndex  = appDelegate.tabbarVC.selectedIndex;
		NSInteger type			 = KSWebSourceTypeInvestDetail;
		if (selectedIndex == 2)
		{
			type = KSWebSourceTypeAccount;
		}
		//普通投 输入金额<=账户余额
		//        [KSWebVC pushInController:self.navigationController urlString:KInvestBidPage title:@"投标" params:@{@"loanId" : @(_entity.ID), @"amount" : _investTextField.text} type:type];
		[self gotoInvestBidPageWith:self.entity.ID amount:self.investTextField.text type:type];
	}
}

- (void)gotoInvestBidPageWith:(long long)loanId amount:(NSString *)amount type:(NSInteger)type
{
	if (loanId <= 0 || !amount || amount.length <= 0)
	{
		return;
	}
	NSString *	actionFlag = @"test";
	NSDictionary *dict		 = @{ kLoanIdKey : @(loanId),
							kAmountKey : amount,
							kActionFlagKey : actionFlag };
	NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KInvestBidTradeId data:dict error:nil];
	NSString *title		= @"投标";
	[KSWebVC pushInController:self.navigationController urlString:urlString title:title type:type];
}

- (IBAction)redpackAction:(id)sender
{
	//    UIViewController *controller = [[KSRedpacketVC alloc] initWithNibName:@"KSRedpacketVC" bundle:nil];
	//    [self.navigationController pushViewController:controller animated:YES];
	if (![USER_MGR isLogin])
	{
		[USER_MGR judgeLoginForVC:self];
		return;
	}

	if ([_entity isLoanOpen])
	{
		KSWholeNewRedPacketVC *wholeVC = [[KSWholeNewRedPacketVC alloc] init];
		wholeVC.type				   = KSWebSourceTypeInvestDetail;
		//        wholeVC.selectIndex = 1;
		[self.navigationController pushViewController:wholeVC animated:YES];
	}
}

- (IBAction)rechargeAction:(id)sender
{
	if (![USER_MGR isLogin])
	{
		[USER_MGR judgeLoginForVC:self];
		return;
	}
	[self rechargeNumber:_investTextField.text];
}

//全额投
- (IBAction)payAllAction:(id)sender
{
	//判断用户登录
	BOOL isLogin = [USER_MGR judgeLoginForVC:self];
	if (!isLogin)
	{
		return;
	}

	//用户可用余额
	NSString *availabelAmountStr = USER_MGR.assets.fund.available.money;
	NSString *zeroStr			 = [KSBaseEntity formatFloat:0.0f];
	BOOL	  flag				 = [KSBaseEntity isValue1:availabelAmountStr greaterValue2:zeroStr];
	if (!flag)
	{
		[self showAlertWithoutMoney];
		return;
	}

	//账户余额小于最小投资金额的时候弹出提示
	NSInteger available = availabelAmountStr.integerValue;
	if (available < _entity.investRule.minAmount)
	{
		[self showAlertNoMoreAssetsMoney];
		return;
	}

	//可投金额=MIN(项目余额，最大可投金额)
	//全额投 全额投金额=MIN(用户可用余额，可投金额) 在全额投输入逻辑方法判断
	NSUInteger total = 0;
	if ([_entity isNewBee])
	{
		//        total = MIN(_nbEntity.newbeeAmount, available);
		total = [_nbEntity getCanInvestMaxInAvailable:USER_MGR.assets.fund.available.money.longLongValue];
	}
	else
	{
		total = [_entity getCanInvestMaxInAvailable:USER_MGR.assets.fund.available.money.longLongValue];
	}
	_investSlider.value = total;
	//因为刻度尺的原因..这里要强制设定一个不在刻度尺不在的范围内的值
	_investTextField.text = [NSString stringWithFormat:@"%ld", total];
}

#pragma mark - 理财计算器
- (IBAction)calcAction:(UIButton *)sender
{

	UIView *coverView				= [[UIView alloc] init];
	coverView.frame					= CGRectMake(0, navBarHeight, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT - navBarHeight);
	coverView.backgroundColor		= [UIColor colorWithWhite:0.f alpha:0.2];
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCalcator)];
	[coverView addGestureRecognizer:gesture];

	CGRect			 frame			   = CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 332);
	KSCalcuatorView *finanCaluatorView = ViewFromNib(@"KSCalcuatorView", 0);
	finanCaluatorView.frame			   = frame;
	[finanCaluatorView inteType];
	//    finanCaluatorView.delegate = self;
	//    [self sortAnimation];
	UITapGestureRecognizer *gestureC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
	[finanCaluatorView addGestureRecognizer:gestureC];
	//    self.finanCaluatorView = finanCaluatorView;
	_finanCaluatorView			  = finanCaluatorView;
	_finanCaluatorView.periodType = KSPeriodTypeMax;
	_finanCaluatorView.methodType = KSMethodTypeMax;

	UIWindow *window = KEY_WINDOW;
	[coverView addSubview:finanCaluatorView];
	[window addSubview:coverView];

	//
	self.title = @"收益计算器";

	[self setNavLeftButtonByImage:@"update_close_icon" selectedImageName:@"update_close_icon" navBtnAction:@selector(closeCalcator)];

	//设置第一响应者
	[_finanCaluatorView.investTF becomeFirstResponder];

	//监听收益变化
	@WeakObj(self);

	[[RACSignal combineLatest:@[_finanCaluatorView.investTF.rac_textSignal,
                                _finanCaluatorView.periodTF.rac_textSignal,
                                _finanCaluatorView.rateTF.rac_textSignal,
                                RACObserve(_finanCaluatorView, periodType),
                                RACObserve(_finanCaluatorView, methodType),
                                ]
                       reduce:^(NSString *invest, NSString *period, NSString *rate,NSInteger perType,NSInteger methodType){
		//                           INFO(@"name:%@ phone:%@ relation:%@",name,phone,relationshipContent);
		//                           return @(name.length > 0 && phone.length > 0 && relationshipContent.length>0);
		return @(invest.length > 0 && period.length > 0 && rate.length > 0 && perType != KSPeriodTypeMax && methodType != KSMethodTypeMax);
                       }]
     subscribeNext:^(NSNumber *res){
         {
//             _saveBtn.enabled = [res boolValue];
             if([res boolValue])
             {
                 //算预期收益
                 [weakself caluatorEarningsWithInvest:_finanCaluatorView.investTF.text peroid:_finanCaluatorView.periodTF.text rate:_finanCaluatorView.rateTF.text peroidType:_finanCaluatorView.periodType methodType:_finanCaluatorView.methodType];
}
}
}];

//密码
RAC(_finanCaluatorView.investTF, text) = [_finanCaluatorView.investTF.rac_textSignal map:^id(NSString *value) {
	NSString *newValue = value;
	if (value.length >= KInvestMaxLength)
	{
		_finanCaluatorView.incomeLabel.text = @"哥，这回真算不过来了";
		newValue							= [value substringToIndex:KInvestMaxLength - 1];
	}
	//        weakself.pw = newValue;
	return newValue;
}];
}

- (void)caluatorEarningsWithInvest:(NSString *)invest peroid:(NSString *)period rate:(NSString *)rate peroidType:(NSInteger)peroidType methodType:(NSInteger)methodType
{
	if (invest == nil || period == nil || rate == nil || peroidType == KSPeriodTypeMax || methodType == KSMethodTypeMax)
		return;

	if (methodType != KSMethodTypeOnce && peroidType == KSPeriodTypeDay)
	{
		[_finanCaluatorView makeToast:kCannotSelectError duration:3.0 position:CSToastPositionCenter];
		return;
	}
	CGFloat P  = [invest floatValue];
	CGFloat DM = [period floatValue];
	CGFloat R  = [rate floatValue];

	//一次性还款
	if (peroidType == KSPeriodTypeDay && methodType == KSMethodTypeOnce)
	{
		_finanCaluatorView.incomeLabel.text = [NSString stringWithFormat:@"%.2f", P * R * DM / 365 / 100];
	}
	double value = pow((1 + (R / 12 / 100)), DM);

	if (peroidType == KSPeriodTypeMonth)
	{
		switch (methodType)
		{
		case KSMethodTypeBX:
			_finanCaluatorView.incomeLabel.text = [NSString stringWithFormat:@"%.2f", (((P * (R / 12 / 100) * value) / (value - 1)) * DM) - P];
			break;
		case KSMethodTypeBJ:
			_finanCaluatorView.incomeLabel.text = [NSString stringWithFormat:@"%.2f", P * R * (DM + 1) / 24 / 100];
			break;
		case KSMethodTypeFirX:
		case KSMethodTypeOnce:
			_finanCaluatorView.incomeLabel.text = [NSString stringWithFormat:@"%.2f", P * R * DM / 12 / 100];
			break;

		default:
			break;
		}
	}
}

- (void)closeCalcator
{
	UIWindow *window = KEY_WINDOW;
	[[window.subviews lastObject] removeFromSuperview];

	self.title = _entity.title;

	[self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left"];
}

- (void)doNothing
{
}
//显示投资协议
- (IBAction)showProtrolAction:(id)sender
{
	if (![USER_MGR isLogin])
	{
		[USER_MGR judgeLoginForVC:self];
		return;
	}
	if (_entity.contract.length > 0)
	{
		NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KInvestProtocolPage data:@{ @"contractId" : _entity.contract } error:nil];
		NSString *title  = @"投资协议";
		[KSWebVC pushInController:self.navigationController urlString:urlStr title:title type:KSWebSourceTypeInvestDetail];
		//        [KSWebVC pushInController:self.navigationController urlString:KInvestProtocolPage title:@"投资协议" params:@{@"template" : _entity.contract} type:KSWebSourceTypeInvestDetail  runJS:NO];
	}
}
#pragma mark - alert

/**
 *  显示差额充值成功提示窗
 */
- (void)showRechargeSuccessAlert
{
	//    @WeakObj(self);
	//    LGAlertView *alertView  = [[LGAlertView alloc] initWithTitle:@"充值"
	//                                                         message:@"充值成功"
	//                                                           style:LGAlertViewStyleAlert
	//                                                    buttonTitles:nil
	//                                               cancelButtonTitle:@"取消"
	//                                          destructiveButtonTitle:@"去投资"];
	//
	//    alertView.destructiveHandler = ^(LGAlertView *alertView) {
	//        [weakself investAction:nil];
	//    };
	//    alertView.destructiveButtonTitleColor = NUI_HELPER.appOrangeColor;
	//    [alertView showAnimated:YES completionHandler:nil];

	/**
     *  @author semny
     *
     *  替换分散的LGAlert使用的地方
     */
	NSString *title		  = KRechargeTitle;
	NSString *message	 = @"充值成功";
	NSString *cancelTitle = @"取消";
	NSString *okTitle	 = @"去投资";
	@WeakObj(self);
	[self showLGAlertTitle:title
				   message:message
		 cancelButtonTitle:cancelTitle
			 okButtonTitle:okTitle
			   cancelBlock:nil
				   okBlock:^(id alert) {
					   [weakself investAction:nil];
				   }];
}

//显示差额充值提示窗
- (void)showAlertWithoutMoney
{

	/**
     *  @author semny
     *
     *  替换分散的LGAlert使用的地方
     */
	NSString *title		  = @"充值提示";
	NSString *message	 = @"您现在的可用余额不足, 是否马上充值?";
	NSString *cancelTitle = nil;
	NSString *okTitle	 = @"充值";
	@WeakObj(self);
	[self showLGAlertTitle:title
				   message:message
		 cancelButtonTitle:cancelTitle
			 okButtonTitle:okTitle
			   cancelBlock:nil
				   okBlock:^(id alert) {
					   [weakself rechargeAction:nil];
				   }];
}

/**
 *  显示余额不足提示框
 *
 *  @param totalAmount 当前订单金额
 *  @param available   账户余额
 */
- (void)showAlertRchargeMoney:(NSUInteger)totalAmount available:(CGFloat)available
{
	//    NSMutableString *string = [NSMutableString string];
	//
	//    [string appendFormat:@"当前订单:%@元\n", [KSBaseEntity formatAmount:totalAmount]];
	//    [string appendFormat:@"账户余额:%@元\n",[ KSBaseEntity formatAmount:available]];
	//    [string appendFormat:@"还需支付:%@元\n",[ KSBaseEntity formatAmount:(totalAmount - available)]];

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
	NSString *	str0							= [NSString stringWithFormat:@"当前订单:%@元\n账户余额:%@元\n还需支付:", [KSBaseEntity formatAmount:totalAmount], [KSBaseEntity formatAmount:available]];
	NSDictionary *dictAttr0						= @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};
	NSAttributedString *attr0					= [[NSAttributedString alloc] initWithString:str0 attributes:dictAttr0];
	[attributedString appendAttributedString:attr0];

	NSString *			str1	  = [NSString stringWithFormat:@"%@元", [KSBaseEntity formatAmount:(totalAmount - available)]];
	NSDictionary *		dictAttr1 = @{NSForegroundColorAttributeName : NUI_HELPER.appOrangeColor};
	NSAttributedString *attr1	 = [[NSAttributedString alloc] initWithString:str1 attributes:dictAttr1];
	[attributedString appendAttributedString:attr1];

	//段落样式
	NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
	//行间距
	paragraph.lineSpacing = 10;
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attributedString.length)];

	UILabel *label		 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
	label.font			 = [UIFont systemFontOfSize:16];
	label.numberOfLines  = 0;
	label.attributedText = attributedString;

	/**
     *  @author semny
     *
     *  替换分散的LGAlert使用的地方
     */
	NSString *title		  = @"余额不足";
	NSString *message	 = nil;
	NSString *cancelTitle = @"取消";
	NSString *okTitle	 = @"去充值";
	@WeakObj(self);
	[self showLGAlertTitle:title
				   message:message
					  view:label
		 cancelButtonTitle:cancelTitle
			 okButtonTitle:okTitle
			   cancelBlock:nil
				   okBlock:^(id alert) {
					   weakself.hasReplenishChrage = YES;
					   [weakself rechargeNumber:[KSBaseEntity formatFloat:totalAmount - available]];
				   }];
}

//显示余额小于起投金额
- (void)showAlertNoMoreAssetsMoney
{
	NSString *title = @"您的可用余额小于起投金额";
	[self showLGAlertTitle:title];
}

#pragma mark - ScrollView Delegate

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    //DEBUGG(@"%s, _mainScrollView: %@", __FUNCTION__, _mainScrollView);
//    if (decelerate && _mainScrollView.scrollEnabled)
//    {
//        //DEBUGG(@"%s, 111_mainScrollView: %@", __FUNCTION__, _mainScrollView);
//        if (_mainScrollView.contentOffset.y >= 44)
//        {
//            //DEBUGG(@"%s, 222_mainScrollView: %@", __FUNCTION__, _mainScrollView);
//
//        }
//    }
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (_investScrollView.mj_footer != nil) {
//        return;
//    }
//
//    [self checkMainScrollView];
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

	NSInteger page				  = (_mainScrollView.contentOffset.y + (0.5f * CGRectGetHeight(_mainScrollView.frame))) / CGRectGetHeight(_mainScrollView.frame);
	_mainScrollView.scrollEnabled = page == 0;
	CGRect rect					  = page == 0 ? _page1View.frame : _page2View.frame;
	[_mainScrollView scrollRectToVisible:rect animated:YES];
}

#pragma mark - JKScaleSliderDelegate

- (NSString *)scaleSlider:(JKScaleSlider *)slider titleAtValue:(NSInteger)value
{
	//1000的倍数才显示title
	NSUInteger row = (value - slider.minValue) / slider.stepValue;
	//    INFO(@"scale slider = %ld", row);
	if (row % 10 == 0)
	{
		NSString *title = [NSString stringWithFormat:@"%ld", value];

		return title;
	}
	return nil;
}

- (void)scaleSlider:(JKScaleSlider *)slider didChangeValue:(NSInteger)value
{
	if (value == 0)
	{
		_investTextField.text = nil;
	}
	else
	{
		_investTextField.text = [NSString stringWithFormat:@"%ld", value];
	}
}

#pragma mark - WMPageController Delegate

- (void)pageController:(WMPageController *)pageController lazyLoadViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
	@WeakObj(self);
	if ([viewController isKindOfClass:[KSWebVC class]])
	{
		KSWebVC *vc						= (KSWebVC *) viewController;
		vc.webView.scrollView.mj_header = [self dropToTopHeader:^{
			[weakself showInvestPage];
			[vc.webView.scrollView.mj_header endRefreshing];
		}];
	}
	else if ([viewController isKindOfClass:[KSInvestHistoryVC class]])
	{
		KSInvestHistoryVC *vc  = (KSInvestHistoryVC *) viewController;
		vc.tableView.mj_header = [self dropToTopHeader:^{
			[weakself showInvestPage];
			[vc.tableView.mj_header endRefreshing];
		}];
	}
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
	return self.titleArray.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
	UIViewController *itemVC = nil;
	//    @WeakObj(self);
	if (index == 0)
	{
		NSMutableDictionary *param = [NSMutableDictionary dictionary];
		param[kLoanIdKey]		   = @(_entity.ID);
		NSString *urlStr		   = [KSRequestBL createGetRequestURLWithTradeId:KInvestProjectDetailPage data:param error:nil];

		KSWebVC *vc = [[KSWebVC alloc] initWithUrl:urlStr title:nil type:KSWebSourceTypeInvestDetail];
		//vc.url = [NSURL URLWithString:KInvestProjectDetailPage(_entity.ID)];
		if ([_entity isNewBee] || [USER_MGR isLogin])
		{
			[vc reloadRequest];
		}
		else
		{
			[vc setNeedLogin:YES];
		}
		//        vc.webView.scrollView.mj_header = [self dropToTopHeader:^{
		//            [weakself showInvestPage];
		//            [vc.webView.scrollView.mj_header endRefreshing];
		//        }];
		itemVC = vc;
	}
	else
	{
		KSInvestHistoryVC *vc = [[KSInvestHistoryVC alloc] init]; //(KSInvestHistoryVC *)viewController;
		vc.loanId			  = _entity.ID;
		//        vc.tableView.mj_header = [self dropToTopHeader:^{
		//            [weakself showInvestPage];
		//            [vc.tableView.mj_header endRefreshing];
		//        }];
		itemVC = vc;
	}

	return itemVC;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index
{
	NSString *string = nil;
	if (index >= 0 && index < self.titleArray.count)
	{
		string = self.titleArray[index];
	}
	return string;
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
	DEBUGG(@"%@ %@", viewController, info);
}

#pragma mark - MJRefreshStateHeader
- (MJRefreshStateHeader *)dropToTopHeader:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
	MJRefreshStateHeader *header	   = [MJRefreshStateHeader headerWithRefreshingBlock:refreshingBlock];
	header.lastUpdatedTimeLabel.hidden = YES;
	[header setTitle:@"向下拖动, 查看标的" forState:MJRefreshStateIdle];
	[header setTitle:@"向下拖动, 查看标的" forState:MJRefreshStatePulling];
	[header setTitle:@"向下拖动, 查看标的" forState:MJRefreshStateRefreshing];
	[header setTitle:@"向下拖动, 查看标的" forState:MJRefreshStateWillRefresh];
	header.stateLabel.nuiClass = @"AppSmallLightGrayLabel";

	UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
	iconImageView.image		   = UIImageFromName(@"ic_drop_down");
	[header addSubview:iconImageView];
	@WeakObj(iconImageView);
	[RACObserve(header.stateLabel, frame) subscribeNext:^(NSValue *value) {
		CGRect r				 = value.CGRectValue;
		weakiconImageView.center = CGPointMake(CGRectGetMidX(r) - 72, CGRectGetMidY(r));
	}];

	return header;
}

#pragma mark -  KSBLDelegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	id entity = result.body;
	INFO(@"finishedHandle result = %@", NSStringFromClass([entity class]));
	if ([entity isKindOfClass:[KSLoanDetailEntity class]])
	{
		//        BOOL isNewbee = [_entity isNewBee];
		//        NSInteger newbeeAmount = _entity.amount;
		KSLoanDetailEntity *detailEntity = (KSLoanDetailEntity *) entity;
		KSLoanItemEntity *  detailLoan   = detailEntity.loan;
		detailLoan.contract				 = detailEntity.contract;
		//        detailLoan.newbee = isNewbee;
		//        detailLoan.newbeeAmount = newbeeAmount;
		self.entity = detailLoan;

		[_entity calcCountdownTime];
		[self updateLoanInfo];
	}
	if ([entity isKindOfClass:[KSNewbeeEntity class]])
	{
		KSNewbeeEntity *newbeeEntity = (KSNewbeeEntity *) entity;
		newbeeEntity.loan.contract   = _entity.contract;
		//        newbeeEntity.loan.newbeeAmount = newbeeEntity.amount;
		//        newbeeEntity.loan.newbee = YES;
		self.entity   = newbeeEntity.loan;
		self.nbEntity = newbeeEntity;
		[_entity calcCountdownTime];
		[self updateLoanInfo];
	}
}

#pragma mark - MZTimerLabelDelegate

- (void)timerLabel:(MZTimerLabel *)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
	_entity.status = 0 /*@"OPEN"*/;
	[self updateLoanInfo];
}

- (NSString *)timerLabel:(MZTimerLabel *)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time
{
	int second = (int) time % 60;
	int minute = ((int) time / 60) % 60;
	int hours  = time / 3600;
	return [NSString stringWithFormat:@"抢标倒计时  %02d:%02d:%02d", hours, minute, second];
}

#pragma mak - BEMCheckBox delegate

- (void)didTapCheckBox:(BEMCheckBox *)checkBox
{
	self.hasReadProtrol = checkBox.on;
}

@end
