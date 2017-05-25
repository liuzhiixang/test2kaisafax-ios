//
//  KSRechargeVC.m
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRechargeVC.h"
#import "KSFastCardCell.h"
#import "KSCardCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSRechargeFastVC.h"
#import "KSWebVC.h"
#import "KSRechargeBL.h"
#import "KSFileUtil.h"
#import "KSBankBL.h"
#import "KSTextField.h"
#import "KSVersionMgr.h"

#define kCellMargin 8
#define kRadius 5
#define HEIGHT_ZERO 0.01

//#define CACHE_RECHARGE @"recharge.cache"

typedef enum : NSUInteger {
    CardTypeFast = 0,
    CardTypeNormal,
    CardTypeMax,
} CardType;


//#define NormalCardTitles @[@"网银支付",@"快捷支付"]
//#define NormalCardDetails @[@"支持多家网银支付服务", @"支持主流银行快捷支付服务"]
//#define NormalCardIcons @[@"ic_bank_union", @"ic_bank_fast"]

#define kTitle @"Title"
#define kDetail @"Detail"
#define kIcon @"Icon"


@interface KSRechargeVC ()<UITableViewDataSource, UITableViewDelegate,  KSBLDelegate>
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet KSTextField *inputTextField;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) KSRechargeBL *rechargeBL;

@property (nonatomic, strong) KSRechargeEntity *rechargeEntity;

@property (nonatomic, copy) NSArray *chargeArray;

@end

@implementation KSRechargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = KRechargeTitle;
    // Do any additional setup after loading the view from its nib.
    [_tableView registerNib:[UINib nibWithNibName:kFastCardCell bundle:nil] forCellReuseIdentifier:kFastCardCell];
    [_tableView registerNib:[UINib nibWithNibName:kCardCell bundle:nil] forCellReuseIdentifier:kCardCell];

    _inputTextField.text = _available;
    _inputTextField.maxValue = AMOUNT_MAX_VALUE;
    
    NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
    self.rechargeEntity = [KSRechargeEntity yy_modelWithJSON:json];
    [self updateRechageInfo];
    
    _rechargeBL = [[KSRechargeBL alloc]init];
    _rechargeBL.delegate = self;
    
    [self setNavRightButtonByImage:@"ic_help"  selectedImageName:nil navBtnAction:@selector(helpAction:)];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_rechargeBL doGetRechargeInfo];
}


- (void)updateRechageInfo
{
 
    NSMutableArray *array = [NSMutableArray array];
    if (!_rechargeEntity.expressCard) {
        [array addObject:@{kTitle : KRechargeQuickPay, kDetail : KRechargeQuickPayDetail, kIcon : @"ic_bank_fast"}];
    }
    [array addObject:@{kTitle : KRechargeUnionPay, kDetail : KRechargeUnionPayDetail , kIcon : @"ic_bank_union"}];
    
    self.chargeArray = array;
    
    _availableLabel.text = [KSBaseEntity formatAmountString:_rechargeEntity.available withUnit:KUnit];
    [_tableView reloadData];
}


- (NSString *)getCacheFileName
{
    return [NSString stringWithFormat:@"%lld.recharge.cache", USER_MGR.user.user.userId];
}

#pragma mark - Actions
- (IBAction)endEditAction:(id)sender {
    [self.view endEditing:YES];
}

- (void)helpAction:(id)sender
{
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KDepositExplain data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:KRechargeDescription type:self.type];
}


- (void)unbindAction:(id)sender
{
    [KSWebVC pushInController:self.navigationController urlString:_rechargeEntity.UNBIND_QUICK_CARD_URL title:KRechargeUnbind type:self.type];
}

- (void)rechargeAction:(id)sender
{
    [self rechargeByExproess:YES];
}


- (void)rechargeByExproess:(BOOL)b
{
    NSString *amount = _inputTextField.text;
    if (![KSBaseEntity isValue1:amount greaterValue2:@"0"]) {
        [self showLGAlertTitle:KRechargeInputTips];
        return;
    }
    
    KSBankEntity *entity = _rechargeEntity.bank;
    if ([KSBaseEntity isValue1:amount greaterValue2:[KSBaseEntity formatFloat:entity.amount]]) {
        [self showLGAlertTitle:KRechargeOutOfLimit];
        return;
    }
    
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"amount"] = amount;
//    //充值方式 QP-快捷充值, B2C 网银充值
//    if (b) {
//        dict[@"gateBusiId"] =  @"QP";
//        dict[@"openBankId"] = _rechargeEntity.expressCard.bankCode;
//        //dict[@"actionFlag"] = [NSNumber numberWithInteger:KSRechargeTypeNormal];//@"3";
//    }else{
//        dict[@"gateBusild"] = @"B2C";
//    }
//    
//    NSInteger tempActionFlag = self.actionFlag;
//    if (tempActionFlag <= 0)
//    {
////        dict[@"actionFlag"] = self.actionFlag;
//        tempActionFlag = KSRechargeTypeNormal;
//    }
//    dict[@"actionFlag"] = [NSNumber numberWithInteger:tempActionFlag];
    
//    [KSWebVC pushInController:self.navigationController urlString:KAddAssetsPage title:KRechargeTitle params:dict type:self.type];
    self.bankType = KSBankListTypeQuickPay;
    if(!b)
    {
        self.bankType = KSBankListTypeInternetBank;
    }
    
    //跳转充值界面
    [self gotoAddAssetsPageWith:amount bank:entity];
}

//跳转充值界面
- (void)gotoAddAssetsPageWith:(NSString *)amount bank:(KSBankEntity*)entity
{
    //请求参数
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(amount)
    {
        dict[kAmountKey] = amount;
    }
    NSString *bankCode = entity.code;
    if(bankCode)
    {
        dict[kBankCodeKey] = bankCode;
    }
    dict[kRechargeTypeKey] = @(self.bankType);
    
    NSInteger tempActionFlag = self.actionFlag;
    if (tempActionFlag <= 0)
    {
        tempActionFlag = KSRechargeTypeNormal;
    }
    dict[kActionFlagKey] = @(tempActionFlag);
    NSInteger versionCode = [[KSVersionMgr sharedInstance] getAppVersion];
    dict[kVersionCodeKey] = @(versionCode);
    //组合字符串
    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KAddAssetsTradeId data:dict error:nil];
    NSString *title = KRechargeTitle;
    [KSWebVC pushInController:self.navigationController urlString:urlString title:title type:self.type];
}

/**
 *  @author semny
 *
 *  跳转到 快捷支付/网银支付的页面
 *
 *  @param type 快捷：KSBankListTypeQuickPay；网银：KSBankListTypeInternetBank
 */
- (void)turn2RechargeFastPageByType:(NSInteger)type
{
    KSRechargeFastVC *vc = [[KSRechargeFastVC alloc ]init];
    vc.rechargeNumber = _inputTextField.text;
    vc.available = _availableLabel.text;
    vc.type = type;//indexPath.row == 1 ? KSBankListTypeQuickPay:KSBankListTypeInternetBank    ;
    vc.resultType = self.type;
    vc.actionFlag = self.actionFlag;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mrak - table delegate & datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_chargeArray.count == 2 && section == 0) {
        return 0.01;
    }
    
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_chargeArray.count == 2) {
        return 0.01;
    }
    return 40;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 24)];
    label.nuiClass =  NUIAppSmallDarkGrayLabel;
    [view addSubview:label];
    
    if (section == 0) {
        label.text = _rechargeEntity.expressCard ? KRechargeBankcardPay : @"";
    }else{
        label.text = KRechargeOtherPay;
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CardTypeMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == CardTypeFast) {
        return _rechargeEntity.expressCard ? 1 : 0 ;
    }
    return _chargeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = (indexPath.section == CardTypeFast ? kFastCardCell : kCardCell);
    return [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        @WeakObj(self);
        KSFastCardCell *cell = [tableView dequeueReusableCellWithIdentifier:kFastCardCell];
        [cell updateItem:_rechargeEntity.expressCard bank:_rechargeEntity.bank];
        [cell setCardDisable:!_rechargeEntity.isAble];
        [[[cell.rechargeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x) {
            [weakself rechargeAction:nil];
        }];
//        [cell.rechargeButton removeTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.rechargeButton addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
//        RAC(cell.rechargeButton, enabled) = [[RACSignal combineLatest:@[_inputTextField.rac_textSignal] reduce:^id(NSString *input){
//            NSInteger inputNumber = input.integerValue;
//            BOOL canDo = inputNumber > 0 && inputNumber <= _rechargeEntity.bank.amount;
//            if (inputNumber > _rechargeEntity.bank.amount) {
//                [weakself showToastWithTitle:@"超出银行单笔限额"];
//            }
//            return @(canDo);
//        }]takeUntil:cell.rac_prepareForReuseSignal];
        
        cell.unbindButton.enabled = _rechargeEntity.UNBIND_QUICK_CARD_URL;
        [cell.unbindButton removeTarget:self action:@selector(unbindAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.unbindButton addTarget:self action:@selector(unbindAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell layoutIfNeeded];
        return cell;
    }
    
    NSDictionary *dict = [_chargeArray objectAtIndex:indexPath.row];
    
    KSCardCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardCell];
    [cell tableView:tableView setCornerRaduis:0 byRoundType:KSCellRoundCornerTypeCenter inLayoutMargins:UIEdgeInsetsMake(0, 0, 0.5, 0)];
//    [cell tableView:tableView autoCornerRaduis:kRadius atIndexPath:indexPath inLayoutMargins:UIEdgeInsetsMake(0, kCellMargin, 0.5, kCellMargin)];
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    
    cell.titleLabel.text = dict[kTitle];
    cell.subtitleLabel.text = dict[kDetail];
    cell.iconImageView.image = [UIImage imageNamed:dict[kIcon]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self.view endEditing:YES];
        return;
    }
    
    //跳转到网银，快捷充值界面
    if (_chargeArray.count > 1) {
        NSInteger type = (indexPath.row == 0 ? KSBankListTypeQuickPay:KSBankListTypeInternetBank);
        [self turn2RechargeFastPageByType:type];
    }else{
        [self turn2RechargeFastPageByType:KSBankListTypeInternetBank];
    }
}

#pragma mark - BL Delegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    id entity = result.body;
    if ([entity isKindOfClass:[KSRechargeEntity class]]) {
        self.rechargeEntity = entity;
        
        NSDictionary *json = [entity yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
        [self updateRechageInfo];
    }
    INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    
}


- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    ERROR(@"failedHandle %@", NSStringFromClass([result class]));
    self.rechargeEntity = nil;
    [self updateRechageInfo];
    [self showToastWithTitle:KRequestUnknowErrorMessage];
}


- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    self.rechargeEntity = nil;
    [self updateRechageInfo];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself hideProgressHUD];
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:2.0 position:CSToastPositionCenter];
    });
}


@end
