//
//  KSConfig.h
//  kaisafax
//
//  Created by SemnyQu on 14/10/26.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#ifndef KSConfig_h
#define KSConfig_h

#pragma mark -
#pragma mark------------------网络服务-----------------

//#define __ONLINE__
#ifdef __ONLINE__
//生产环境
#define SX_SERVER_ADDRESS @"app.kaisafax.com" //https
//#define SX_H5_ADDRESS @"h5.kaisafax.com" //https
#else

//生产环境
//#define SX_SERVER_ADDRESS @"app.kaisafax.com" //https
//#define SX_H5_ADDRESS @"h5.kaisafax.com" //https

//重构开发环境2
//#define SX_H5_ADDRESS       @"devssl.kaisafax.com" //https
//#define SX_SERVER_ADDRESS   @"devapp.kaisafax.com" //https
//#define SX_SERVER_ADDRESS   @"192.168.188.45:18095/newApp" //http

//重构测试环境2
//#define SX_H5_ADDRESS @"testh5.kaisafax.com" //https
//#define SX_SERVER_ADDRESS @"testapp.kaisafax.com" //https

//重构测试新环境
#define SX_SERVER_ADDRESS @"test1app.kaisafax.com" //https
#endif

//HTTP协议前缀
#define KHTTP_PRE @"http://"
//HTTPS协议前缀
#define KHTTPS_PRE @"https://"

//HTTP协议接口地址
//#define SX_HOST   [NSString stringWithFormat:@"%@%@", KHTTP_PRE, SX_SERVER_ADDRESS]
//#define SX_H5   [NSString stringWithFormat:@"%@%@", KHTTP_PRE, SX_H5_ADDRESS]

//HTTPS协议接口地址
#define SX_HOST [NSString stringWithFormat:@"%@%@", KHTTPS_PRE, SX_SERVER_ADDRESS]
//#define SX_H5   [NSString stringWithFormat:@"%@%@", KHTTPS_PRE, SX_H5_ADDRESS]

//API接口服务地址(重构API)
#define SX_APP(A) [NSString stringWithFormat:@"%@/api/%@", SX_HOST, A]
#define SX_APP_API [NSString stringWithFormat:@"%@/api", SX_HOST]

//H5加载地址
//#define SX_M(A)    [NSString stringWithFormat:@"%@/m/%@", SX_H5, A]
//#define SX_M_API  [NSString stringWithFormat:@"%@/m", SX_H5]

#pragma mark---------------接口参数-------------------

//head
#define kHeadKey @"head"

//body
#define kBodyKey @"body"
/**
 *  header公共参数
 */
//接口名称/方法
#define kMethodKey @"method"
//接口版本
#define kVersionKey @"version"
//序列号，某次连接递增 客户端自行生成
#define kSeqNoKey @"seqNo"
//报文请求时间
#define kTimestampKey @"timestamp"
//校验数据（body部分有数据，必须校验）
#define kSignKey @"sign"
//客户端应用ID 00001
#define kAppKeyKey @"appKey"
//body压缩标志,默认 false不压缩；若压缩采用zip压缩方式
#define kIsCompressKey @"isCompress"
//本地语言 默认en
#define kLocaleKey @"locale"
//用户id
#define kUserIdKey @"userId"
//授权访问令牌
#define kSessionIdKey @"sessionId"
//设备id,获取系统的手机唯一编号（客户端生成）
#define kGuidKey @"guid"
//设备型号
#define kDeviceModelKey @"deviceModel"
//渠道号
#define kAppChannelKey @"appChannel"
//平台类型
#define kPlatformTypeKey @"platformType"
//版本名称
#define kAppVersionKey @"appVersion"
//版本数字编号
#define kVersionNumberKey @"versionNumber"
//系统版本
#define kSysVersionKey @"sysVersion"

/**
 *  比较奇葩
 */
//版本
#define kAppVersionsKey @"appVersions"
//渠道
#define kAppChannelsKey @"appChannels"

#define kChannelVID @"appstore"
#define kPlatformTypeValue 2 //@"ios"

//设备信息更新后的guid key
#define kUpdateDevInfoGUID @"updateDevInfoGUID"

//用户注册登录相关
#define kMobileKey @"mobile"
#define kPasswordKey @"password"
//验证码
#define kVerifyCodeKey @"mobileCaptcha"
#define kTypeKey @"type"
//推荐人
#define kRefereeKey @"referee"

//银行卡
#define kBankCardListKey @"bankCardList"
#define kBankListKey @"bankList"

//银行卡id
#define kBankCardIdKey @"cardId"
//银行列表类型(充值)
#define kBankTypeKey @"bankType"

/**
 *  自动投标
 */
//最小年化利率
#define kMinRateKey @"minRate"
//最大年化利率
#define kMaxRateKey @"maxRate"
//最小投资金额
#define kMinAmountKey @"minAmount"
//最大投资金额
#define kMaxAmountKey @"maxAmount"
//账户保留金额
#define kReservedAmountKey @"reservedAmount"
//还款方式(1+2+4+8?)
#define kRepayMethodIndexKey @"repayMethodIndex"
//最小投资时间
#define kMinDaysKey @"minDays"
//最大投资时间
#define kMaxDaysKey @"maxDays"
//投资周期 0 月 1 天
#define kDurTypeKey @"durType"

#define kIdKey @"id"

//标的id
#define kLoanIdKey @"loanId"
//充值金额
#define kAmountKey @"amount"
//银行代码，必填
#define kBankCodeKey @"bankCode"
//充值类型： 0快捷，1网银，必填
#define kRechargeTypeKey @"rechargeType"
//动作标识，非必填
#define kActionFlagKey @"actionFlag"
//版本序号，不同版本序号的app跳转不同界面
#define kVersionCodeKey @"verCode"

//我的奖励-奖励提取
//可提奖励金额
#define kWithdrawAmtKey @"withdrawAmt"
//提现类型
#define kWithdrawTypeKey @"withdrawType"

//投资接口列表分页开始字段key
#define kListPageStartKey @"pageNum"
//投资接口列表分页长度字段key
#define kListPageCountKey @"pageSize"

//首页相关信息接口字段
#define kSwitchAppRequestNameKey @"switchAppRequestName"
#define kManufactorKey @"manufactor"
//
///**
// *  @author semny
// *  投资
// */
////标的id
#define kInvestLoanIdKey @"loanId"

//旧密码
#define kUserOldPwdKey @"oldPwd"
//新密码
#define kUserNewPwdKey @"newPwd"
//
//资金记录
//开始时间
#define kFromKey @"from"
#define kToKey @"to"
#define kFilterTypeKey @"filterType"

//状态
#define kStatusKey @"status"

#define kManufactorValue @"apple"
#define kSwitchAppRequest1 @"notice"
#define kSwitchAppRequest2 @"share"

////标志整个流程的序列号
#define kRequestProcessSeqNo @"RequestProcessSeqNo"
////整个流程的请求的标志
#define kRequestProcessCmdId @"RequestProcessCmdId"
////整个流程的子类请求的标志
//#define kRequestProcessSubType @"RequestProcessSubType"

#define kEmailKey @"email"

//投资id
#define kInvestIdKey @"investId"
//
//个人信息相关
#define kReceiverNameKey @"receiverName"
#define kReceiverMobileKey @"receiverMobile"
#define kProvinceKey @"province"
#define kCityKey @"city"
#define kCountyKey @"county"
#define kAddressKey @"address"
#define kZipCodeKey @"zipCode"

#define kNameKey @"name"
#define kMobileKey @"mobile"
#define kRelationKey @"relation"

////上报设备信息相关
//#define KIFAKey @"ifa"
//#define KMACKey @"mac"
#define kDeviceImeiKey @"deviceImei"

//分享相关的字符串
#define kShareStatus @"shareStatus"
#define kShareTitle @"title"
#define kShareURL @"url"
#define kShareImage @"image"
#define kShareContent @"content"

#pragma mark--------------配置参数-----------------
//API接口版本数据
#define kAPIVersionValue @"1.0"
//客户端编号
#define kAppKeyValue @"00002"
#define kAppSecret @"FE50B680-10C2-4703-AD2F-D5FD12C0EB3B"

#pragma mark -
#pragma mark------------------APNS推送服务-----------------
#define kAPNSDeviceToken @"APNSDeviceToken"
#define kAPNSDidReceiveMessage @"kAPNSDidReceiveMessage"
#define kAPNsPresentMessage @"kAPNsPresentMessage"

#pragma mark -
#pragma mark-----------------接口业务编号-----------------

//接口名称前缀
//#define kAPIMethodPrefixKey   @"com.jzy.kaisafax.app."

#pragma mark - 短信验证码
//发短信
#define kSendVerifiyCodeTradeId @"com.jzy.kaisafax.app.CaptchaController.sendCaptcha"
//短信校验
#define kValideVerifiyCodeTradeId @"com.jzy.kaisafax.app.CaptchaController.validateCaptcha"

#pragma mark - 注册登录
//注册接口
#define KRegisterTradeId @"com.jzy.kaisafax.app.RegisterController.register"
//注册整个过程中统一返回的结果编号
#define KRegisterProcessTradeId @"RegisterProcess"

//登录接口编号
#define KLoginTradeId @"com.jzy.kaisafax.app.LoginController.login"
//注销登录接口编号
#define KLogoutTradeId @"com.jzy.kaisafax.app.LoginController.logout"
//token登录（暂时未实现）
//#define KLoginTokenTradeId              @"loginToken"
//手机号登录整个过程中统一返回的结果编号
#define KLoginMobileProcessTradeId @"com.jzy.kaisafax.app.LoginMobileProcess"
//忘记密码找回密码
#define KForgotPasswordTradeId @"com.jzy.kaisafax.app.LoginController.resetPassword"
//修改登录密码
#define KModifyLoginPwdTradeId @"com.jzy.kaisafax.app.AccountSecurityController.modifyPassword"

//注册协议(h5)
#define KRegisterProtocolPage @"com.jzy.kaisafax.app.StaticController.regContract"

//同步用户信息
#define KSyncUserInfoTradeId @"com.jzy.kaisafax.app.LoginController.syncUserInfo"
//刷新会话
#define KRefreshSessionIdTradeId @"com.jzy.kaisafax.app.LoginController.refreshSessionId"
//业主认证
#define KCertifyOwnerUserTradeId @"com.jzy.kaisafax.app.AccountSecurityController.certifyOwnerUser"

#pragma mark - 我的推广
//我的推广
#define KCommissionTradeId @"com.jzy.kaisafax.app.PromotionController.promoteForConfigurable"
//我的推荐收益统计
#define KCommissionIncomeTradeId @"com.jzy.kaisafax.app.PromotionController.commissionStat"
//我的推荐的直接推荐人列表
#define KCommissionInviteListTradeId @"com.jzy.kaisafax.app.PromotionController.inviteList"

#pragma mark - 京东卡
//获取卡密(挂卡)
#define KGetJDPwdTradeId @"com.jzy.kaisafax.app.JingDongEController.getCardPwd"
//获取卡密(发送短信)
#define KSendMobileCaptchaForJDTradeId @"com.jzy.kaisafax.app.JingDongEController.sendMobileCaptcha"
//获取卡密(验证短信)
#define KGetJDDetailTradeId @"com.jzy.kaisafax.app.JingDongEController.extractDetail"
//领卡纪录列表（余额及领取列表）
#define KGetJDExtractListTradeId @"com.jzy.kaisafax.app.JingDongEController.extractRecordList"
//领取京东卡
#define KGetJDECardTradeId @"com.jzy.kaisafax.app.JingDongEController.extract"
//发放纪录(发放列表)
#define KJDProvideListTradeId @"com.jzy.kaisafax.app.JingDongEController.provideRecordList"

#pragma mark - 银行卡
//用户的银行卡(我的银行卡 老接口)
#define KGetBankCardsTradeId @"com.jzy.kaisafax.app.BankCardController.userBankcard"
//同步银行卡信息
#define KSyncBankCardTradeId @"com.jzy.kaisafax.app.BankCardController.pnrSynCard"

//支持充值的银行列表(快捷/网银)
#define KGetBankListTradeId @"com.jzy.kaisafax.app.BankCardController.bankList"

//解除绑定银行卡接口
#define KUnbindBankAccountTradeId @"com.jzy.kaisafax.app.BankCardController.unbindBankAccount"

#pragma mark - 红包
//注册红包列表
#define KRegisterRedpacketTradeId @"com.jzy.kaisafax.app.RewardController.registerRedpacket"
//已激活奖励，未激活奖励，已提取奖励（红包列表）
#define KGetRewardListTradeId @"com.jzy.kaisafax.app.RewardController.listCoupons"
//可提取奖励(红包、现金劵)
#define KGetValidRewardsForRedTradeId @"com.jzy.kaisafax.app.RewardController.rewardInvoked"
//提取红包
#define KTakeRewardCashTradeId @"com.jzy.kaisafax.app.RewardController.withdrawReward"

#pragma mark - 自动投标
//获取自动投标信息
#define KGetAutoInvestInfoTradeId @"com.jzy.kaisafax.app.InvestController.autoInvest"
//保存自动投标信息
#define KSaveAutoInvestInfoTradeId @"com.jzy.kaisafax.app.InvestController.saveAutoInvest"
//开启自动投标(动态h5)
#define KOpenAutoInvestTradeId @"com.jzy.kaisafax.app.InvestController.openAutoInvest"
//关闭自动投标(动态h5)
#define KCloseAutoInvestTradeId @"com.jzy.kaisafax.app.InvestController.closeAutoInvest"
//自动投标的帮助说明h5
#define KAutoInvestExplainPage @"com.jzy.kaisafax.app.StaticController.autoInvestDesc"

#pragma mark - 我的投资
//用户的投资列表接口编号(我的投资)
#define KUserInvestListTradeId @"com.jzy.kaisafax.app.InvestController.userInvest"
//回款计划
#define KReceivedRepaysTradeId @"com.jzy.kaisafax.app.InvestController.investRepay"

//投资合同(后续可能用不到)
#define KGetInvestContractTradeId @"com.jzy.kaisafax.app.InvestController.getContract"

#pragma mark - 检查功能
//检查功能（版本检查）
#define KCheckAPPUpdateStatusTradeId @"com.jzy.kaisafax.app.AppCheckController.checkVersion"
//检查功能（上传设备信息）
#define KDeviceReportTradeId @"com.jzy.kaisafax.app.AppCheckController.reportDevice"

#pragma mark - h5请求
#define KOpenAccountTradeId @"com.jzy.kaisafax.app.RegisterController.openAccount"
#define KInvestBidTradeId @"com.jzy.kaisafax.app.InvestController.investLoan"
#define KAddAssetsTradeId @"com.jzy.kaisafax.app.FundOperationController.userRecharge"
#define KCashGetAssetsPage @"com.jzy.kaisafax.app.FundOperationController.userWithdraw"

/**
 *  首页
 */
//运营图
//获取首页相关信息(包括以上的三个部分的信息，新构造)
#define KGetHomeTogetherTradeId @"com.jzy.kaisafax.app.HomeController.bannerNoticeOperation"
//新手标
#define KInvestNewBeeTradeId @"com.jzy.kaisafax.app.HomeController.noviceLoan"
//物业宝#define KPropertyTreasureTradeId         @"getOwnerLoans"
//推荐和物业宝合并的接口
#define KGetOwnerAndRecommendLoansTradeId @"com.jzy.kaisafax.app.HomeController.ownerRecommendLoans"
//Home界面的组合请求的tradeId
#define KHomeBatchRequestTradeId @"homeBatchRequestTradeId"
//投资界面的组合请求的tradeId
#define KInvestBatchRequestTradeId @"investBatchRequestTradeId"
//公告里的更多
#define KNoticeMoreTradeId @"com.jzy.kaisafax.app.HomeController.noticeList"
//公告详情
#define KNoticeDetailTradeId @"com.jzy.kaisafax.app.HomeController.noticeDetail"
//轮播,运营图
#define KBannerAndAdvertiseTradeId @"com.jzy.kaisafax.app.HomeController.redirectToH5Banner"

/**
 *  投资理财
 */
//投资列表接口编号
#define KInvestListTradeId @"com.jzy.kaisafax.app.LoanController.filterLoans"

//投资页面/详情接口编号 新接口
#define KInvestDetailTradeId @"com.jzy.kaisafax.app.LoanController.loanDetail"

//标的投资记录
#define KInvestBidRecordTradeId @"com.jzy.kaisafax.app.LoanController.investRecordByLoan"

//投资协议(h5)
#define KInvestProtocolPage @"com.jzy.kaisafax.app.LoanController.getLoanContract"
//项目详情(h5)
#define KInvestProjectDetailPage @"com.jzy.kaisafax.app.LoanController.getLoanDetail"

//物业宝标的详情
#define KOwnerLoanDetailPage @"com.jzy.kaisafax.app.LoanController.getOwnerLoanDetailPage"

/**
 *  @author semny
 *
 *  用户个人信息账户相关
 */
//账户信息-我的资产
#define KUserNewAssetsTradeId @"com.jzy.kaisafax.app.AccountManagerController.accountAssets"
//我的资产-累计收益部分
#define KGetUserAccumulatedIncomeTradeId @"com.jzy.kaisafax.app.AccountManagerController.accumulatedIncome"
//我的资产-可提取金额部分
#define KGetValidRewardsDetailTradeId @"com.jzy.kaisafax.app.RewardController.extractableRewardInfo"

//用户投资交易记录(资金记录)
#define KUserFundRecordTradeId @"com.jzy.kaisafax.app.AccountManagerController.userFundRecord"

//定制标接口
#define KCustomLoansTradeId @"com.jzy.kaisafax.app.LoanController.customLoans"

//获取充值页面的信息接口
#define KGetRechargeInfoTradeId @"com.jzy.kaisafax.app.AccountManagerController.depositPre"

//提现界面信息接口
#define KGetWithdrawInfoTradeId @"com.jzy.kaisafax.app.AccountManagerController.withdrawPre"
/**
 *  @author semny
 *
 *  账户资金相关
 */
//绑定银行卡（h5）
#define KBindBankCardsPage @"com.jzy.kaisafax.app.BankCardController.bindCard"

/**
 *  @author semny
 *
 *  账户信息相关
 */
//关于我们(h5)
#define KAboutUSPage @"com.jzy.kaisafax.app.StaticController.aboutUs"
//安全保障（h5）
#define KSafetyPage @"com.jzy.kaisafax.app.StaticController.security"
//常见问题（h5）
#define KQuestionPage @"com.jzy.kaisafax.app.StaticController.faq"

/**
 *  @author semny
 *
 *  奖励相关
 */
//奖励纪录,奖励明细(h5)
#define KRewardRecordsPage @"com.jzy.kaisafax.app.RewardController.getRewardRecord"
//推广规则(h5)
#define KCommissionRulesPage @"com.jzy.kaisafax.app.PromotionController.getPromoteRulesPage"
//红包规则（h5）
#define KRedpacketRulePage @"com.jzy.kaisafax.app.StaticController.rewardRules"
//我的二维码(下载图片)
//#define KQuardCodeDownloadURL SX_APP(@"account/myQrcode")
//理财师（h5）
#define KFinancierDescPage @"com.jzy.kaisafax.app.PromotionController.getPromoteRulesPage"
//高级理财师(h5)
#define KSenFinancierDescPage @"com.jzy.kaisafax.app.PromotionController.getPromoteRulesPage"

/**
 *  @author yubei
 *
 *  个人信息
 */
//个人信息
#define KPersonalInfoTradeId @"com.jzy.kaisafax.app.AccountSecurityController.userSecurityInfo"
//绑定邮箱
#define KBindEmail @"com.jzy.kaisafax.app.AccountSecurityController.modifyEmail"
//修改地址
#define KModifyAddr @"com.jzy.kaisafax.app.AccountSecurityController.modifyAddress"
//获取区域
#define KGetArea @"com.jzy.kaisafax.app.AccountSecurityController.areaInfo"
//修改联系人
#define KModifyContactor @"com.jzy.kaisafax.app.AccountSecurityController.modifyContactor"
//修改手机号(重构接口已去掉)
#define KModifyPhoneTradeId @"set/modifyMobile"

//个人中心页面的组合请求的tradeId
#define KAccountBatchRequestTradeId @"AccountBatchRequestTradeId"

/**
 *  @author yubei
 *
 *  回款日历
 */
#define KPayCalendarTradeId @"com.jzy.kaisafax.app.AccountManagerController.getRepayCalendarPage"
//充值说明
#define KDepositExplain @"com.jzy.kaisafax.app.StaticController.rechargeExplain"
//提现说明
#define KWithdrawExplain @"com.jzy.kaisafax.app.StaticController.withdrawExplain"
//同步登陆态接口
#define KSyncSession SX_APP(@"syncSessionForApp")
//服务端的广告数据接口id
#define KGetAdForConfigurableTradeId @"com.jzy.kaisafax.app.HomeController.openScreenAdvert"

/**
 *  @author semny
 *
 *  服务器维护状态
 */
#define KServerStatusTradeId @"service_status"

#pragma mark----------- 通知 ----------------
//物业认证成功通知
#define KOwnerAuthenticateSuccessNotificationKey @"OwnerAuthenticateSuccessNotification"

//启动页面完成的通知
#define KLaunchCompletedNotificationKey @"LaunchCompletedNotification"

//个人中心信息变更的通知
#define KAccountInfoChangeNotificationKey @"AccountInfoChangeNotification"

//京东卡变更通知
#define KAccountJDCardChangeNotificationKey @"AccountJDCardChangeNotificationKey"

//自动投标更新通知
#define KAutoLoanChangeNotificationKey @"AutoLoanChangeNotification"

//登录启动之前的通知
#define KLoginPageBeginAnimationNotificationKey @"LoginPageBeginAnimationNotification"

//登录框关闭之前的通知
#define KLoginPageCloseAnimationNotificationKey @"LoginPageCloseAnimationNotification"

//页面开启之前的通知
#define KBeforePageBeginAnimationNotificationKey @"BeforePageBeginAnimationNotification"

//页面关闭之后的通知
#define KAfterPageCloseAnimationNotificationKey @"AfterPageCloseAnimationNotification"

//提现通知
#define KTakeValidRewardNotificationKey @"TakeValidRewardNotification"

//登录，注册通知账户中心眼睛隐藏标志
#define KChangeAccountEyeFlagKey @"ChangeEyeFlagNotification"

/**
 *  佳信客服
 */
#define KJXAppkey @"m3vozhy4cwj4zq#sxfax001#10002"

#endif /* KSConfig_h */
