//
//  KSBankCardsVC.m
//  kaisafax
//
//  Created by BeiYu on 16/8/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBankCardsVC.h"
#import "KSUserMgr.h"
//#import "KSUserInfoBL.h"
#import "KSNBankCardCell.h"
#import "KSCardItemEntity.h"
//#import "KSUserCardsEntity.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSDashView.h"
#import "KSWebVC.h"
#import "KSBindBankCardVC.h"
#import "KSOpenAccountVC.h"
#import "KSAddBankCardCell.h"
#import "KSBankCardBL.h"
#import "KSFileUtil.h"
#import "KSOpenAccountBL.h"

@interface KSBankCardsVC ()<KSBLDelegate,KSNBankCardCellDelegate,KSAddBankCardCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *bankTableView;
@property (strong, nonatomic) NSArray *cardsArray;
@property (strong, nonatomic) KSBankCardBL *userInfoBL;
//解绑
@property (nonatomic,strong) KSBankCardBL *bankCardBL;
//同步银行卡
@property (nonatomic,strong) KSBankCardBL *syncBankBL;
//@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL hasExpress;

@end

@implementation KSBankCardsVC
-(KSBankCardBL *)bankCardBL
{
    if (!_bankCardBL) {
        self.bankCardBL = [[KSBankCardBL alloc]init];
        self.bankCardBL.delegate = self;
    }
    return _bankCardBL;
}

-(KSBankCardBL *)syncBankBL
{
    if (!_syncBankBL)
    {
        _syncBankBL = [[KSBankCardBL alloc]init];
        _syncBankBL.delegate = self;
    }
    return _syncBankBL;
}

-(KSBankCardBL *)userInfoBL
{
    if (!_userInfoBL) {
        _userInfoBL = [[KSBankCardBL alloc]init];
        _userInfoBL.delegate = self;
    }
    
    return _userInfoBL;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //导航栏相关
    [self configNav];
    
    self.bankTableView.separatorColor = [UIColor clearColor];

    NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
    self.cardsArray = [NSArray yy_modelArrayWithClass:[KSCardItemEntity class] json:json];
    // 判断是否绑定银行卡
    BOOL hasExpress = NO;
    for (KSCardItemEntity *item in self.cardsArray)
    {
        if (item.express)
        {
            hasExpress = YES;
            break;
        }
    }
    self.hasExpress = hasExpress;
    
    kRegisterCellNib(self.bankTableView,KNBankCardsCell);
    kRegisterCellNib(self.bankTableView,KAddBankCardCell);
    
    //配置下拉上拉刷新操作
    [self tableRefreshGif];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.bankTableView.mj_header beginRefreshing];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [USER_MGR updateUserAssets];
}


- (NSString *)getCacheFileName
{
    return [NSString stringWithFormat:@"%lld.bankcards.cache", USER_MGR.user.user.userId];
}

#pragma mark - 加载视图
- (void)configNav
{
    self.title = KBankCardTitle/*@"我的银行卡"*/;
    //右边按钮
    [self setNavRightButtonByText:@"同步" titleColor:WhiteColor imageName:nil selectedImageName:nil navBtnAction:@selector(syncBankCards)];
}

- (void)syncBankCards
{
    [self showProgressHUD];
    [self.syncBankBL doSyncBankCard];
}

#pragma mark - 刷新控件
-(void)tableRefreshGif
{
    // 添加动画图片的上拉刷新
    [self scrollView:_bankTableView headerRefreshAction:@selector(refreshing) footerRefreshAction:nil];
}

-(void)refreshing
{
    [self.userInfoBL doGetUserBankCards];
}

#pragma mark-datasource
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count = self.cardsArray.count;
    //无快捷卡或者无卡
    if (!self.hasExpress)
    {
        count += 1;
    }
    
    return  count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger count = self.cardsArray.count;
    UITableViewCell *tempCell = nil;
    if (self.hasExpress)
    {
        //快捷卡
        KSNBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:KNBankCardsCell];
        KSCardItemEntity *entity = nil;
        if (section < count)
        {
            entity = (KSCardItemEntity*)self.cardsArray[section];
        }
        [cell updateItem:entity];
        cell.delegate = self;
        tempCell = cell;
    }
    else
    {
        //无快捷卡
        if (count <= 0)
        {
            KSAddBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:KAddBankCardCell];
            cell.delegate = self;
            tempCell = cell;
        }
        else
        {
            if (section < count)
            {
                KSNBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:KNBankCardsCell];
                KSCardItemEntity *entity = nil;
                entity = (KSCardItemEntity*)self.cardsArray[section];
                [cell updateItem:entity];
                cell.delegate = self;
                tempCell = cell;
            }
            else
            {
                KSAddBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:KAddBankCardCell];
                cell.delegate = self;
                tempCell = cell;
            }
        }
    }
    tempCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return tempCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat viewWidth = MAIN_BOUNDS_SCREEN_WIDTH;
    CGFloat cellHeight = viewWidth*152.0f/375.0f;
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

//-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 && self.cardsArray.count == 0)
//    {
//        if (![USER_MGR.assets isOpenAccount])
//        {
//            [self turn2OpenAccountPage];
//        }
//        else
//        {
//            KSBindBankCardVC *vc = [[KSBindBankCardVC alloc] initWithUrl:KBindBankCardsPage title:@"绑定银行卡"  params:@{@"imei":USER_SESSIONID} type:self.type runJS:YES];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//}

#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@ %@",blEntity,result);
    
    NSString *tradeId = result.tradeId;
    if ([tradeId isEqualToString:KSyncBankCardTradeId])
    {
        [self hideProgressHUD];
    }
    else
    {
        [self.bankTableView.mj_header endRefreshing];
    }
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
    });
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@ %@",blEntity,result);
    
    NSString *tradeId = result.tradeId;
    if ([tradeId isEqualToString:KGetBankCardsTradeId])
    {
        [self.bankTableView.mj_header endRefreshing];
        self.cardsArray =  result.body;//entity.cardList;
        NSDictionary *json = [_cardsArray yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
        // 判断是否绑定银行卡
        BOOL hasExpress = NO;
        for (KSCardItemEntity *item in self.cardsArray)
        {
            if (item.express)
            {
                hasExpress = YES;
                break;
            }
        }
        self.hasExpress = hasExpress;
        [self.bankTableView reloadData];
    }
    else if ([tradeId isEqualToString:KSyncBankCardTradeId])
    {
        [self hideProgressHUD];
        self.cardsArray =  result.body;
        NSDictionary *json = [_cardsArray yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
        // 判断是否绑定银行卡
        BOOL hasExpress = NO;
        for (KSCardItemEntity *item in self.cardsArray)
        {
            if (item.express)
            {
                hasExpress = YES;
                break;
            }
        }
        self.hasExpress = hasExpress;
        [self.bankTableView reloadData];
        
        @WeakObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.view makeToast:KSyncBankCardSuccessTitle duration:3.0 position:CSToastPositionCenter];
        });
    }
    else if ([tradeId isEqualToString:KUnbindBankAccountTradeId])
    {
        [self.bankTableView.mj_header endRefreshing];
        /**
         *  @author semny
         *
         *  替换分散的LGAlert使用的地方
         */
        NSString *title = @"解绑银行卡成功";
        NSString *message = nil;
        NSString *cancelTitle = nil;
        NSString *okTitle = @"确定";
        @WeakObj(self);
        [self showLGAlertTitle:title message:message cancelButtonTitle:cancelTitle okButtonTitle:okTitle cancelBlock:nil okBlock:^(id alert) {
            [weakself.userInfoBL doGetUserBankCards];
        }];
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    INFO(@"%@ %@",blEntity,result);
    
    NSString *tradeId = result.tradeId;
    if ([tradeId isEqualToString:KSyncBankCardTradeId])
    {
        [self hideProgressHUD];
    }
    else
    {
        [self.bankTableView.mj_header endRefreshing];
    }
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}

#pragma mark-跳转添加页面
-(void)toAddBankCards
{
    if (![USER_MGR.assets isOpenAccount])
    {
        [self turn2OpenAccountPage];
    }
    else
    {
        NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KBindBankCardsPage data:nil error:nil];
        KSBindBankCardVC *vc = [[KSBindBankCardVC alloc]initWithUrl:urlStr title:@"绑定银行卡" params:nil type:self.type runJS:YES ];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - cell上按钮点击的代理方法
- (void)toPlusBankCards
{
    [self toAddBankCards];

}

#pragma mark - 去开户
- (void)turn2OpenAccountPage
{
//    NSString *imeiStr = [USER_MGR getCurrentSessionId];
//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@&app=1", KOpenAccountPage, imeiStr];
//
//    
//    //开托管账户
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:self.type];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
    
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:self.type];
}

#pragma mark-解绑银行卡的代理
-(void)unbindBankCard:(KSCardItemEntity*)card
{
    if(!card || !card.account || card.account.length <= 0)
    {
        return;
    }
    /**
     *  @author semny
     *
     *  替换分散的LGAlert使用的地方
     */
    NSString *cardStr = card.account;
    NSString *first4Str = [cardStr substringToIndex:4];
    NSString *last4Str = [cardStr substringFromIndex:cardStr.length-4];
    NSString *title = [NSString stringWithFormat:@"您即将要解除银行卡号(%@ **** **** %@)的绑定",first4Str,last4Str];
    NSString *message = nil;
    NSString *cancelTitle = @"取消";
    NSString *okTitle = @"解绑";
    long long cardId = card.cardId;
    @WeakObj(self);
    [self showLGAlertTitle:title message:message cancelButtonTitle:cancelTitle okButtonTitle:okTitle cancelBlock:nil okBlock:^(id alert) {
        if (weakself.bankCardBL)
        {
            [weakself.bankCardBL doUnbindBankCard:cardId];
        }
    }];
}
@end
