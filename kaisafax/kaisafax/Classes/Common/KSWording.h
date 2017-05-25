//
//  KSWording.h
//  kaisafax
//
//  Created by LazySnail on 15/3/27.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#ifndef kaisafax_KSWording_h
#define kaisafax_KSWording_h


//common
#define KTryRefresh NSLocalizedString(@"TryRefresh",@"pull refresh")
#define KSettingSuccessfull NSLocalizedString(@"SettingSuccessfull",@"Setting Successfull")
#define KUnit   NSLocalizedString(@"Unit",@"RMB")
#define KTTUnit   NSLocalizedString(@"TTUnit",@"Ten Thousand")

#pragma mark - Tabbar
//tabbar的item标题
#define KTabbarHomeTitle    NSLocalizedString(@"TabbarHomeTitle",@"HomeTitle")  //"主页面"
#define KTabbarInvestTitle    NSLocalizedString(@"TabbarInvestTitle",@"InvestTitle")  //"理财"
#define KTabbarAccountTitle    NSLocalizedString(@"TabbarAccountTitle",@"AccountTitle")  //"账户，个人中心"
#define KTabbarMoreTitle    NSLocalizedString(@"TabbarMoreTitle",@"MoreTitle")  //"更多"

//首页
#define KHomeTitleText      NSLocalizedString(@"HomeTitleText",@"kaisafax")
#define KHomeFooterLabel    NSLocalizedString(@"HomeFooterLabel",@"- Discreet investment is suggested for the risk of the stock market -")
#define KHomeNewbeeTitle    NSLocalizedString(@"HomeNewbeeTitle",@"Newbee welfare")
#define KHomeNewbeeSubtitle NSLocalizedString(@"HomeNewbeeSubtitle",@"Limited ¥10,000")
#define KHomeRecomTitle     NSLocalizedString(@"HomeRecomTitle",@"Regular financial management")
#define KHomeOwnerTitle     NSLocalizedString(@"HomeOwnerTitle",@"Owners' welfare")
#define KHomeOwnerTags      NSLocalizedString(@"HomeOwnerTags",@"Owners exclusive")
//京东E卡
#define KJingDongCardTitle  NSLocalizedString(@"JingDongCard",@"JingDong card")
#define KJingDongCardRecord NSLocalizedString(@"JingDongCardRecord",@"JingDong cardrecord")
#define KJDCardfailText            NSLocalizedString(@"JDCardFailText",@"JDcardfail text")
#define KJDCardServiceText            NSLocalizedString(@"JDCardServiceText",@"JDcardservice text")

//登录
#define KLoginUserNameTextFieldPlaceholder    NSLocalizedString(@"LoginUserNameTextFieldPlaceholder",@"user name")
#define KLoginPasswordTextFieldPlaceholder    NSLocalizedString(@"LoginPasswordTextFieldPlaceholder",@"password")
#define KLoginText                            NSLocalizedString(@"LoginText",@"Login")
//登录页面跳转注册的文字
#define KLoginTurn2RegisterText1            NSLocalizedString(@"LoginTurn2RegisterText1",@"no user?")
#define KLoginTurn2RegisterText2            NSLocalizedString(@"LoginTurn2RegisterText2",@"turn to register")
#define KLoginForgetPasswordText            NSLocalizedString(@"LoginForgetPasswordText",@"forget password")

//未知错误
#define KRequestUnknowErrorMessage            NSLocalizedString(@"RequestUnknowErrorMessage",@"unknow error")
//请求网络错误提示
#define KRequestNetworkErrorMessage            NSLocalizedString(@"RequestNetworkErrorMessage",@"unknow error")
#define KLoginFailedErrorMessage1            NSLocalizedString(@"LoginFailedErrorMessage1",@"login failed")
#define KLoginFailedErrorMessage2            NSLocalizedString(@"LoginFailedErrorMessage2",@"login failed")

//注册
//"手机号输入框默认"
#define KMobileTextFieldPlaceholder           NSLocalizedString(@"MobileTextFieldPlaceholder",@"mobile")
#define KVerifyCodeTextFieldPlaceholder       NSLocalizedString(@"VerifyCodeTextFieldPlaceholder",@"verify code")
#define KNextActionText                       NSLocalizedString(@"NextActionText",@"next")
//"发验证码"
#define KSendVerifyCodeActionText                       NSLocalizedString(@"SendVerifyCodeActionText",@"send")
//"重新发送"
#define KReSendVerifyCodeActionText                      NSLocalizedString(@"ReSendVerifyCodeActionText",@"resend")
#define KSecondTextText                             NSLocalizedString(@"SecondText",@"second")

#define KRegisterText                           NSLocalizedString(@"RegisterText",@"register")
//"已有账户"
#define KHasAccountActionText                   NSLocalizedString(@"HasAccountActionText",@"has account")
#define KSettingPasswordPlaceholder             NSLocalizedString(@"SettingPasswordPlaceholder",@"setting password")
#define KRecommendedMobilePlaceholder           NSLocalizedString(@"RecommendedMobilePlaceholder",@"recommented mobile")
#define KRegisterAndGetRedpacketText            NSLocalizedString(@"RegisterAndGetRedpacketText",@"register")
#define KReadAndAgreeText                       NSLocalizedString(@"ReadAndAgreeText",@"read agree")
#define KRegisterProtocolText                   NSLocalizedString(@"RegisterProtocolText",@"Register protocol")
 //验证码错误
#define KCheckVerifyCodeErrorText                   NSLocalizedString(@"CheckVerifyCodeErrorText",@"VerifyCodeError")
#define KSendVerifyCodeErrorText                   NSLocalizedString(@"SendVerifyCodeErrorText",@"VerifyCodeError")

//验证手机号码
#define KVerifyMobileText                   NSLocalizedString(@"VerifyMobileText",@"Verify mobile")
//找回密码
#define KForgotPasswordText                     NSLocalizedString(@"ForgotPasswordText",@"ForgotPassword")
//"设置密码"
#define KPasswordInputPlaceholder1                   NSLocalizedString(@"PasswordInputPlaceholder1",@"PasswordInput")
#define KPasswordInputPlaceholder2                   NSLocalizedString(@"PasswordInputPlaceholder2",@"PasswordInput")

#define KSetPasswordSuccessText                   NSLocalizedString(@"SetPasswordSuccessText",@"set password success")
#define KSetPasswordFailedText                  NSLocalizedString(@"SetPasswordFailedText",@"Set Password Failed")
#define KSetPasswordInputDifferText                  NSLocalizedString(@"SetPasswordInputDifferText",@"Set Password differ")

#define KRegisterProtocolUnCheckedText          NSLocalizedString(@"RegisterProtocolUnCheckedText",@"Register Protocol UnChecked")
 //注册失败
#define KRegisterFailedText                 NSLocalizedString(@"RegisterFailedText",@"Register failed")
//注册成功
#define KRegisterSuccessText                NSLocalizedString(@"RegisterSuccessText",@"Register success")

//开户
#define KOpenAccountText                NSLocalizedString(@"OpenAccountText",@"Open Account")
//投资
#define KInvestText                     NSLocalizedString(@"InvestText",@"Invest")

//注册成功
#define KRegisterSuccessShowText          NSLocalizedString(@"RegisterSuccessShowText",@"Register Success Show")
//注册成功红包
#define KRegisterRedPacketShowText          NSLocalizedString(@"RegisterRedPacketShowText",@"Register RedPacket Show")
//托管账户
#define KOpenAccountShowText          NSLocalizedString(@"OpenAccountShowText",@"Open Account Show")

//查看红包
#define KRedPacketActionText          NSLocalizedString(@"RedPacketActionText",@"RedPacket Action")
//立即开户
#define KOpenAccountActionText          NSLocalizedString(@"OpenAccountActionText",@"Open Account Action")

//注册输入密码框的默认提示
#define KRegisterPasswordInputPlaceholder1          NSLocalizedString(@"RegisterPasswordInputPlaceholder1",@"Register password input")
#define KRegisterPasswordInputPlaceholder2         NSLocalizedString(@"RegisterPasswordInputPlaceholder2",@"Register password input")

//新旧密码输入一致
#define KNewAndOldPasswordInputSameText         NSLocalizedString(@"NewAndOldPasswordInputSameText",@"New and old password input same")

//修改登录密码
#define KChangeLoginPasswordText         NSLocalizedString(@"ChangeLoginPasswordText",@"Change login password")
//输入原始登录密码
#define KOldPasswordInputPlaceholder         NSLocalizedString(@"OldPasswordInputPlaceholder",@"Old login password")
//确认提交
#define KConfirmSubmissionText         NSLocalizedString(@"ConfirmSubmissionText",@"Confirm Submission")
//登录密码修改成功
#define KChangeLoginPasswordSuccessText         NSLocalizedString(@"ChangeLoginPasswordSuccessText",@"Change Login Password Success")
//立即升级
#define KUpdateActionTitle         NSLocalizedString(@"UpdateActionTitle",@"Update")

//服务器维护提示信息
#define KServerStatusShowCommentText1         NSLocalizedString(@"ServerStatusShowCommentText1",@"")
#define KServerStatusShowCommentText2         NSLocalizedString(@"ServerStatusShowCommentText2",@"")
#define KServerStatusShowCommentText3         NSLocalizedString(@"ServerStatusShowCommentText3",@"")
#define KServerStatusShowActionTitle         NSLocalizedString(@"ServerStatusShowActionTitle",@"Iknow")

//我的二维码
#define KMyQRCodeTitle         NSLocalizedString(@"MyQRCodeTitle",@"Iknow")

//开通托管账户
#define KOpenAccountTitle        NSLocalizedString(@"OpenAccountTitle",@"Open Account")

//提现失败提示拨打客服电话
#define KCallCustomerService1     NSLocalizedString(@"CallCustomerService1",@"Call Customer Service1")

//充值失败提示拨打客服电话
#define KCallCustomerService2     NSLocalizedString(@"CallCustomerService2",@"Call Customer Service2")


#pragma mark - 登录，注册，修改密码等界面提示
//输入框超过最大限制的时候的提示
#define KReachedInputMaxLength     NSLocalizedString(@"ReachedInputMaxLength",@"Reached Input Max Length")
//登录用户名或手机号输入
#define KInputUserNameOrPhoneErrorText     NSLocalizedString(@"InputUserNameOrPhoneErrorText",@"Input UserName Or Phone Error")
//登录密码输入
#define KInputPasswordErrorText     NSLocalizedString(@"InputPasswordErrorText",@"Input Password Error")
//注册密码输入 请输入6-16位密码,且包含数字和字母";
#define KInputPasswordErrorText1     NSLocalizedString(@"InputPasswordErrorText1",@"Input Password Error")

//手机号输入提示
#define KInputPhoneErrorText     NSLocalizedString(@"InputPhoneErrorText",@"Input Phone Error")
//验证码输入提示
#define KInputVerifyCodeErrorText     NSLocalizedString(@"InputVerifyCodeErrorText",@"Input VerifyCode Error")

//验证码输入提示
#define KInputOldPasswordErrorText     NSLocalizedString(@"InputOldPasswordErrorText",@"Input Old Password Error")
//验证邮编位数
#define KInputPostcodeErrorText     NSLocalizedString(@"InputPostcodeErrorText",@"Input Postcode Error")
//验证个人中心姓名位数
#define KInputNameErrorText     NSLocalizedString(@"InputNameErrorText",@"Input Name Error")
//验证个人中心详细信息位数
#define KInputDetailInfoErrorText     NSLocalizedString(@"InputDetailInfoErrorText",@"Input Detail Info Error")

//分享
#define KShareUnInstallQQAPPShowErrorInfo     NSLocalizedString(@"ShareUnInstallQQAPPShowErrorInfo",@"Share UnInstall QQ APP Show Error")
#define KShareUnInstallWechatAPPShowErrorInfo     NSLocalizedString(@"ShareUnInstallWechatAPPShowErrorInfo",@"Share UnInstall Wechat APP Show Error")
#define KShareUnInstallSinaWeiboAPPShowErrorInfo    NSLocalizedString(@"ShareUnInstallSinaWeiboAPPShowErrorInfo",@"Share UnInstall SinaWeibo APP Show Error")
#define KShareShowErrorTitle    NSLocalizedString(@"ShareShowErrorTitle",@"Share Show Error Title")

//广告页面的跳过
#define KJumpActionTitle    NSLocalizedString(@"JumpActionTitle",@"Jump")

//奖励提取
#define KRewardGetSuccessText    NSLocalizedString(@"RewardGetSuccessText",@"success")
#define KRewardGetErrorText   NSLocalizedString(@"RewardGetErrorText",@"error")

//指纹
#define KAuthenticationWithFingerprintReasonText   NSLocalizedString(@"AuthenticationWithFingerprintReason",@"Authentication With Fingerprint")
#define KAuthenticationWithFingerprintInSettingPasswordReasonText   NSLocalizedString(@"AuthenticationWithFingerprintInSettingPasswordReason",@"Authentication With Fingerprint")
#define KUseFingerprintLoginTitle                  NSLocalizedString(@"UseFingerprintLoginTitle",@"Use Fingerprint login")
#define KTurnToOtherLoginPageTitle                 NSLocalizedString(@"TurnToOtherLoginPageTitle",@"Turn To Other Login")

//手势
//请绘制解锁图案
#define KSettingGesturePasswordTitle                 NSLocalizedString(@"SettingGesturePasswordTitle",@"Setting Gesture Password")
//再次绘制解锁图案
#define KSettingGesturePasswordTitle2                 NSLocalizedString(@"SettingGesturePasswordTitle2",@"Setting Gesture Password")
//请输入手势密码解锁
#define KGesturePasswordCheckInputTitle                 NSLocalizedString(@"GesturePasswordCheckInputTitle",@"Gesture Password Check Input Title")
//请绘制解锁图案，至少连接
#define KGesturePasswordSettingInputTitle      NSLocalizedString(@"GesturePasswordSettingInputTitle",@"Gesture Password Setting Input Title")
//个点
#define KGesturePasswordSettingInputUnitTitle      NSLocalizedString(@"GesturePasswordSettingInputUnitTitle",@"Unit Title")

//密码错误，还可以输入
#define KGesturePasswordCheckInputErrorTitle   NSLocalizedString(@"GesturePasswordCheckInputErrorTitle",@"Gesture Password Check Input Error Title")
//次
#define KTimesTitle                NSLocalizedString(@"TimesTitle",@"Times")
#define KLoginOtherAccountTitle    NSLocalizedString(@"LoginOtherAccountTitle",@"Login Other Account")
//至少链接
#define KGesturePasswordInputLenthErrorTitle1  NSLocalizedString(@"GesturePasswordInputLenthErrorTitle1",@"Min Input Lenth")
//个点，请重新输入
#define KGesturePasswordInputLenthErrorTitle2  NSLocalizedString(@"GesturePasswordInputLenthErrorTitle2",@"Input too")
//与上次绘制不一致，请重新绘制
#define KGesturePasswordInputDifferentErrorTitle  NSLocalizedString(@"GesturePasswordInputDifferentErrorTitle",@"Input Different")

//设置手势密码
#define KGesturePasswordSettingTitle  NSLocalizedString(@"GesturePasswordSettingTitle",@"Gesture Setting")

//密码管理
//密码管理"
#define KPasswordManngerTitle  NSLocalizedString(@"PasswordManngerTitle",@"Password Mannger")
//修改登录密码
#define KModifyLoginPasswordTitle  NSLocalizedString(@"ModifyLoginPasswordTitle",@"Modify Login Password")
//修改第三方托管账户登录密码
#define KModifyThirdPartLoginPasswordTitle  NSLocalizedString(@"ModifyThirdPartLoginPasswordTitle",@"Modify ThirdPart Login Password")
//修改第三方托管账户交易密码
#define KModifyThirdPartPayPasswordTitle  NSLocalizedString(@"ModifyThirdPartPayPasswordTitle",@"Modify ThirdPart Pay Password")

//登录密码修改
//验证现有密码
#define KVerifyCurrentPasswordTitle  NSLocalizedString(@"VerifyCurrentPasswordTitle",@"Verify Current Password")
//设置新密码
#define KSettingNewPasswordTitle  NSLocalizedString(@"SettingNewPasswordTitle",@"Setting New Password")
//6-16字符，至少包含数字,字母,符号中的两种
#define KSettingNewPasswordDescriptionText  NSLocalizedString(@"SettingNewPasswordDescriptionText",@"Setting New Password Description")

//银行卡
#define KAddBankCardTitle  NSLocalizedString(@"AddBankCardTitle",@"Add bank card")
#define KUnbindBankCardTitle  NSLocalizedString(@"UnbindBankCardTitle",@"Unbind bank card")
#define KSyncBankCardSuccessTitle  NSLocalizedString(@"SyncBankCardSuccessTitle",@"Sync bank card success")
#define KBankCardTitle  NSLocalizedString(@"BankCardTitle",@"My bank cards")

#define KBankDebitCardTitle  NSLocalizedString(@"BankDebitCardTitle",@"Bank Debit Card")
#define KFundRecordTitle  NSLocalizedString(@"FundRecordTitle",@"Fund Record")

//充值相关
#define KRechargeResultTitle  NSLocalizedString(@"RechargeResultTitle",@"Recharge success")
#define KChaRechargeResultTitle  NSLocalizedString(@"ChaRechargeResultTitle",@"Difference charge success")

//我的投资列表
#define KAnnualInterestRateTitle  NSLocalizedString(@"AnnualInterestRate",@"Annual interest rate")
#define KDueTimeTitle  NSLocalizedString(@"DueTime",@"Due time")
#define KInvestmentTitle  NSLocalizedString(@"Investment",@"Investment")
#define KInvestTimeTitle  NSLocalizedString(@"InvestTime",@"Invest time")
#define KRepayMethodTitle  NSLocalizedString(@"RepayMethod",@"Repay method")
#define KCollectInterestTitle  NSLocalizedString(@"CollectInterest",@"Collect interest")
#define KPayOffTimeTitle  NSLocalizedString(@"PayOffTime",@"Pay off time")

#define KEarnedIncomeTitle  NSLocalizedString(@"EarnedIncome",@"Earned income")
//京东E卡
#define KJingDongCardTitle  NSLocalizedString(@"JingDongCard",@"JingDong card")
#define KJingDongCardRecord NSLocalizedString(@"JingDongCardRecord",@"JingDong cardrecord")
//个人中心
//底部提示
#define KAccountFooterTitle  NSLocalizedString(@"AccountFooterTitle",@"Footer Title")

//开户相关
#define KOpenAccountFailTitle  NSLocalizedString(@"OpenAccountFail",@"Open account fail")
#define KOpenAccountSuccessTitle  NSLocalizedString(@"OpenAccountSuccess",@"Open account success")
#define KReopenAccountTitle  NSLocalizedString(@"ReopenAccount",@"Re open an account")
#define KImmediateInvestmentTitle  NSLocalizedString(@"ImmediateInvestment",@"Immediate investment")
#define KImmediateRechargeTitle  NSLocalizedString(@"ImmediateRecharge",@"Instant Recharge")


//绑定手机号
#define KBindPhoneTitle  NSLocalizedString(@"BindPhone",@"Bind phone")

//奖励
#define KValidRewardTitle  NSLocalizedString(@"ValidReward",@"Valid reward")
#define KRewardDetailTitle  NSLocalizedString(@"RewardDetail",@"Reward Detail")
#define KRewardExtractingTitle  NSLocalizedString(@"RewardExtracting",@"Reward extracting")
#define KSoonExtractTitle  NSLocalizedString(@"SoonExtract",@"Soon extract")

//联系人
#define KEmegencyContactTitle  NSLocalizedString(@"EmegencyContact",@"Emegency contact")
#define KSaveTitle  NSLocalizedString(@"Save",@"Save")
#define KCorrectPhoneTitle  NSLocalizedString(@"CorrectPhone",@"Please input correct phone")
#define KContactHeaderTitle  NSLocalizedString(@"ContactHeader",@"Used only when emegency")
#define KNoInvestTargetTitle  NSLocalizedString(@"NoInvestTarget",@"No invest target")

//
#define KCashTitle  NSLocalizedString(@"Cash",@"Cash coupon")
#define KInvestmentReturnTitle  NSLocalizedString(@"InvestmentReturn",@"Investment return")

//个人信息
#define KEmailTitle  NSLocalizedString(@"Email",@"Email")
#define KPersonalInfoTitle  NSLocalizedString(@"PersonalInfo",@"Personal info")
#define KNotCertifiedTitle  NSLocalizedString(@"NotCertified",@"Not certified")
#define KCertifiedTitle  NSLocalizedString(@"Certified",@"Certified")
#define KUnboundTitle  NSLocalizedString(@"Unbound",@"Unbound")
#define KAddrAddTitle  NSLocalizedString(@"AddressAdd",@"Address add")
#define kAddrHeaderTitle  NSLocalizedString(@"AddrHeader",@"Used only for send presents") 

//我的投资
#define KMyInvestTitle  NSLocalizedString(@"MyInvest",@"My investment")

#define KHiddenStarTitle  NSLocalizedString(@"HiddenStar",@"****")
#define KFrozenAmountTitle  NSLocalizedString(@"FrozenAmount",@"Freezing amount")
#define KConfirmTitle  NSLocalizedString(@"Confirm",@"Confirm")
#define KPaymentPlanTitle  NSLocalizedString(@"PaymentPlan",@"Payment plan")

//关于我们
#define KAboutUsTitle  NSLocalizedString(@"AboutUs",@"About US")
#define KVerUpgradeTitle  NSLocalizedString(@"VerUpgrade",@"Version Upgrade")

//我的推广
#define KMyPromoteTitle  NSLocalizedString(@"MyPromote",@"My promotion")
#define KNoPromoteRecordTitle  NSLocalizedString(@"NoPromoteRecord",@"No promote record")
#define KPhoneVerifyTitle  NSLocalizedString(@"PhoneVerify",@"Phone Verified")


//充值
#define KRechargeTitle   NSLocalizedString(@"RechargeTitle",@"Recharge")
#define KRechargeBankcardPay   NSLocalizedString(@"RechargeBankcardPay",@"Bank Card Pay")
#define KRechargeOtherPay   NSLocalizedString(@"RechargeOtherPay",@"Other Pay")
#define KRechargeQuickPay   NSLocalizedString(@"RechargeQuickPay",@"Quick Pay")
#define KRechargeQuickPayDetail   NSLocalizedString(@"RechargeQuickPayDetail",@"Support the mainstream bank quick payment service")
#define KRechargeUnionPay   NSLocalizedString(@"RechargeUnionPay",@"Union Pay")
#define KRechargeUnionPayDetail   NSLocalizedString(@"RechargeUnionPayDetail",@"Support a number of online banking payment services")
#define KRechargeUnionNFCPay    NSLocalizedString(@"RechargeUnionNFCPay",@"NFC")
#define KRechargeConfirm     NSLocalizedString(@"RechargeConfirm",@"Confirm Pay")
#define KRechargeInputTips  NSLocalizedString(@"RechargeInputTips",@"Please enter the amount of money")
#define KRechargeOutOfLimit NSLocalizedString(@"RechargeOutOfLimit",@"Exceed the bank's single limit")
#define KRechargeSelectedBankCard NSLocalizedString(@"RechargeSelectedBankCard",@"Please Choose BankCard")
#define KRechargeOpenCardTips   NSLocalizedString(@"RechargeOpenCardTips",@"The following bank card to be opened before the UnionPay no card payment, or can not recharge, how to open?")
#define KRechargeOpenWay    NSLocalizedString(@"RechargeOpenWay",@"How to open?")
#define KRechargeOpenOnlinePay  NSLocalizedString(@"RechargeOpenOnlinePay",@"Open online pay")
#define KRechargeHowToOpenNFCPay    NSLocalizedString(@"RechargeHowToOpenNFCPay",@"How to open CUP card without payment?")
#define KRechargeNoneBank   NSLocalizedString(@"RechargeNoneBank",@"No bank message")
#define KRechargeDescription   NSLocalizedString(@"RechargeDescription",@"Recharge Description")
#define KRechargeUnbind   NSLocalizedString(@"RechargeUnbind",@"Unbind")


//提现
#define KDepositTitle   NSLocalizedString(@"DepositTitle",@"withdraw")
#define KDepositFreeTake   NSLocalizedString(@"DepositFreeTake",@"You have %ld free chance this month")
#define KDepositAddBankcard   NSLocalizedString(@"DepositAddBankcard",@"Add BankCard")
#define KDepositDescription NSLocalizedString(@"DepositDescription",@"withdraw description")
#define KDepositEnterAmount NSLocalizedString(@"DepositEnterAmount",@"Please enter the amount of cash")
#define KDepositOutOfLimit   NSLocalizedString(@"DepositOutOfLimit",@"Excessable withdrawable balance")
#define KDepositTaked   NSLocalizedString(@"DepositTaked",@"Take")


//自动投标
#define KAutoLoanTitle   NSLocalizedString(@"AutoLoanTitle",@"Auto loan")
#define KAutoLoanOpen   NSLocalizedString(@"AutoLoanOpen",@"Open Auto Loan")
#define KAutoLoanClose   NSLocalizedString(@"AutoLoanClose",@"Close Auto Loan")

//投资记录
#define KInvestHistoryTitle  NSLocalizedString(@"InvestHistoryTitle",@"Invest History")
#define KInvestHistoryNone  NSLocalizedString(@"InvestHistoryNone",@"No more Invest History")

//资产明细
//资产明细
#define KAssetTitle  NSLocalizedString(@"AssetTitle",@"Asset Detail")
//总资产(元)
#define KTotalAssetTitle  NSLocalizedString(@"TotalAssetTitle",@"Total Asset")
//可用余额
#define KAvailableBalanceTitle  NSLocalizedString(@"AvailableBalanceTitle",@"Available Balance")
//冻结金额
#define KFrozenBalanceTitle  NSLocalizedString(@"FrozenBalanceTitle",@"Frozen Balance")
//待收本金
#define KDueInFundTitle  NSLocalizedString(@"DueInFundTitle",@"DueIn Fund")
//待收利息
#define KDueInInterestTitle  NSLocalizedString(@"DueInInterestTitle",@"DueIn Interest")
//获取资产明细错误
#define KGetAssetDetailErrorMessage  NSLocalizedString(@"GetAssetDetailErrorMessage",@"Get Asset Detail Error")

//可提奖励
//总金额(元)
#define KTotalExtractableAmtTitle  NSLocalizedString(@"TotalExtractableAmtTitle",@"Total Extractable Amount")
//推广收益
#define KValidRewardForExtendTitle  NSLocalizedString(@"ValidRewardForExtendTitle",@"Valid Reward For Extend")
//现金券
#define KValidRewardForCashTitle  NSLocalizedString(@"ValidRewardForCashTitle",@"Valid Reward For Cash")
//红包激活
#define KValidRewardForRedPacketTitle  NSLocalizedString(@"ValidRewardForRedPacketTitle",@"Valid Reward For RedPacket")
//立即提取
#define KTakeRewardActionTitle  NSLocalizedString(@"TakeRewardActionTitle",@"Take Reward")
//奖励提取说明
#define KTakeRewardActionDescriptionTitle  NSLocalizedString(@"TakeRewardActionDescriptionTitle",@"Take Reward Action Description")
//获取可提奖励明细错误
#define KGetRewardDetailErrorMessage  NSLocalizedString(@"GetRewardDetailErrorMessage",@"Get Reward Detail Error")
//奖励提取错误
#define KTakeRewardActionErrorMessage  NSLocalizedString(@"TakeRewardActionErrorMessage",@"Take Reward Error")

//汇款日历
#define KRepayCalendarText      NSLocalizedString(@"RepayCalendarText",@"Repay Calendar")

//单次最多可提取
#define KRewardInputAboveMaxErrorMessage  NSLocalizedString(@"RewardInputAboveMaxErrorMessage",@"Reward Input Above Max Error")
//输入金额超过可提取奖励
#define KRewardInputAboveTotalErrorMessage  NSLocalizedString(@"RewardInputAboveTotalErrorMessage",@"Reward Input Above Total Error")
//格式错误
#define KRewardInputFormatErrorMessage  NSLocalizedString(@"RewardInputFormatErrorMessage",@"Reward Input Format Error")
//提取金额
#define KTakeRewardInputTitle  NSLocalizedString(@"TakeRewardInputTitle",@"Take Reward Money")
//每笔最多
#define KTakeRewardInputPlaceholderTitle  NSLocalizedString(@"TakeRewardInputPlaceholderTitle",@"Take Reward Money Max")
//邮箱名超过最大值的提示
#define KMailNameMaxLengthTitle   NSLocalizedString(@"MailNameMaxLengthTitle",@"The length of mail can't be beyond 40 characters")   
#endif
