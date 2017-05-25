//
//  KSRechargeFastVC.m
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRechargeFastVC.h"
#import "KSCardCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "KSBankListEntity.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KSWebVC.h"
#import "KSUserMgr.h"
#import "KSTextField.h"
#import "KSOpenAccountVC.h"
#import "YYText.h"
#import "KSVersionMgr.h"
#import "KSOpenAccountBL.h"

#define kCellMargin 8
#define kRadius 5
#define HEIGHT_ZERO 0.01


@interface KSRechargeFastVC ()<KSBLDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *rechargeButton;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet KSTextField *inputTextField;

@property (nonatomic, strong) KSBankBL *bankBL;
@property (nonatomic, strong) KSBankListEntity *bankEntity;
@property (nonatomic, copy) NSArray<KSBankEntity *> *normalBankArray;//不需要开通无卡支付
@property (nonatomic, copy) NSArray<KSBankEntity *> *neededBankArray;//需要开通无卡支付
@property (nonatomic, strong) NSDictionary *bankTelDict;

@end

@implementation KSRechargeFastVC


- (id)init
{
    self = [super initWithNibName:@"KSRechargeFastVC" bundle:nil];
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (_type == KSBankListTypeQuickPay) {
        self.title = KRechargeQuickPay;
    }else{
        self.title = KRechargeUnionPay;
    }
    
    // Do any additional setup after loading the view from its nib.
    

    _bankTelDict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"bankTel" withExtension:@"plist"]];
    
    [_tableView registerNib:[UINib nibWithNibName:kCardCell bundle:nil] forCellReuseIdentifier:kCardCell];
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    _inputTextField.maxValue = AMOUNT_MAX_VALUE;
    _inputTextField.text = _rechargeNumber;
    _availableLabel.text = _available;
    
    _bankBL = [[KSBankBL alloc]init];
    _bankBL.delegate = self;
    [_bankBL doGetBankListWith:_type];
    
//    RAC(_rechargeButton, enabled) = [RACSignal combineLatest:@[_inputTextField.rac_textSignal, RACObserve(self, payIndex)] reduce:^id(NSString *input, NSNumber *idx){
//        if (USER_MGR.assets.isOpenAccount) {
//            return @(YES);
//        }
//        
//        NSInteger inputNumber = input.integerValue;
//        if (_type == KSBankListTypeQuickPay)
//        {
//            KSBankEntity *entity = _bankEntity.bankList[idx.integerValue];
//            return @(input.length > 0 && inputNumber <= entity.amount);
//        }
//        return @(inputNumber > 0);
//    }];
    
    
    @WeakObj(self);
    [RACObserve(USER_MGR, assets) subscribeNext:^(KSNewAssetsEntity *entity) {
        BOOL isOpenAccount = entity.isOpenAccount ;
        [weakself.rechargeButton setTitle:(!isOpenAccount ? KOpenAccountTitle : KRechargeConfirm) forState:UIControlStateNormal];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rechargeAction:(id)sender
{
    //需要开通托管帐户
    if (![USER_MGR.assets isOpenAccount])
    {
        [self turn2OpenAccountPage];
        return;
    }
    
    NSString *amount = _inputTextField.text;
    if (![KSBaseEntity isValue1:amount greaterValue2:@"0"]) {
        [self showLGAlertTitle:KRechargeInputTips];
        return;
    }
    KSBankEntity *entity = [self bankEntityAtIndexPath:_selectedIndexPath];
    if (_type == KSBankListTypeQuickPay && [KSBaseEntity isValue1:amount greaterValue2:[KSBaseEntity formatFloat:entity.amount]]) {
        [self showLGAlertTitle:KRechargeOutOfLimit];
        return;
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
    dict[kRechargeTypeKey] = @(self.type);
    
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
    [KSWebVC pushInController:self.navigationController urlString:urlString title:title type:self.resultType];
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
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:self.resultType];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
        
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:self.resultType];
}


- (KSBankEntity *)bankEntityAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _normalBankArray[indexPath.row];
    }
    return _neededBankArray[indexPath.row];
}


#pragma mark - 

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _normalBankArray.count > 0) {
        return 30;
    }
    if (section == 1 && _neededBankArray.count > 0) {
        return 40;
    }
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    if (section == 0 && _normalBankArray.count) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, CGRectGetWidth(self.view.frame) - 40, 30)];
        label.nuiClass = NUIAppSmallDarkGrayLabel;
        [view addSubview:label];
        
        label.text = KRechargeSelectedBankCard;
    }
    if (section == 1 && _neededBankArray.count > 0) {
        
        NSString *tips = KRechargeOpenCardTips;
        NSString *bankPay = KRechargeUnionNFCPay;
        NSString *open = KRechargeOpenWay;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:tips];
        YYLabel *label = [[YYLabel alloc]initWithFrame:CGRectMake(20, 0, CGRectGetWidth(self.view.frame) - 40, 40)];
        label.numberOfLines = 0;
        @WeakObj(self);
        [text yy_setTextHighlightRange:[tips rangeOfString:bankPay] color:NUI_HELPER.appOrangeColor backgroundColor:NUI_HELPER.appLightGrayColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [KSWebVC pushInController:weakself.navigationController urlString:@"https://www.95516.com/static/union/pages/card/openFirst.html?entry=openPay" title:KRechargeOpenOnlinePay type:weakself.resultType];
        }];
        [text yy_setTextHighlightRange:[tips rangeOfString:open] color:NUI_HELPER.appOrangeColor backgroundColor:NUI_HELPER.appLightGrayColor  tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [KSWebVC pushInController:weakself.navigationController urlString:@"https://lab.chinapnr.com/cash/cashier/charge/desktop/quickPayTutorial" title:KRechargeHowToOpenNFCPay type:weakself.resultType];
        }];
        
        label.attributedText = text;


        [view addSubview:label];
        
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _normalBankArray.count;
    }
    return _neededBankArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:kCardCell cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSBankEntity *entity = [self bankEntityAtIndexPath:indexPath];
    
    KSCardCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardCell];
    BOOL showCheckBox = (indexPath.row == _selectedIndexPath.row && indexPath.section == _selectedIndexPath.section);
    cell.payCheckBox.hidden = !showCheckBox;
    cell.payCheckBox.userInteractionEnabled = NO;
    cell.titleLabel.text = entity.name;
    if (_type == KSBankListTypeQuickPay) {
        cell.subtitleLabel.text = [entity getDetailText];
    }else{
        cell.subtitleLabel.text = _bankTelDict[entity.code];
    }
    
    UIImage *image = [UIImage imageNamed:@"ic_bank_fast"];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:entity.bankIconUrl] placeholderImage:image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    if (indexPath.section == 1) {
//        [KSWebVC pushInController:self.navigationController urlString:@"https://www.95516.com/static/union/pages/card/openFirst.html?entry=openPay" title:@"开通在线支付"];
//        return;
//    }
    _selectedIndexPath = indexPath;
    [tableView reloadData];
}

#pragma mark -  DZNEmptyDataSet

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = KRechargeNoneBank;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:KTryRefresh attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    [self showProgressHUD];
    [_bankBL doGetBankListWith:_type];
}


#pragma mark - BL Delegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self hideProgressHUD];
    id entity = result.body;
    
    if ([entity isKindOfClass:[KSBankListEntity class]]) {
        self.bankEntity = entity;
        
        NSMutableArray *normalArray = [NSMutableArray array];
        NSMutableArray *neededArray = [NSMutableArray array];
        for (KSBankEntity *bank in _bankEntity.bankList) {
            if (bank.type == 0) {
                [normalArray addObject:bank];
            }else{
                [neededArray addObject:bank];
            }
        }
        
        self.normalBankArray = normalArray;
        self.neededBankArray = neededArray;
        
        [_tableView reloadData];
    }
    INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [_tableView reloadData];
}


- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    [_tableView reloadData];
}


@end
