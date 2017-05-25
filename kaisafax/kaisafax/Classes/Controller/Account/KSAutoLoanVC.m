//
//  KSAutoLoanVC.m
//  kaisafax
//
//  Created by Jjyo on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAutoLoanVC.h"
#import "JSONKit.h"
#import "KSAutoInvestBL.h"
#import "KSAutoLoanSettingVC.h"
#import "KSFileUtil.h"
#import "KSInvestAutoBL.h"
#import "KSInvestAutoInfoEntity.h"
#import "KSLabel.h"
#import "KSOpenAccountBL.h"
#import "KSOpenAccountVC.h"
#import "KSWebVC.h"

@interface KSAutoLoanVC () <KSBLDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UIStackView *rowStackView;

@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTypeLabel;   //投资周期, 0天, 1月
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;		   //单笔投标金额
@property (weak, nonatomic) IBOutlet UILabel *reservedAmountLabel; //保留金额
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;		   //排名
@property (weak, nonatomic) IBOutlet UIStackView *repayStackView;
@property (weak, nonatomic) IBOutlet UILabel *repayLabel;

@property (nonatomic, strong) KSInvestAutoBL *autoBL;

@end

@implementation KSAutoLoanVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = KAutoLoanTitle;

	[self setNavRightButtonByImage:@"ic_help" selectedImageName:nil navBtnAction:@selector(helpAction)];

	_autoBL			 = [[KSInvestAutoBL alloc] init];
	_autoBL.delegate = self;

	[_autoBL doGetAutoInvestInfo];

	KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
	if (entity)
	{
		[self updateUI:entity];
	}

	@WeakObj(self);
	[[NOTIFY_CENTER rac_addObserverForName:KAutoLoanChangeNotificationKey object:nil] subscribeNext:^(id x) {
		[weakself.autoBL doGetAutoInvestInfo];
	}];

	//添加刷新控件
	[self tableRefreshGif];
}

/**
 *  设置列表加载刷新数据的图片
 */
- (void)tableRefreshGif
{
	// 添加动画图片的下拉刷新
	[self scrollView:_scrollView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];
}

- (void)refreshing
{
	[_autoBL doGetAutoInvestInfo];
}

- (void)endRefreshing
{
	[self.scrollView.mj_header endRefreshing];
	[self.scrollView.mj_footer endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

//
- (void)autoLoanOpen
{
	BOOL	 on		 = _autoSwitch.on;
	NSArray *subView = _rowStackView.arrangedSubviews;
	for (int i = 1; i < subView.count; i++)
	{
		[subView[i] setAlpha:(on ? 1 : 0.5)];
	}
}

- (void)updateUI:(KSInvestAutoInfoEntity *)entity
{
	_rateLabel.text			  = [entity.autoInvest getAutoRateText];
	_durationLabel.text		  = [entity.autoInvest getAutoDurationText];
	_amountLabel.text		  = [entity.autoInvest getAutoAmountText];
	_reservedAmountLabel.text = [entity.autoInvest getReservedAmountText];
	_durationTypeLabel.text   = [entity.autoInvest getAutoDurationType];
	_rangeLabel.text		  = [entity.autoInvest getRangeText];
	_autoSwitch.on			  = [entity.autoInvest isAutoLoanOpen];

	[self setTags:[entity.autoInvest getRepayMethodStringArray]];
	[self autoLoanOpen];
}

- (void)setTags:(NSArray *)tags
{
	/*
    for (UIView *subView in _repayStackView.arrangedSubviews) {
        [_repayStackView removeArrangedSubview:subView];
        [subView removeFromSuperview];
    }
    if (tags.count == 0) {
        return;
    }
    for (NSString *tag in tags) {
        KSLabel *label = [KSLabel new];
        label.text =  tag;
        label.nuiClass = @"AutoLoanRepayLabel";
        [_repayStackView addArrangedSubview:label];
    }
     */

	if (tags.count > 0)
	{
		_repayLabel.text = [tags componentsJoinedByString:@"/"];
	}
	else
	{
		_repayLabel.text = @"";
	}

	//    _repayLabel.textColor = NUI_HELPER.appOrangeColor;
	//    if (tags.count == 4 && MAIN_BOUNDS_SCREEN_WIDTH <= 320) {
	//        _repayLabel.font = [UIFont systemFontOfSize:NUI_HELPER.appNormalFontSize];
	//    }else
	//    {
	//        _repayLabel.font = [UIFont systemFontOfSize:NUI_HELPER.appNormalFontSize];
	//    }
}

#pragma mark - Action

- (void)helpAction
{
	NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KAutoInvestExplainPage data:nil error:nil];
	[KSWebVC pushInController:self.navigationController urlString:urlStr title:@"帮助说明"];
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
	//    //NSString *urlStr = [NSString stringWithFormat:@"%@", KOpenAccountPage];
	//
	//    //开托管账户
	//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:KSWebSourceTypeAutoLoan];
	//    openAccountVC.hidesBottomBarWhenPushed = YES;
	//    [self.navigationController pushViewController:openAccountVC animated:YES];

	[KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeAutoLoan];
}

- (IBAction)autoLoanSettingAction:(id)sender
{
	KSAutoLoanSettingVC *vc = [[KSAutoLoanSettingVC alloc] init];
	vc.autoLoanOpen			= _autoSwitch.on;
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)openAutoLoanAction:(id)sender
{

	BOOL isaccountNull = ![USER_MGR.assets isOpenAccount];
	if (isaccountNull)
	{
		[self turn2OpenAccountPage];
		return;
	}

	if (_autoSwitch.on)
	{
		//关闭
		//        KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:KCloseAutoInvest title:KAutoLoanOpen params:nil type:KSWebSourceTypeAutoLoan];
		//        [vc setCallback:^(NSDictionary *data)
		//        {
		//            [weakself showH5CloseLoanCallbackData:data];
		//        }];

		[self gotoCloseAutoInvestPage];
	}
	else
	{
		//打开
		KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];

		//        NSInteger repayMethodIndex = entity.autoInvest.repayMethodIndex;
		//        if (entity.repayMethod.BULLET_REPAYMENT) {
		//            repayMethodIndex |= 1;
		//        }
		//        if (entity.repayMethod.INTEREST) {
		//            repayMethodIndex |= 2;
		//        }
		//        if (entity.repayMethod.EQUAL_INSTALLMENT) {
		//            repayMethodIndex |= 4;
		//        }
		//        if (entity.repayMethod.EQUAL_PRINCIPAL) {
		//            repayMethodIndex |= 8;
		//        }

		//        NSDictionary *params = @{@"minRate" : [entity.autoInvest getMinRateText],
		//                                 @"maxRate" : [entity.autoInvest getMaxRateText],
		//                                 @"amount" : @(entity.autoInvest.minAmount),
		//                                 @"amountMax" : @(entity.autoInvest.maxAmount),
		//                                 @"reservedAmount" : [entity.autoInvest getReservedAmountText],
		//                                 @"repayMethodIndex" : @(repayMethodIndex),
		//                                 @"minDays" : @(entity.autoInvest.minDays),
		//                                 @"maxDays" : @(entity.autoInvest.maxDays),
		//                                 @"durType" : @(entity.autoInvest.durType)
		//                                 };
		//
		//
		//        KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:KOpenAutoInvest title:KAutoLoanClose params:params type:KSWebSourceTypeAutoLoan];
		//        [vc setCallback:^(NSDictionary *data) {
		//            [weakself showH5OpenLoanCallbackData:data];
		//        }];

		[self gotoOpenAutoInvestPageWith:entity];
	}
}

- (void)gotoCloseAutoInvestPage
{
	//    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KCloseAutoInvestTradeId data:nil error:nil];
	//    NSString *title = KAutoLoanClose;
	//    KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:urlString title:title type:KSWebSourceTypeAutoLoan];
	//    @WeakObj(self);
	//    [vc setCallback:^(NSDictionary *data){
	//         [weakself showH5CloseLoanCallbackData:data];
	//     }];
	@WeakObj(self);
	[KSAutoInvestBL pushCloseAutoInvestPageWith:self.navigationController
					   hidesBottomBarWhenPushed:YES
										   type:KSWebSourceTypeAutoLoan
									   callback:^(NSDictionary *data) {
										   [weakself showH5CloseLoanCallbackData:data];
									   }];
}

- (void)gotoOpenAutoInvestPageWith:(KSInvestAutoInfoEntity *)entity
{
	if (!entity)
	{
		return;
	}

	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	//最小利率
	NSInteger minRate   = entity.autoInvest.minRate;
	params[kMinRateKey] = @(minRate);
	//最大利率
	NSInteger maxRate   = entity.autoInvest.maxRate;
	params[kMaxRateKey] = @(maxRate);
	//最小期限
	NSInteger minDays   = entity.autoInvest.minDays;
	params[kMinDaysKey] = @(minDays);
	//最大期限
	NSInteger maxDays   = entity.autoInvest.maxDays;
	params[kMaxDaysKey] = @(maxDays);
	//最小金额
	long minAmount		  = entity.autoInvest.minAmount;
	params[kMinAmountKey] = @(minAmount);
	//最大金额
	long maxAmount		  = entity.autoInvest.maxAmount;
	params[kMaxAmountKey] = @(maxAmount);
	//保留金额
	NSString *reservedAmount = entity.autoInvest.reservedAmount;
	if (reservedAmount)
	{
		params[kReservedAmountKey] = reservedAmount;
	}
	//还款方式
	NSInteger repayMethodIndex   = entity.autoInvest.repayMethodIndex;
	params[kRepayMethodIndexKey] = @(repayMethodIndex);
	//期限类型
	NSInteger durType   = entity.autoInvest.durType;
	params[kDurTypeKey] = @(durType);

	//    KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:KOpenAutoInvest title:KAutoLoanClose params:params type:KSWebSourceTypeAutoLoan];
	//    [vc setCallback:^(NSDictionary *data) {
	//        [weakself showH5OpenLoanCallbackData:data];
	//    }];

	//    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KOpenAutoInvestTradeId data:params error:nil];
	//    NSString *title = KAutoLoanOpen;
	//    KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:urlString title:title type:KSWebSourceTypeAutoLoan];
	//    @WeakObj(self);
	//    [vc setCallback:^(NSDictionary *data) {
	//        [weakself showH5OpenLoanCallbackData:data];
	//    }];

	@WeakObj(self);
	[KSAutoInvestBL pushOpenAutoInvestPageWith:self.navigationController
					  hidesBottomBarWhenPushed:YES
										  type:KSWebSourceTypeAutoLoan
										  data:params
									  callback:^(NSDictionary *data) {
										  [weakself showH5OpenLoanCallbackData:data];
									  }];
}

- (void)showH5OpenLoanCallbackData:(NSDictionary *)data
{
	if ([data[@"result"] integerValue] == 1)
	{

		[_autoSwitch setOn:YES animated:YES];

		KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
		entity.autoInvest.status	   = KSAutoLoanStatusActive;
		[self saveAutoloanCacheEntity:entity];
		[self updateUI:entity];
		[self autoLoanOpen];
		[self showOperationHUDWithStr:KSettingSuccessfull];

		[NOTIFY_CENTER postNotificationName:KAutoLoanChangeNotificationKey object:nil];
	}
	else
	{
		[self showFailedHUDWithStr:data[@"msg"]];
	}
}

- (void)showH5CloseLoanCallbackData:(NSDictionary *)data
{
	if ([data[@"result"] integerValue] == 1)
	{
		[_autoSwitch setOn:NO animated:YES];

		KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
		entity.autoInvest.status	   = KSAutoLoanStatusInActive;
		[self saveAutoloanCacheEntity:entity];
		[self updateUI:entity];
		[self autoLoanOpen];
		[self showOperationHUDWithStr:KSettingSuccessfull];
	}
	else
	{
		[self showFailedHUDWithStr:data[@"msg"]];
	}
}

#pragma mark -  KSBLDelegate

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	[self endRefreshing];
	if ([result.tradeId isEqualToString:KGetAutoInvestInfoTradeId])
	{
		KSInvestAutoInfoEntity *entity = result.body;
		if (entity)
		{
			[self updateUI:entity];
			[self saveAutoloanCacheEntity:entity];
		}
		else
		{
			KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
			entity.autoInvest.status	   = KSAutoLoanStatusInActive; //@"INACTIVE";
			[self saveAutoloanCacheEntity:entity];
			[self updateUI:entity];
			[self autoLoanOpen];
		}
	}
	/*
    else if ([result.tradeId isEqualToString:KCloseAutoInvestTradeId])
    {
        [_autoSwitch setOn:NO animated:YES];
        [self autoLoanOpen];
        [self showOperationHUDWithStr:KSettingSuccessfull];
        
        KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
        entity.autoInvest.status = @"INACTIVE";
        [self saveAutoloanCacheEntity:entity];
    }
     */
	else if ([result.tradeId isEqualToString:KSaveAutoInvestInfoTradeId])
	{
		[_autoSwitch setOn:YES animated:YES];
		[self autoLoanOpen];
		[self showOperationHUDWithStr:KSettingSuccessfull];
	}
}

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	[self endRefreshing];
	if (result.errorDescription)
	{
		[self showSimpleAlert:result.errorDescription];
	}
}

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	[self endRefreshing];
}

#pragma mark - cache

- (NSString *)getCacheFileName
{
	return [NSString stringWithFormat:@"%lld.autoloan2.cache", USER_MGR.user.user.userId];
}

- (KSInvestAutoInfoEntity *)getAutoloanCacheEntity
{
	NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
	//如果APP 内没有上一次缓存.刚打开默认的配置文件
	if (!json)
	{
		NSData *data = [KSFileUtil openResouceFile:@"default_autoloan" ofType:@"json"];
		json		 = [data objectFromJSONData];
	}
	return [KSInvestAutoInfoEntity yy_modelWithJSON:json];
}

- (void)saveAutoloanCacheEntity:(KSInvestAutoInfoEntity *)entity
{
	NSDictionary *json = [entity yy_modelToJSONObject];
	[KSFileUtil saveFile:[self getCacheFileName] data:json];
}

@end
