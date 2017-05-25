//
//  KSJingDongCardVC.m
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardVC.h"


#import "UITableView+FDTemplateLayoutCell.h"
#import "KSInvestBL.h"
#import "KSStatusView.h"
#import "KSNewbeeEntity.h"
#import "JSONKit.h"
#import "KSUserMgr.h"
#import "NSDate+Utilities.h"
#import "KSFileUtil.h"
#import "KSBLoanListEntity.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>



#define kCellMargin 0
#define kRadius 5
#define HEIGHT_ZERO 0.01



@interface KSJDCardVC ()<UITableViewDelegate,UITableViewDataSource,KSBLDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>



@property (strong, nonatomic) KSJDExtractListBL *extractListBL;
@property (strong, nonatomic) KSBJDExtractListEntity *listEntity;



@end

@implementation KSJDCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置navigationbar显示
    self.title = KJingDongCardTitle;
    [self setNavRightButtonByText:KJingDongCardRecord titleColor:UIColor.whiteColor imageName:nil selectedImageName:nil navBtnAction:@selector(goCardRecord)];
    
    [self initTakeActionBtn];
    
    self.tableView.estimatedRowHeight = 109;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
  
    [_tableView registerNib:[UINib nibWithNibName:kJDCardListCell bundle:nil] forCellReuseIdentifier:kJDCardListCell];
    
    _extractLab.text =[NSString stringWithFormat:@"%@元", [KSBaseEntity formatAmountNotFloat:0]];
    
    
    NSMutableAttributedString * noteStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@元",@"0"]];
    NSRange redRangeTwo = NSMakeRange([[noteStr string] rangeOfString:@"元"].location, [[noteStr string] rangeOfString:@"元"].length);
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:redRangeTwo];
    [_extractLab setAttributedText:noteStr];
    
    
    
    
    // 添加动画图片的下拉刷新
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
    
    _extractListBL = [[KSJDExtractListBL alloc]init];
    _extractListBL.delegate = self;
    
    
    [_tableView.mj_header beginRefreshing];
    
    @WeakObj(self);
    [[NOTIFY_CENTER rac_addObserverForName:KAccountJDCardChangeNotificationKey object:nil] subscribeNext:^(id x) {
        [weakself refreshing];
    }];
}
//提取按钮
- (void)initTakeActionBtn
{
    //提取按钮样式
    [self.takeActionBtn setTitle:@"立即领取" forState:UIControlStateNormal];
    [self.takeActionBtn setTitle:@"立即领取" forState:UIControlStateSelected];
    self.takeActionBtn.enabled = NO;
    
}
- (void)updateBottomInfo:(KSBJDExtractListEntity *)extractListEntity
{
    CGFloat value =  extractListEntity.jdAccount.floatValue;
    
    BOOL canTake = value > 0;
    //操作按钮
    self.takeActionBtn.enabled = canTake;
    

}

#pragma mark - TableView Delegate & DataSource

// 查看发放记录
-(void)goCardRecord
{
 
    KSJDCardPayrollRecordVC *jdRecordVC = [[KSJDCardPayrollRecordVC alloc]init];
    jdRecordVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:jdRecordVC animated:YES];
}
//去领取京东卡界面
- (IBAction)goCardReceive:(id)sender {
    
    KSJDCardReceiveVC *VC = [[KSJDCardReceiveVC alloc]init];
    VC.jdAmount = _listEntity.jdAccount.integerValue;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kCellMargin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int sectionHeight = 0;
    
    if (section==0) {
        sectionHeight = 3;
    } else {
        sectionHeight = kCellMargin;
    }
    return sectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 96;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return _listEntity.dataList.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    KSJDExtractItemEntity  *entity =[KSJDExtractItemEntity yy_modelWithJSON:_listEntity.dataList[indexPath.section]];
    KSJDCardCell *cell = [tableView dequeueReusableCellWithIdentifier:kJDCardListCell forIndexPath:indexPath];
    [cell updateItem:entity];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KSJDCardDetailVC *vc = [[KSJDCardDetailVC alloc]init];
   // vc.Section = (int)indexPath.section;
    vc.entity =[KSJDExtractItemEntity yy_modelWithJSON:_listEntity.dataList[indexPath.section]];
    vc.Section = (int)indexPath.section;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}


- (void)refreshing
{
    //请求首页信息
   [_extractListBL refreshJDExtractList];
}

- (void)loadingMore
{
    //请求首页信息
     [_extractListBL requestNextPageJDExtractList];
}

#pragma mark -  DZNEmptyDataSet
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;
{
    return YES;
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"您还未领取过京东卡哦~";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:NUI_HELPER.appNormalFontSize],
                                 NSForegroundColorAttributeName: NUI_HELPER.appLightGrayColor};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"account_jd_no_card"];
}


#pragma mark - KSBLDelegate


- (void)didEndLoading
{
    [self hideProgressHUD];
    
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    [_tableView reloadData];
}

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    if ([result.body isKindOfClass:[KSBJDExtractListEntity class]]) {
        KSBJDExtractListEntity *entity = (KSBJDExtractListEntity *)result.body;
        self.listEntity = entity;
        DEBUGG(@"entity count:%ld", entity.dataList.count);
        
        //更新当前数据
        [self updateBottomInfo:entity];
        
        NSInteger amount = entity.jdAccount.integerValue;
        _extractLab.text =[NSString stringWithFormat:@"%@元", [KSBaseEntity formatAmountNotFloat:amount]];
        
        NSMutableAttributedString * noteStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld元",(long)amount]];
        NSRange redRangeTwo = NSMakeRange([[noteStr string] rangeOfString:@"元"].location, [[noteStr string] rangeOfString:@"元"].length);
        [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:redRangeTwo];
        [_extractLab setAttributedText:noteStr];
        
        
    }
    
    [self didEndLoading];
}

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self didEndLoading];
    
    self.takeActionBtn.enabled = NO;
    
    if (result.errorDescription) {
        [self showSimpleAlert:result.errorDescription];
    }
}

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self didEndLoading];
}

- (void)sysErrorBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result
{
    //防止同一时间多次弹出
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayToastNetworkError) object:nil];
    [self performSelector:@selector(delayToastNetworkError) withObject:nil afterDelay:2];
}
- (void)delayToastNetworkError
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
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

@end
