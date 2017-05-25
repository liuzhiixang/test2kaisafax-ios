//
//  KSAccountInvestVC.m
//  kaisafax
//
//  Created by BeiYu on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInvestVC.h"
#import "WMPageController.h"
#import "KSAccountInvestCell.h"
#import "KSUIItemEntity.h"
#import "KSLoanItemEntity.h"
#import "KSUserInvestsEntity.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MJRefresh.h"
#import "KSInvestReceivedPayVC.h"
#import "KSBUserInvestListEntity.h"
#import "KSAccountInvestClearCell.h"
#import "KSContractBL.h"
#import "KSWebVC.h"
#import "KSPDFViewVC.h"

//typedef NS_ENUM(NSInteger,KSAccountInvest)
//{
//    KSAccountInvestFrozen = 0,        //投标中
//    KSAccountInvestLoaned,            //还款中
//    KSAccountInvestCleared,           //已还清
//    KSAccountInvestMax,               //最大枚举值;
//};
@interface KSAccountInvestVC ()<KSBLDelegate,KSAccountInvestCellDelegate, KSAccountInvestClearCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *investTableView;
@property (strong, nonatomic) KSInvestListBL *investListBL;
@property (weak, nonatomic) NSMutableArray *investArray;
@property (nonatomic,strong) KSBUserInvestListEntity *investlistData;
@property (strong, nonatomic) KSContractBL *contractBL;
//没有红包信息的提示
@property (weak, nonatomic) IBOutlet UILabel *noRecordLabel;



@end

@implementation KSAccountInvestVC


-(NSMutableArray*)investArray
{
    _investArray = self.investlistData.dataList;
    return _investArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _investArray = [NSMutableArray array];
    [self.investTableView setSeparatorColor:[UIColor clearColor]];

    //注册cell
    kRegisterCellNib(self.investTableView,kSAccountInvestCell);
    kRegisterCellNib(self.investTableView, kSAccountInvestClearCell);
    
    //添加刷新控件
    [self tableRefreshGif];
    
    
    // 请求用户投资列表
    [self.investTableView.mj_header beginRefreshing];
    
}

#pragma mark - 内部方法
/**
 *  设置列表加载刷新数据的图片
 */
- (void)tableRefreshGif
{
    // 添加动画图片的下拉刷新
    [self scrollView:_investTableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
}

/**
 *  @author semny
 *
 *  刷新当前页面数据
 */
- (void)refreshing
{

    if (!_investListBL)
    {
        _investListBL = [[KSInvestListBL alloc]init];
        
        _investListBL.delegate = self;
    }
    
    _investListBL.status = self.status;
    // 请求用户投资列表
    [_investListBL refreshUserInvestList];
}

- (void)loadingMore
{
    //加载更多
    // 请求用户投资列表
    [_investListBL requestNextPageUserInvestList];
}

-(void)endRefreshing
{
    [self.investTableView.mj_header endRefreshing];
    [self.investTableView.mj_footer endRefreshing];
}



#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.investArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    //1.创建cell
    NSInteger sec = indexPath.section;
    
    if (self.status == KSDoInvestStatusCleared /*[self.status isEqualToString:@"CLEARED"]*/)
    {
        KSAccountInvestClearCell *cell = [tableView dequeueReusableCellWithIdentifier:kSAccountInvestClearCell];
        if ( sec>=0 && sec < _investArray.count)
        {
            //2.给cell赋值
            [cell updateItem:_investArray[sec]];
            cell.delegate = self;
        }
        return cell;

    }
    else
    {
        KSAccountInvestCell *cell = [tableView dequeueReusableCellWithIdentifier:kSAccountInvestCell];
        if ( sec>=0 && sec < _investArray.count)
        {
            //2.给cell赋值
            [cell updateItem:_investArray[sec]];
        }
        if (self.status == KSDoInvestStatusLoaned /*[self.status isEqualToString:@"LOANED"]*/)
        {
            cell.delegate = self;
            
        }
        return cell;
    }
    
    
    return nil;
 
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec = indexPath.section;
    if (self.status == KSDoInvestStatusCleared /*[self.status isEqualToString:@"CLEARED"]*/) {
        return [tableView fd_heightForCellWithIdentifier:kSAccountInvestClearCell cacheByIndexPath:indexPath configuration:^(KSAccountInvestCell *cell) {
            if ( sec>=0 && sec < _investArray.count)
                [cell updateItem:_investArray[sec]];
            
        }];
    }
    else
    {
        return [tableView fd_heightForCellWithIdentifier:kSAccountInvestCell cacheByIndexPath:indexPath configuration:^(KSAccountInvestCell *cell) {
            if ( sec>=0 && sec < _investArray.count)
        [cell updateItem:_investArray[sec]];
        
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 10.0;
    }
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}


#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self endRefreshing];
    [self hideProgressHUD];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        //        [weakself hideProgressHUD];
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
    });
    INFO(@"%@ %@",blEntity,result);
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
//    INFO(@"%@ %@",blEntity,result.body);
    
    [self endRefreshing];
    [self hideProgressHUD];
    
//    if (!result.body) return;
    
    if ([result.tradeId isEqualToString:KGetInvestContractTradeId]) {
        //投资合同
        NSDictionary *jsonData = result.body;
        NSString *title = jsonData[@"title"];
        NSString *url = jsonData[@"url"];
        [self showContract:title url:url];
        
    }else{
        _investlistData = (KSBUserInvestListEntity *)result.body;
        
        [self.investTableView reloadData];
        
        if(self.investArray.count == 0)
        {
            self.noRecordLabel.text = KNoInvestTargetTitle;
            self.noRecordLabel.hidden = NO;
        }
        else
        {
            self.noRecordLabel.hidden = YES;
        }
    }

}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self endRefreshing];
    [self hideProgressHUD];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        //        [weakself hideProgressHUD];
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
    INFO(@"%@ %@",blEntity,result);
}

#pragma mark --cell的代理
-(void)accountInvestCellWithLoanID:(KSUIItemEntity*)entity
{
   // 跳转至回款计划
    KSInvestReceivedPayVC *vc = [[KSInvestReceivedPayVC alloc]init];
    vc.loanTitle = entity.loan.title;
    vc.loanID = entity.invest.iiId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showContractFromEntity:(KSUIItemEntity *)entity
{
//    if (!_contractBL) {
//        _contractBL = [[KSContractBL alloc]init];
//        _contractBL.delegate = self;
//    }
//    [self showProgressHUD];
    
#warning get contract
//    [_contractBL doGetContractWithInvestId:entity.invest.iiId];
    
    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KGetInvestContractTradeId data:@{@"investId":@(entity.invest.iiId)} error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"投资合同" params:nil type:KSWebSourceTypeInvestDetail  runJS:NO];

}

- (void)showContract:(NSString *)title url:(NSString *)url
{
    if (title.length > 0 && url.length > 0) {
//        [KSWebVC pushInController:self.navigationController urlString:url title:title params:nil type:KSWebSourceTypeInvestDetail  runJS:NO];
        KSPDFViewVC *vc = [[KSPDFViewVC alloc]init];
        vc.title = title;
        vc.filePath = url;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
