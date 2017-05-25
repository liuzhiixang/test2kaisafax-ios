//
//  KSRechargeResultVC.m
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSRechargeResultVC.h"
#import "KSInvestDetailVC.h"
#import "KSInvestVC.h"
#import "KSLoginVC.h"
#import "KSHomeVC.h"
//#import "KSMainVC.h"
#import "KSConst.h"
#import "AppDelegate.h"
#import "KSUserMgr.h"
#import "UIViewController+BackButtonHandler.h"
#import "YYText.h"
#import "KSYYLabel.h"
#import "KSJXCustomerServiceMgr.h"
#import "JXMCSUserManager.h"

@interface KSRechargeResultVC()
/**
 失败相关的控件
 */
//失败的view
@property (weak, nonatomic) IBOutlet UIView *failView;
//失败的原因
@property (weak, nonatomic) IBOutlet UILabel *failReasonLabel;
//失败的客服提示
@property (weak, nonatomic) IBOutlet KSYYLabel *failCustomerServLabel;

//失败的日期
@property (weak, nonatomic) IBOutlet UILabel *failTimeLabel;

//失败的确认按钮点击事件
//- (IBAction)failedConfirmBtnClick:(UIButton *)sender;
/**
 成功相关的控件
 */
//成功的差额充值和普通充值
@property (weak, nonatomic) IBOutlet UILabel *sucLabel;
//成功的view
@property (weak, nonatomic) IBOutlet UIView *sucView;
//充值金额
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

//- (IBAction)sucConfirmBtnClick:(UIButton *)sender;
//
//
//- (IBAction)toInvestBtnClick:(UIButton *)sender;
- (IBAction)contactCusSerAction:(UIButton *)sender;

//单一确定按钮
@property (weak, nonatomic) IBOutlet UIButton *sucOKBtn;
//确定和去投资按钮同时存在的情况
@property (weak, nonatomic) IBOutlet UIButton *sucOKBtn2;
@property (weak, nonatomic) IBOutlet UIButton *sucInvestBtn;
@property (weak, nonatomic) IBOutlet UIButton *cusBtn;

@end

@implementation KSRechargeResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = KRechargeResultTitle;
    
    if ([self.result isEqualToString:@"true"])
    {
        self.amountLabel.text = [NSString stringWithFormat:@"充值金额：%.2f元",[self.amount doubleValue]];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        format.dateFormat = @"yyyy-MM-dd HH:mm";
        
        self.dateLabel.text =[format stringFromDate:[NSDate date]];
        self.dateLabel.text = [NSString stringWithFormat:@"时间: %@",self.dateLabel.text];
        self.sucView.hidden = NO;
        
        //判断充值类型
        if(self.actionFlag == KSRechargeTypeBalance)
        {
            //差额充值
            self.sucOKBtn.hidden = NO;
            self.sucOKBtn2.hidden = YES;
            self.sucInvestBtn.hidden = YES;
            self.sucLabel.text = KChaRechargeResultTitle;
        }
        else if(self.actionFlag == KSRechargeTypeBalance)
        {
            //普通充值
            self.sucOKBtn.hidden = YES;
            self.sucOKBtn2.hidden = NO;
            self.sucInvestBtn.hidden = NO;
            self.sucLabel.text = @"充值成功";
        }
        else
        {
            //其他
            self.sucOKBtn.hidden = YES;
            self.sucOKBtn2.hidden = NO;
            self.sucInvestBtn.hidden = NO;
        }
        
        // 发通知去更新账户中心
//        [NOTIFY_CENTER postNotificationName:KAssetUpdateNotification object:nil userInfo:@{@"frompage":@"KSRechargeResultVC"}];
        [USER_MGR updateUserAssets];
        [NOTIFY_CENTER postNotificationName:KRechargeNotification object:nil];
    }
    else
    {

        if ([self.code isEqualToString:@""] ||
            [self.amount isEqualToString:@""]) {
            self.failReasonLabel.text = @"";
        }
        else
        {
            self.failReasonLabel.text = [NSString stringWithFormat:@"%@(错误码 %@)",self.amount,self.code];
//            self.failCustomerLabel.text = KCallCustomerService2;

            [self.failCustomerServLabel customerServiceRichText:KCallCustomerService2];

            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            format.dateFormat = @"yyyy-MM-dd HH:mm";
            self.failTimeLabel.text =[format stringFromDate:[NSDate date]];
            self.failTimeLabel.text = [NSString stringWithFormat:@"时间: %@",self.failTimeLabel.text];
        }
        self.cusBtn.layer.borderWidth = 0.5;
        self.cusBtn.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;

        self.failView.hidden = NO;
        
    }
}




#pragma mark - 重写backbar

- (IBAction)failedConfirmBtnClick:(UIButton *)sender
{
    [self confirmToRelativePage];
}

- (IBAction)sucConfirmBtnClick:(UIButton *)sender
{
    [self confirmToRelativePage];
}

- (IBAction)toInvestBtnClick:(UIButton *)sender
{
    NSArray *vcsArray = [self.navigationController viewControllers];
    INFO(@"%@",vcsArray);
    
    //0.从注册页来 1:从账户中心来 2:从投资页面来 3.从首页来
    KSWebSourceType type = (KSWebSourceType)self.type;
    if (type == KSWebSourceTypeRegister)
    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [USER_MGR dismissLoginProgressFor:self.navigationController completion:nil];
        
        UITabBarController *tabbarVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarVC;
        if (tabbarVC.selectedIndex!=1)
        {
            [tabbarVC setSelectedIndex:1];
        }
    }
    else if(type == KSWebSourceTypeAccount || type == KSWebSourceTypeHome)
    {
        [self turn2InvestListPage];
    }
    else if(type == KSWebSourceTypeInvestDetail)
    {
        [self.navigationController popToViewController:vcsArray[1] animated:YES];
    }
    else
    {
        //默认跳转投资列表
        [self turn2InvestListPage];
    }
}

- (void)turn2InvestListPage
{
    UITabBarController *tabbarVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarVC;
    if (tabbarVC.selectedIndex!=1)
    {
        [tabbarVC setSelectedIndex:1];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)leftButtonAction:(id)sender
{
//    [super leftButtonAction:sender];
    [self confirmToRelativePage];
}

- (void)confirmToRelativePage
{
    //在注册充值和账户中心跳转的充值返回账户中心

    NSArray *vcsArray = [self.navigationController viewControllers];
    INFO(@"%@",vcsArray);

    //0.从注册页来 1:从账户中心来 2:从投资页面来 3.从首页来
    KSWebSourceType type = (KSWebSourceType)self.type;
    if (type == KSWebSourceTypeRegister)
    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [USER_MGR dismissLoginProgressFor:self.navigationController completion:nil];
    }
    else if(type == KSWebSourceTypeAccount || type == KSWebSourceTypeHome)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if(type == KSWebSourceTypeInvestDetail)
    {
         [self.navigationController popToViewController:vcsArray[1] animated:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)contactCusSerAction:(UIButton *)sender {
    KSJXCustomerServiceMgr *cusMgr = [KSJXCustomerServiceMgr sharedInstance];
    
    JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
    
    if ([mgr isLogin])
    {
        [cusMgr jumpToCustomerCenter:self.navigationController];
    }
    else
    {
        [cusMgr loginJXCustomer:self.navigationController];
    }
}
@end
