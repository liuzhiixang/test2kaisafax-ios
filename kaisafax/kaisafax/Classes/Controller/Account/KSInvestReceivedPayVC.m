//
//  KSInvestReceivedPayVC.m
//  KSfax
//
//  Created by philipyu on 16/3/10.
//  Copyright © 2016年 com.KSfax. All rights reserved.
//

#import "KSInvestReceivedPayVC.h"
#import "KSInvestPlanCell.h"
#import "KSInvestAboutBL.h"
#import "KSInvestRepayEntity.h"
#import "KSIRItemEntity.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSContractBL.h"
#import "KSWebVC.h"
#import "KSPDFViewVC.h"

#define kInvestHeight   40
@interface KSInvestReceivedPayVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UITableView *repayTableview;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (strong, nonatomic) KSContractBL *contractBL;
@property (strong, nonatomic) KSInvestAboutBL *investBL;
@property (nonatomic,strong) NSMutableArray *receivedRepays;

@property (nonatomic,copy) NSString *loanProduct;
@end

@implementation KSInvestReceivedPayVC



//懒加载
-(NSMutableArray*)receivedRepays
{
    if (_receivedRepays == nil)
    {
        self.receivedRepays = [NSMutableArray array];
    }
    return _receivedRepays;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = KPaymentPlanTitle;
    self.headLabel.text = self.loanTitle;
    self.repayTableview.separatorColor = ClearColor;
    
    kRegisterCellNib(self.repayTableview,kSInvestPlanCell);

    
    if (!_investBL) {
        _investBL = [[KSInvestAboutBL alloc]init];
        _investBL.delegate = self;
    }
    
    //转菊花
    [self showProgressHUD];

    [_investBL doGetInvestRepaysByInvestId:self.loanID];
}

-(void)updateUI
{
    [self.repayTableview reloadData];
}

- (IBAction)showContract:(id)sender
{
//    if (!_contractBL) {
//        _contractBL = [[KSContractBL alloc]init];
//        _contractBL.delegate = self;
//    }
//    [self showProgressHUD];
#warning get contract
//    [_contractBL doGetContractWithInvestId:_loanID];
    
    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KGetInvestContractTradeId data:@{@"investId":@(self.loanID)} error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"投资合同" params:nil type:KSWebSourceTypeInvestDetail  runJS:NO];
}

#pragma mark - tableview datasource and delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count =self.receivedRepays.count;
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSInvestPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:kSInvestPlanCell];
    
    KSIRItemEntity *entity = nil;
    NSInteger index = 0;
    if ((index=indexPath.section) < self.receivedRepays.count)
    {
        entity = self.receivedRepays[index];
    }
    [cell updateItem:entity];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 10.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [tableView fd_heightForCellWithIdentifier:kSInvestPlanCell cacheByIndexPath:indexPath configuration:^(id cell) {
//         [cell updateItem:self.receivedRepays[indexPath.section]];
//    }];
    return 150.0;
}



#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self hideProgressHUD];
    INFO(@"%@ %@",blEntity,result);
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@" finishedHandle %@",result);
    [self hideProgressHUD];
    if (result == nil) return;
    
    if ([result.tradeId isEqualToString:KReceivedRepaysTradeId]) {
        KSInvestRepayEntity *entity = result.body;
        [self.receivedRepays addObjectsFromArray:entity.repayList];
        self.loanProduct = entity.loanProduct;
        [self updateUI];
    }
    
    if ([result.tradeId isEqualToString:KGetInvestContractTradeId]) {
        //投资合同
        NSDictionary *jsonData = result.body;
        NSString *title = jsonData[@"title"];
        NSString *url = jsonData[@"url"];
        [self showContract:title url:url];
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
            [self hideProgressHUD];

    INFO(@"%@ %@",blEntity,result);
}

- (void)showContract:(NSString *)title url:(NSString *)url
{
    if (title.length > 0 && url.length > 0) {
        //[KSWebVC pushInController:self.navigationController urlString:url title:title params:nil type:KSWebSourceTypeInvestDetail  runJS:NO];
        KSPDFViewVC *vc = [[KSPDFViewVC alloc]init];
        vc.title = title?:@"投资合同";
        vc.filePath = url;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


@end
