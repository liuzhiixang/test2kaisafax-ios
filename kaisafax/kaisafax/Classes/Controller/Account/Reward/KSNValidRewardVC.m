//
//  KSNValidRewardVC.m
//  kaisafax
//
//  Created by semny on 17/4/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNValidRewardVC.h"
#import "KSRewardBL.h"
#import "KSWebVC.h"

@interface KSNValidRewardVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
//顶部视图
@property (weak, nonatomic) IBOutlet UIView *headerView;
//可提奖励label
@property (weak, nonatomic) IBOutlet UILabel *validRewardLabel;
//可提奖励title label
@property (weak, nonatomic) IBOutlet UILabel *validRewardTitleLabel;

//信息输入
@property (weak, nonatomic) IBOutlet UITextField *takeRewardValueTF;
@property (weak, nonatomic) IBOutlet UILabel *takeRewardInputTitleLabel;

//可提奖励操作描述
@property (weak, nonatomic) IBOutlet UILabel *takeRewardActionDescLabel;

//底部操作
@property (weak, nonatomic) IBOutlet UIView *footerView;
//提取操作按钮
@property (weak, nonatomic) IBOutlet UIButton *takeActionBtn;
//提取说明
@property (weak, nonatomic) IBOutlet UILabel *takeDescriptionLabel;

//提取说明左间距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takeDescLabelLeft;
//提取说明右间距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takeDescLabelRight;

//描述数组
@property (copy, nonatomic) NSArray *explainList;

//奖励BL
@property (strong, nonatomic) KSRewardBL *validRewardsBL;

@end

//最大可提取金额
const static int kMaxTakeRewardValue = 2000;


//金额类型
typedef NS_ENUM(NSInteger,KSRewardInputType)
{
    KSRewardInputTypeFormatError = -4,  //格式异常
    KSRewardInputTypeAboveTotal = -3,   //超过总数
    KSRewardInputTypeAboveMax = -2,     //超过单笔限额
    KSRewardInputTypeLTOEZero = -1,     //小于等于0
    KSRewardInputTypeEmpty = 0,         //空
    KSRewardInputTypeNormal = 1,        //正常
};

@implementation KSNValidRewardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //标题
    [self setNavTitleByText:KValidRewardTitle];
    [self setNavRightButtonByText:KRewardDetailTitle titleColor:UIColor.whiteColor imageName:nil selectedImageName:nil navBtnAction:@selector(rewardInfoDetail)];

    @WeakObj(self);
    [[self.takeRewardValueTF rac_textSignal] subscribeNext:^(id x) {
        [weakself updateActionAndErrorDesc:x];
    }];
    
    [RACObserve(self.takeRewardValueTF, text) subscribeNext:^(id x) {
        [weakself updateActionAndErrorDesc:x];
    }];
    
    //顶部视图
    [self initHeaderView];
    //输入信息相关
    [self initInputView];
    //底部视图
    [self initFooterView];
    DEBUGG(@"%s %@", __FUNCTION__, self.validRewards);
    //更新当前数据
    [self updateViewInfoWith:self.validRewards];
    
    //刷新拉取数据
    [self refreshing];
    
    //初始化下拉刷新的操作
    [self scrollView:_contentScrollView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];
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


#pragma mark -------------视图初始化-------------
//整个顶部视图的尺寸
- (void)initHeaderView
{
    //金额标题
    self.validRewardTitleLabel.text = KTotalExtractableAmtTitle;
}

- (void)initFooterView
{
    //设置底部视图
    //左间距
    CGFloat left = self.takeDescLabelLeft.constant;
    CGFloat right = self.takeDescLabelRight.constant;
    //设置preferredMaxLayoutWidth，方便计算高度
    self.takeDescriptionLabel.preferredMaxLayoutWidth = MAIN_BOUNDS_SCREEN_WIDTH-(left+right);
    
    //操作按钮，提取说明
    [self initTakeActionBtn];
    
    //计算顶部视图的高度
    [self updateFooterViewFrame];
}

//提取按钮
- (void)initTakeActionBtn
{
    //提取按钮样式
    [self.takeActionBtn setTitle:KTakeRewardActionTitle forState:UIControlStateNormal];
    [self.takeActionBtn setTitle:KTakeRewardActionTitle forState:UIControlStateSelected];
}

- (void)initInputView
{
    self.takeRewardInputTitleLabel.text = KTakeRewardInputTitle;
    //输入框
    self.takeRewardValueTF.placeholder = [NSString stringWithFormat:@"%@%d", KTakeRewardInputPlaceholderTitle, kMaxTakeRewardValue];
}

#pragma mark ---------------刷新视图---------------
- (void)updateViewInfoWith:(KSValidRewardsEntity *)validRewards
{
    DEBUGG(@"%s %@", __FUNCTION__, self.validRewards);
    //奖励信息相关数据(页面)
    [self updateValidRewardsData:validRewards];
    
    //更新相关视图
    [self updateHeaderInfo];
    [self updateRewardInputInfo];
    [self updateBottomInfo];
}

//更新顶部视图
- (void)updateHeaderInfo
{
    NSString *totalValidReward = self.validRewards.totalExtractableAmt;
    if (!totalValidReward || totalValidReward.length <= 0)
    {
        totalValidReward = @"0.00";
    }
    totalValidReward = [KSBaseEntity formatAmountString:totalValidReward];
    //总金额信息
    self.validRewardLabel.text = totalValidReward;
}

//更新输入框视图
- (void)updateRewardInputInfo
{
    NSString *totalValidReward = self.validRewards.totalExtractableAmt;
    NSString *defaultStr = [self defaultValidInputRewardValue:totalValidReward];
    self.takeRewardValueTF.text = defaultStr;
}

//更新底部信息
- (void)updateFooterViewFrame
{
    [self.footerView setNeedsLayout];
    CGSize mainSize = MAIN_BOUNDS.size;
    CGFloat headerHeight  = [self.footerView systemLayoutSizeFittingSize:mainSize].height;
    CGRect frame = self.footerView.frame;
    frame.size.height = headerHeight;
    DEBUGG(@"%s %f", __FUNCTION__, frame.size.height);
    self.footerView.frame = frame;
    [self.footerView layoutIfNeeded];
}

- (void)updateBottomInfo
{
    NSString *value =  self.validRewards.totalExtractableAmt;
    BOOL canTake = [KSBaseEntity isValue1:value greaterValue2:@"0"];
    //操作按钮
    self.takeActionBtn.enabled = canTake;
    
    //更新描述信息
    [self updateRewardDescription];
}

- (void)updateRewardDescription
{
    NSArray *explainList = self.explainList;
    NSMutableString *explainStr = [NSMutableString string];
    //计算高度
    UIFont *font = self.takeDescriptionLabel.font;
    if(!font)
    {
        font = SYSFONT(12.0f);
    }
    NSDictionary *dic = @{NSFontAttributeName: font};
    
    NSMutableAttributedString *explainAttrStr = nil;
    if (!explainList || explainList.count <= 0)
    {
        explainStr = nil;
    }
    else
    {
        [explainStr appendString:KTakeRewardActionDescriptionTitle];
        //组合
        int index = 1;
        NSInteger start = 0;
        NSInteger length = 0;
        for (NSString *explainItem in explainList)
        {
            if (explainItem)
            {
                NSString *subStr = [NSString stringWithFormat:@"\n%d、%@", index,explainItem];
                if (index == 2)
                {
                    start = explainStr.length;
                    length = subStr.length;
                }
                [explainStr appendString:subStr];
                index++;
            }
        }
        explainAttrStr = [[NSMutableAttributedString alloc] initWithString:explainStr attributes:dic];
        
        if (length > 0)
        {
            NSDictionary *dic = @{NSForegroundColorAttributeName: UIColorFromHex(0xee7700)};
            [explainAttrStr addAttributes:dic range:NSMakeRange(start, length)];
        }
    }
    
    self.takeDescriptionLabel.attributedText = explainAttrStr;
    
    CGRect descFrame = self.takeDescriptionLabel.frame;
    CGSize size = [explainAttrStr boundingRectWithSize:CGSizeMake(descFrame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
//    CGSize size = [explainStr boundingRectWithSize:CGSizeMake(descFrame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    descFrame.size.height = size.height;
    self.takeDescriptionLabel.frame = descFrame;
    [self.takeDescriptionLabel layoutIfNeeded];
    DEBUGG(@"%s %f %@", __FUNCTION__, descFrame.size.height, explainStr);
    
    //描述高度适配
    [self updateFooterViewFrame];
}

//更新可提取奖励相关数据
- (void)updateValidRewardsData:(KSValidRewardsEntity *)validRewards
{
    //本地数据
    self.validRewards = validRewards;
    
    //描述
    NSArray *explainListTemp = validRewards.explainList;
    if (explainListTemp && explainListTemp.count > 0)
    {
        self.explainList = explainListTemp;
    }
}

//更新相关提示和按钮
- (void)updateActionAndErrorDesc:(NSString *)value
{
    NSString *valueStr = nil;
    NSString *errorTitle = nil;
    
    NSString *totalValidReward = self.validRewards.totalExtractableAmt;
    //检测金额格式
    KSRewardInputType type = [self checkValidRewardInput:value total:totalValidReward];
    switch (type)
    {
        case KSRewardInputTypeNormal:
        {
            //正常输入
            valueStr = value;
            errorTitle = nil;
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = YES;
            //按钮状态
            self.takeActionBtn.enabled = YES;
        }
        break;
        case KSRewardInputTypeEmpty:
        {
            //空
            valueStr = nil;
            errorTitle = nil;
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = YES;
            //按钮状态
            self.takeActionBtn.enabled = YES;
        }
        break;
        case KSRewardInputTypeLTOEZero:
        {
            //小于等于0
            valueStr = nil;
            //说明
            errorTitle = nil;
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = YES;
            //按钮状态
            self.takeActionBtn.enabled = NO;
        }
        break;
        case KSRewardInputTypeAboveMax:
        {
            //超过限额
            //说明
            errorTitle = [NSString stringWithFormat:@"%@%d%@", KRewardInputAboveMaxErrorMessage, kMaxTakeRewardValue, KUnit];
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = NO;
            //按钮状态
            self.takeActionBtn.enabled = YES;
        }
        break;
        case KSRewardInputTypeAboveTotal:
        {
            //超过总金额
            valueStr = value;
            //说明
            errorTitle = KRewardInputAboveTotalErrorMessage;
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = NO;
            //按钮状态
            self.takeActionBtn.enabled = YES;
        }
        break;
        case KSRewardInputTypeFormatError:
        {
            //输入格式错误
            //说明
            errorTitle = KRewardInputFormatErrorMessage;
            self.takeRewardActionDescLabel.text = errorTitle;
            self.takeRewardActionDescLabel.hidden = NO;
            //按钮置灰
            self.takeActionBtn.enabled = NO;
        }
        break;
        default:
        break;
    }
}

#pragma mark ------内部操作方法-----------
//刷新奖励数据
-(void)refreshing
{
    if (!_validRewardsBL)
    {
        _validRewardsBL = [[KSRewardBL alloc] init];
        _validRewardsBL.delegate = self;
    }
    //获取可提取奖励明细
    [_validRewardsBL doGetValidRewardsForDetail];
}

//提取奖励
- (IBAction)takeValidRewardAction:(id)sender
{
    [self showProgressHUD];
    
    //可提奖励
    NSString *value = self.takeRewardValueTF.text;
    [self.validRewardsBL doTakeRewardCashWith:value];
}

// 奖励明细查看
-(void)rewardInfoDetail
{
    //    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@&app=1",KRewardRecordsPage,USER_SESSIONID];
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KRewardRecordsPage data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:KRewardDetailTitle type:self.type];
}

- (NSString*)defaultValidInputRewardValue:(NSString*)value
{
    NSString *valueStr = nil;
    NSString *totalValidReward = self.validRewards.totalExtractableAmt;
    //检测金额格式
    KSRewardInputType type = [self checkValidRewardInput:value total:totalValidReward];
    switch (type)
    {
        case KSRewardInputTypeNormal:
        {
            //正常输入
            valueStr = value;
        }
        break;
        case KSRewardInputTypeEmpty:
        {
            //空
            valueStr = nil;
        }
        break;
        case KSRewardInputTypeLTOEZero:
        {
            //小于等于0
            valueStr = nil;
        }
        break;
        case KSRewardInputTypeAboveMax:
        {
            //超过限额
            valueStr = [NSString stringWithFormat:@"%d", kMaxTakeRewardValue];
        }
        break;
        case KSRewardInputTypeAboveTotal:
        {
            //超过总金额
            valueStr = value;
        }
        break;
        case KSRewardInputTypeFormatError:
        {
            //输入格式错误
            valueStr = nil;
        }
        break;
        default:
        break;
    }
    
    return valueStr;
}

//金额检测
- (KSRewardInputType)checkValidRewardInput:(NSString*)value total:(NSString*)total
{
    NSDecimalNumber *valueNum = nil;
    KSRewardInputType type = KSRewardInputTypeEmpty;
    if (!value)
    {
        return type;
    }
    
    valueNum = [NSDecimalNumber decimalNumberWithString:value];
    if (!valueNum)
    {
        type = KSRewardInputTypeFormatError;
        return type;
    }
    
    NSDecimal discount1 = valueNum.decimalValue;
    NSDecimalNumber *maxNum = [[NSDecimalNumber alloc] initWithInt:kMaxTakeRewardValue];
    NSDecimal discount2 = maxNum.decimalValue;
    NSDecimal discount3 = [NSDecimalNumber zero].decimalValue;
    //总奖励
    NSDecimal discount4 = [NSDecimalNumber decimalNumberWithString:total].decimalValue;
    
    NSComparisonResult result0 = NSDecimalCompare(&discount1, &discount3);
    NSComparisonResult result = NSDecimalCompare(&discount1, &discount2);
    NSComparisonResult result1 = NSDecimalCompare(&discount1, &discount4);
    
    if (result0 == NSOrderedSame || result0 == NSOrderedAscending)
    {
        //金额小于等于0
        type = KSRewardInputTypeLTOEZero;
    }
    else if (result1 == NSOrderedDescending)
    {
        //超过总金额
        if (result == NSOrderedDescending)
        {
            //金额大于2000
            type = KSRewardInputTypeAboveMax;
        }
        else
        {
            //超过总奖励 小于等于2000
            type = KSRewardInputTypeAboveTotal;
        }
    }
    else if (result == NSOrderedDescending)
    {
        //金额大于2000
        type = KSRewardInputTypeAboveMax;
    }
    else
    {
        //升序 金额小于等于2000
        type = KSRewardInputTypeNormal;
    }
    return type;
}

#pragma mark -
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    NSString *tradeId = result.tradeId;
    //可提取奖励明细(新 红包＋现金券＋推广收益)
    if ([tradeId isEqualToString:KGetValidRewardsDetailTradeId])
    {
        [self.contentScrollView.mj_header endRefreshing];
        [self hideProgressHUD];
        
        id entity = result.body;
        if ([entity isKindOfClass:[KSValidRewardsEntity class]])
        {
            DEBUGG(@"%s %@", __FUNCTION__, self.validRewards);
            //更新当前数据
            [self updateViewInfoWith:entity];
        }
    }
    else if([tradeId isEqualToString:KTakeRewardCashTradeId])
    {
        //刷新数据
        [self refreshing];
        //停止转菊花
        [self hideProgressHUD];
        //更新视图
//        [self updateViewInfoWith:nil];
        //更新账户信息
        [USER_MGR updateUserAssets];
        //发送通知提现成功
        [NOTIFY_CENTER postNotificationName:KTakeValidRewardNotificationKey object:nil];
        //toast
        NSString *errorMsg = KRewardGetSuccessText;
        [self.view makeToast:errorMsg duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self.contentScrollView.mj_header endRefreshing];
    [self hideProgressHUD];
    
    NSString *errorMsg = result.errorDescription;
    if (!errorMsg || errorMsg.length <= 0)
    {
        NSString *tradeId = result.tradeId;
        if ([tradeId isEqualToString:KGetValidRewardsDetailTradeId])
        {
            errorMsg = KGetRewardDetailErrorMessage;
        }
        else if([tradeId isEqualToString:KTakeRewardCashTradeId])
        {
            errorMsg = KTakeRewardActionErrorMessage;
        }
    }
    
    [self.view makeToast:errorMsg duration:2.0 position:CSToastPositionCenter];
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self.contentScrollView.mj_header endRefreshing];
    [self hideProgressHUD];
    [self.view makeToast:KRequestNetworkErrorMessage duration:2.0 position:CSToastPositionCenter];
}
@end
