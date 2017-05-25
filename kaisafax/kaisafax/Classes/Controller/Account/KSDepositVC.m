//
//  KSDepositVC.m
//  kaisafax
//
//  Created by Jjyo on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSDepositVC.h"
#import "KSWithdrawBL.h"
#import "KSWithdrawEntity.h"
#import "UIImageView+WebCache.h"
#import "KSFileUtil.h"
#import "MJRefresh.h"
#import "KSWebVC.h"
#import "KSVersionMgr.h"
#import "KSUserMgr.h"
#import "UIView+Round.h"
#import "KSTextField.h"
#import "KSOpenAccountVC.h"
#import "KSVersionMgr.h"
#import "KSOpenAccountBL.h"

typedef NS_ENUM(NSInteger,KSDepositType)
{
    KSDepositTypeFast = 1, //快速提现
    KSDepositTypeGeneral , //一般提现
    KSDepositTypeImmediate , //即时提现
};
//// 汇付普通提现
//#define TYPE_HF_GENERAL @"GENERAL"
//// 汇付加急提现
//#define TYPE_HF_IMMEDIATE @"IMMEDIATE"

//#define CACHE_DEPOSIT @"diposit.cache"

@interface KSDepositVC () <KSBLDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UIView *modeView;
@property (weak, nonatomic) IBOutlet UIView *addCardView;
@property (weak, nonatomic) IBOutlet UIView *fastCardView;


@property (weak, nonatomic) IBOutlet UIImageView *fastExpressIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bankIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

//提现方式
@property (weak, nonatomic) IBOutlet UISegmentedControl *withdrawSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *withdrawSingleLabel;
@property (weak, nonatomic) IBOutlet UILabel *intoTimeLabel;//到账时间
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;//手续费

@property (weak, nonatomic) IBOutlet UIImageView *expressImageView;
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
@property (weak, nonatomic) IBOutlet KSTextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *availeLabel;

@property (weak, nonatomic) IBOutlet UILabel *freeTakeLabel;
@property (nonatomic, strong) KSWithdrawBL *bl;
@property (nonatomic, strong) KSWithdrawEntity *entity;
@end


@implementation KSDepositVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = KDepositTitle;
        
    _addCardView.hidden = YES;
    [_addCardView makeCorners:UIRectCornerAllCorners radius:5];
    [_fastCardView makeCorners:UIRectCornerAllCorners radius:5];
    
    _inputTextField.maxValue = AMOUNT_MAX_VALUE;
    
    [self setNavRightButtonByImage:@"ic_help" selectedImageName:nil navBtnAction:@selector(helpAction:)];
    NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
    self.entity = [KSWithdrawEntity yy_modelWithJSON:json];
    [self updateInfoUI];

    
//    @WeakObj(self);
//    [RACObserve(_inputTextField, text) subscribeNext:^(NSString *text) {
//        if (weakself.entity && weakself.withdrawSegmentedControl.selectedSegmentIndex == 1) {
//            [weakself updateMode:NO];
//        }
//    }];
    
//    RAC(_takeButton, enabled) = [RACSignal combineLatest:@[_inputTextField.rac_textSignal] reduce:^id(NSString *text){
//        CGFloat value = text.floatValue;
//        CGFloat maxValue = MIN(AMOUNT_MAX_VALUE, weakself.entity.available);
//        BOOL canTake = value > 0 && value <= maxValue;
//        return @(canTake);
//    }];
    
    
    
    //刷新动画及操作
    [self scrollView:_scrollView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshing];
}


- (void)refreshing
{
    if (!_bl) {
        _bl = [[KSWithdrawBL alloc] init];
        _bl.delegate = self;
    }
    [_bl doGetWithdrawInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)updateInfoUI
{
    _bankView.hidden = !_entity.bankCard;
    _modeView.hidden = !_entity;
    _addCardView.hidden = (_entity.bankCard!=nil);
    
    _nameLabel.text = _entity.bankCard.name;
    _availeLabel.text = [KSBaseEntity formatAmountString:_entity.available withUnit:@"元"];
    _bankNameLabel.text = _entity.bank.name;
    _expressImageView.hidden = !_entity.bankCard.express;
    
    /**
     *  @author semny 2016-09-23
     *
     *  修改无快捷卡的时候置灰操作按钮的问题
     */
    BOOL hasCard = _entity.bankCard==nil?NO:YES;
    _takeButton.enabled = hasCard;//_entity.bankCard.express;//提现没有绑定银行卡时，提现按钮要置灰
    _bankDetailLabel.text = [_entity.bankCard formatAccount];//[NSString stringWithFormat:@"%@ | %@", _entity.bankCard.account, _entity.bankCard.name];
    
    UIImage *defaultImage = [UIImage imageNamed:@"ic_bank_fast"];
    [_bankIconImageView sd_setImageWithURL:[NSURL URLWithString:_entity.bank.bankIconUrl] placeholderImage:defaultImage];
    _fastExpressIconImageView.hidden = !_entity.bankCard.express;
    
    /**
     *  @author semny 2016-09-27
     *
     *  是否支持加急提现
     */
    BOOL isImmediate = _entity.isImmediate;
    //不支持加急提现则显示普通提现,支持则现实两种提现方式切换
    _withdrawSegmentedControl.hidden = !isImmediate;
    _withdrawSingleLabel.hidden = isImmediate;
    if (isImmediate)
    {
        //支持加急提现
        [self selectedAction:nil];
    }
    else
    {
        //普通提现
        NSArray *typeList = _entity.typeList;
        KSWithdrawTypeEntity *entity = nil;
        if (typeList && typeList.count > 0)
        {
            entity = typeList[0];
            [self updateMode:entity];
        }
    }
}


- (void)updateMode:(KSWithdrawTypeEntity *)entity
{
    //普通
    _intoTimeLabel.text = entity.paymentDate;
    
    NSInteger type = entity.type;
    //
    if (type == KSDepositTypeGeneral)
    {
        _feeLabel.text = [KSBaseEntity formatAmount:entity.withdrawFee.floatValue withUnit:@"元"];
        _freeTakeLabel.hidden = NO;
    }else{
        _freeTakeLabel.hidden = YES;
        _feeLabel.text = entity.withdrawFee;
    }
    _freeTakeLabel.text = [NSString stringWithFormat:KDepositFreeTake, (entity.freeWithdrawTimes - entity.withdrawTimes)];

}

- (NSString *)getCacheFileName
{
    return [NSString stringWithFormat:@"%lld.diposit.cache", USER_MGR.user.user.userId];
}

#pragma mark - Action
- (IBAction)addCardAction:(id)sender {
    if(![USER_MGR.assets isOpenAccount])
        // 跳转开户页面
        [self turn2OpenAccountPage];
    else
    {
        NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KBindBankCardsPage data:nil error:nil];
        [KSWebVC pushInController:self.navigationController urlString:urlStr title:KDepositAddBankcard type:self.type];
    }
}

- (void)helpAction:(id)sender
{
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KWithdrawExplain data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:KDepositDescription type:self.type];
}

//选择提现模式
- (IBAction)selectedAction:(id)sender
{
    NSUInteger idx = _withdrawSegmentedControl.selectedSegmentIndex;
    if (idx < _entity.typeList.count) {
        KSWithdrawTypeEntity *entity = _entity.typeList[idx];
        [self updateMode:entity];
    }
}

//提现
- (IBAction)takeAction:(id)sender
{
    if(![USER_MGR.assets isOpenAccount])
    {
        // 跳转开户页面
        [self turn2OpenAccountPage];
    }
    else{
        if (_entity.typeList.count == 0) {
            return;
        }
    
        NSString *amount = _inputTextField.text;
        if (![KSBaseEntity isValue1:amount greaterValue2:@"0"]) {
            [self showLGAlertTitle:KDepositEnterAmount];
            return ;
        }
        if ([KSBaseEntity isValue1:amount greaterValue2:_entity.available]) {
            [self showLGAlertTitle:KDepositOutOfLimit];
            return;
        }
        
        /**
         *  @author semny
         *
         *  根据是否支持加急提现判断
         */
        BOOL isImmediate = _entity.isImmediate;
        NSInteger withdrawType = KSDepositTypeGeneral;
        if (isImmediate)
        {
            NSUInteger idx = _withdrawSegmentedControl.selectedSegmentIndex;
            withdrawType = idx == 0 ? KSDepositTypeGeneral : KSDepositTypeImmediate;
        }

//        //拿到build版本
//        NSDictionary  *dict = [[NSBundle mainBundle]infoDictionary];
//        NSString *app_build = [dict objectForKey:@"CFBundleVersion"];
//        [KSWebVC pushInController:self.navigationController urlString:KCashGetAssetsPage title:KDepositTaked params:@{@"amount": amount, @"cashChl" : cashChl,@"verCode":app_build}  type:KSWebSourceTypeAccount];
        [self gotoCashGetPageWith:withdrawType amount:amount type:KSWebSourceTypeAccount];
    }
}

- (void)gotoCashGetPageWith:(NSInteger)withdrawType amount:(NSString*)amount type:(NSInteger)type
{
    if (withdrawType < 0 || !amount || amount.length <= 0)
    {
        return;
    }
    NSString *actionFlag = @"test";
    NSInteger versionCode = [[KSVersionMgr sharedInstance] getAppVersion];
    NSDictionary *dict = @{kWithdrawTypeKey : @(withdrawType), kAmountKey :amount, kActionFlagKey:actionFlag, kVersionCodeKey: @(versionCode)};
    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KCashGetAssetsPage data:dict error:nil];
    NSString *title = KDepositTaked;
    [KSWebVC pushInController:self.navigationController urlString:urlString title:title type:type];
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
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:self.type];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:self.type];
}
#pragma mark - BL Delegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [_scrollView.mj_header endRefreshing];
    id entity = result.body;
    if ([entity isKindOfClass:[KSWithdrawEntity class]]) {
        self.entity = entity;
        [self updateInfoUI];
        
        NSDictionary *json = [entity yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
    }
    INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    
}


- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [_scrollView.mj_header endRefreshing];
    ERROR(@"failedHandle %@", NSStringFromClass([result class]));
    self.entity = nil;
    [self updateInfoUI];
    [self showToastWithTitle:@"服务器连接失败!"];
}


- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    self.entity = nil;
    [self updateInfoUI];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself hideProgressHUD];
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:2.0 position:CSToastPositionCenter];
    });
}



@end
