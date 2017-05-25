//
//  KSAutoLoanSettingVC.m
//  kaisafax
//
//  Created by Jjyo on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAutoLoanSettingVC.h"
#import "AMPopTip.h"
#import "JSONKit.h"
#import "KSAmountTextField.h"
#import "KSAutoInvestBL.h"
#import "KSFileUtil.h"
#import "KSInvestAutoBL.h"
#import "KSInvestAutoInfoEntity.h"
#import "KSLabel.h"
#import "KSOpenAccountBL.h"
#import "KSOpenAccountVC.h"
#import "KSWebVC.h"
#import "YYText.h"

@interface KSAutoLoanSettingVC () <KSBLDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UITextField *minRateTextField;
@property (nonatomic, weak) IBOutlet UITextField *maxRateTextField;
@property (nonatomic, weak) IBOutlet UITextField *minDaysTextField;
@property (nonatomic, weak) IBOutlet UITextField *maxDaysTextField;
@property (nonatomic, weak) IBOutlet KSAmountTextField *amountTextField;
@property (nonatomic, weak) IBOutlet KSAmountTextField *amountMaxTextField;
@property (nonatomic, weak) IBOutlet UITextField *reservedAmountTextField;

@property (nonatomic, weak) IBOutlet UIButton *tipsButton;

@property (nonatomic, weak) IBOutlet UIButton *dayTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *monthTypeButton;

@property (nonatomic, weak) IBOutlet UIButton *equalInstallmentButton; //等额本息
@property (nonatomic, weak) IBOutlet UIButton *equalPrincipalButton;   //等额本金
@property (nonatomic, weak) IBOutlet UIButton *bulletRepaymentButton;  //一次性还款
@property (nonatomic, weak) IBOutlet UIButton *interestButton;		   //先息后本

@property (nonatomic, weak) IBOutlet UIView *repayView;

@property (nonatomic, strong) AMPopTip *popTip;

@property (nonatomic, strong) KSInvestAutoBL *autoBL;

@end

@implementation KSAutoLoanSettingVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = @"投标设置";

	[self setNavRightButtonByImage:@"ic_help" selectedImageName:nil navBtnAction:@selector(helpAction)];

	self.popTip					   = [AMPopTip popTip];
	self.popTip.shouldDismissOnTap = YES;
	self.popTip.popoverColor	   = UIColorFromHex(0xfaea92);
	self.popTip.edgeMargin		   = 5;
	self.popTip.offset			   = 2;
	self.popTip.edgeInsets		   = UIEdgeInsetsMake(0, 10, 0, 10);
	self.popTip.shouldDismissOnTap = YES;

	_autoBL			 = [[KSInvestAutoBL alloc] init];
	_autoBL.delegate = self;

	KSInvestAutoInfoEntity *entity = [self getAutoloanCacheEntity];
	if (entity)
	{
		[self updateUI:entity];
	}

	[self addKVO];
}

- (void)addKVO
{
	@WeakObj(self);

	[[_equalInstallmentButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		_equalInstallmentButton.selected ^= 1;
	}];

	[[_equalPrincipalButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		_equalPrincipalButton.selected ^= 1;
	}];

	[[_bulletRepaymentButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		_bulletRepaymentButton.selected ^= 1;
	}];

	[[_interestButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		_interestButton.selected ^= 1;
	}];

	[[_dayTypeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		if (!_dayTypeButton.selected)
		{
			[weakself updateDurType:KSAutoLoanDurationTypeDay];
		}
	}];

	[[_monthTypeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		if (!_monthTypeButton.selected)
		{
			[weakself updateDurType:KSAutoLoanDurationTypeMonth];
		}
	}];

	[[_tipsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
		[weakself showTips];
	}];
}

- (void)updateDurType:(KSAutoLoanDurationType)type
{
	_dayTypeButton.selected   = type == KSAutoLoanDurationTypeDay;
	_monthTypeButton.selected = type == KSAutoLoanDurationTypeMonth;

	if (type == KSAutoLoanDurationTypeDay)
	{
		_minDaysTextField.text = @"1";
		_maxDaysTextField.text = @"720";
	}
	else
	{
		_minDaysTextField.text = @"1";
		_maxDaysTextField.text = @"36";
	}
}

- (void)showTips
{
	NSString *tipsString = @"为符合以月为单位投资期限标的, 系统都会按照1月=30天进行折算";
	//先将tipsbutton转换成self.view的相对坐标
	CGRect rectInView = [_contentView convertRect:_tipsButton.frame toView:self.view];

	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:tipsString];
	[attrString yy_setColor:NUI_HELPER.appDarkGrayColor range:NSMakeRange(0, tipsString.length)];
	[attrString yy_setTextHighlightRange:[tipsString rangeOfString:@"1月=30"] color:NUI_HELPER.appOrangeColor backgroundColor:NUI_HELPER.appLightGrayColor userInfo:nil];
	[self.popTip showAttributedText:attrString direction:AMPopTipDirectionDown maxWidth:240 inView:self.view fromFrame:rectInView];
}

- (void)updateUI:(KSInvestAutoInfoEntity *)entity
{

	_minRateTextField.text = [entity.autoInvest getMinRateText];
	_maxRateTextField.text = [entity.autoInvest getMaxRateText];

	_minDaysTextField.text = [NSString stringWithFormat:@"%@", @(entity.autoInvest.minDays)];
	_maxDaysTextField.text = [NSString stringWithFormat:@"%@", @(entity.autoInvest.maxDays)];

	_amountTextField.text	= [NSString stringWithFormat:@"%@", @(entity.autoInvest.minAmount)];
	_amountMaxTextField.text = [NSString stringWithFormat:@"%@", @(entity.autoInvest.maxAmount)];

	_reservedAmountTextField.text = [entity.autoInvest getReservedAmountText];
	_monthTypeButton.selected	 = entity.autoInvest.durType == KSAutoLoanDurationTypeMonth;
	_dayTypeButton.selected		  = entity.autoInvest.durType == KSAutoLoanDurationTypeDay;

	_equalInstallmentButton.selected = entity.autoInvest.isEQUAL_INSTALLMENT;
	_equalPrincipalButton.selected   = entity.autoInvest.isEQUAL_PRINCIPAL;
	_bulletRepaymentButton.selected  = entity.autoInvest.isBULLET_REPAYMENT;
	_interestButton.selected		 = entity.autoInvest.isINTEREST;

	if (MAIN_BOUNDS_SCREEN_WIDTH <= 320)
	{
		_equalInstallmentButton.nuiClass = @"AutoLoanSelectedButton2";
		_equalPrincipalButton.nuiClass   = @"AutoLoanSelectedButton2";
		_bulletRepaymentButton.nuiClass  = @"AutoLoanSelectedButton2";
		_interestButton.nuiClass		 = @"AutoLoanSelectedButton2";
	}
}

#pragma mark - help

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
	//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:KSWebSourceTypeAutoLoanSetting];
	//    openAccountVC.hidesBottomBarWhenPushed = YES;
	//    [self.navigationController pushViewController:openAccountVC animated:YES];

	[KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeAutoLoanSetting];
}

- (IBAction)saveAction:(id)sender
{
	NSString *minRate = _minRateTextField.text;
	NSString *maxRate = _maxRateTextField.text;

	NSInteger minAmount = [_amountTextField getAmount];
	NSInteger maxAmount = [_amountMaxTextField getAmount];

	NSInteger minDays = [_minDaysTextField.text integerValue];
	NSInteger maxDays = [_maxDaysTextField.text integerValue];

	NSString *reservedAmount = _reservedAmountTextField.text;

	NSInteger durType = _dayTypeButton.selected ? KSAutoLoanDurationTypeDay : KSAutoLoanDurationTypeMonth;

	NSInteger repayMethodIndex = 0;
	if (_bulletRepaymentButton.selected)
	{
		repayMethodIndex |= 1;
	}
	if (_interestButton.selected)
	{
		repayMethodIndex |= 2;
	}
	if (_equalInstallmentButton.selected)
	{
		repayMethodIndex |= 4;
	}
	if (_equalPrincipalButton.selected)
	{
		repayMethodIndex |= 8;
	}

	if ([KSBaseEntity isValue1:minRate lessValue2:@"1"] || [KSBaseEntity isValue1:maxRate greaterValue2:@"24"] || [KSBaseEntity isValue1:minRate greaterValue2:maxRate])
	{
		[self showToastWithTitle:@"投资利率范围为:1% ~ 24%"];
		return;
	}

	if (durType == KSAutoLoanDurationTypeDay && (minDays <= 0 || maxDays > 720 || minDays > maxDays || maxDays == 0))
	{
		[self showToastWithTitle:@"投资期限范围为:1 ~ 720天"];
		return;
	}

	if (durType == KSAutoLoanDurationTypeMonth && (minDays <= 0 || maxDays > 36 || minDays > maxDays || maxDays == 0))
	{
		[self showToastWithTitle:@"投资期限范围为:1 ~ 36月"];
		return;
	}

	if (minAmount < 100 || maxAmount > 10000000 || minAmount > maxAmount)
	{
		[self showToastWithTitle:@"投资金额为:100 ~ 10000000之间"];
		return;
	}

	if ([KSBaseEntity isValue1:reservedAmount lessValue2:@"0"] || [KSBaseEntity isValue1:reservedAmount greaterValue2:@"10000000"])
	{
		[self showToastWithTitle:@"账户保留金额范圈为:0 ~ 10000000之间"];
		return;
	}

	if (repayMethodIndex == 0)
	{
		[self showToastWithTitle:@"至少选择一种还款方式"];
		return;
	}

	//处理年化利率
	NSDecimalNumber *minRateDec = [NSDecimalNumber decimalNumberWithString:minRate];
	NSDecimalNumber *maxRateDec = [NSDecimalNumber decimalNumberWithString:maxRate];

	// NSNumber 获取
	NSNumber *number1		  = @100;
	NSDecimal decimal		  = [number1 decimalValue];
	NSDecimalNumber *decimal2 = [[NSDecimalNumber alloc] initWithDecimal:decimal];
	//乘100
	minRateDec = [minRateDec decimalNumberByMultiplyingBy:decimal2];
	maxRateDec = [maxRateDec decimalNumberByMultiplyingBy:decimal2];

	// 如果已经开启自动投标，那么调用保存接口
	// 否则调用开启自动投标接口
	if (_autoLoanOpen)
	{
		[self showProgressHUD];

		[self.autoBL doSaveAutoInvestInfoWithMinRate:minRateDec.integerValue
											 maxRate:maxRateDec.integerValue
										   minAmount:minAmount
										   maxAmount:maxAmount
									  reservedAmount:reservedAmount
									repayMethodIndex:repayMethodIndex
											 minDays:minDays
											 maxDays:maxDays
											 durType:durType];
	}
	else
	{

		//未开户, 跳转开户
		if (![USER_MGR.assets isOpenAccount])
		{
			[self turn2OpenAccountPage];
			return;
		}

		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		//最小利率
		params[kMinRateKey] = @(minRateDec.integerValue);
		//最大利率
		params[kMaxRateKey] = @(maxRateDec.integerValue);
		//最小期限
		params[kMinDaysKey] = @(minDays);
		//最大期限
		params[kMaxDaysKey] = @(maxDays);
		//最小金额
		params[kMinAmountKey] = @(minAmount);
		//最大金额
		params[kMaxAmountKey] = @(maxAmount);
		//保留金额
		if (reservedAmount)
		{
			params[kReservedAmountKey] = reservedAmount;
		}
		//还款方式
		params[kRepayMethodIndexKey] = @(repayMethodIndex);
		//期限类型
		params[kDurTypeKey] = @(durType);

		//        @WeakObj(self);
		//        KSWebVC *vc =  [KSWebVC pushInController:self.navigationController urlString:KOpenAutoInvest title:@"开启自动投标" params:params type:KSWebSourceTypeAutoLoan];
		//        [vc setCallback:^(NSDictionary *data) {
		//            [weakself showH5OpenLoanCallbackData:data];
		//        }];
		[self gotoOpenAutoInvestPageWith:params];
	}
}

- (void)gotoOpenAutoInvestPageWith:(NSDictionary *)data
{
	if (!data || data.count <= 0)
	{
		return;
	}

	NSDictionary *params = data;
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
		[self showOperationHUDWithStr:@"设置成功"];
		[NOTIFY_CENTER postNotificationName:KAutoLoanChangeNotificationKey object:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		[self showFailedHUDWithStr:data[@"msg"]];
	}
}

#pragma mark -  KSBLDelegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	INFO(@"%s %@ %@", __FUNCTION__, blEntity, result.body);
	NSString *tradeId = result.tradeId;
	if ([tradeId isEqualToString:KSaveAutoInvestInfoTradeId])
	{
		[self showOperationHUDWithStr:@"设置成功"];
		[NOTIFY_CENTER postNotificationName:KAutoLoanChangeNotificationKey object:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	if (result.errorDescription)
	{
		[self showSimpleAlert:result.errorDescription];
	}
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
	[self hideProgressHUD];
	@WeakObj(self);
	dispatch_async(dispatch_get_main_queue(), ^{
		//隐藏菊花
		[weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
	});
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
