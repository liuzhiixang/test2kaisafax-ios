//
//  KSOpenAccountResultVC.m
//  sxfax
//
//  Created by philipyu on 16/4/23.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSOpenAccountResultVC.h"
#import "KSOpenAccountVC.h"
#import "KSInvestVC.h"
#import "KSLoginVC.h"
#import "KSRegisterSuccessVC.h"
#import "KSRechargeVC.h"
#import "KSHomeVC.h"
#import "KSDepositVC.h"
#import "KSConst.h"
#import "KSUserMgr.h"
//#import "KSMainVC.h"
#import "AppDelegate.h"
#import "KSYYLabel.h"
#import "KSJXCustomerServiceMgr.h"
#import "JXMCSUserManager.h"
#import "KSAutoLoanVC.h"
#import "KSAutoLoanSettingVC.h"
#import "KSOpenAccountBL.h"

//typedef NS_ENUM(NSUInteger,KSWebSourceType)
//{
//    KSWebSourceTypeRegister=0,     //从注册入口来的
//    KSWebSourceTypeOther=1,      //从账户中心来的
//};

#define kisOpenFail  ([self.name isEqualToString:KOpenAccountFailTitle])

@interface KSOpenAccountResultVC ()
- (IBAction)soonInvestClick:(UIButton *)sender;
- (IBAction)soonAddCashClick:(UIButton *)sender;
//开户成功或者失败的图标
@property (weak, nonatomic) IBOutlet UIImageView *successFailImage;
//开户的圆圈
@property (weak, nonatomic) IBOutlet UIImageView *openAccountRound;
//连接开户与注册的view
@property (weak, nonatomic) IBOutlet UIView *connView;
//投资或者确定按钮
@property (weak, nonatomic) IBOutlet UIButton *investOrConfirmBtn;
//重新开户或者立即充值
@property (weak, nonatomic) IBOutlet UIButton *reopenOrRechargeBtn;
@property (weak, nonatomic) IBOutlet KSYYLabel *custoerLabel;

@property (weak, nonatomic) IBOutlet KSYYLabel *investLabel;
- (IBAction)contactCusSerAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cusBtn;
@property (weak, nonatomic) IBOutlet UILabel *openAccountLabel;
@end

@implementation KSOpenAccountResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.title = kisOpenFail?KOpenAccountFailTitle: KOpenAccountSuccessTitle;
    
    INFO(@"after----------------------");
    INFO(@"childrens %@",self.navigationController.childViewControllers);
    INFO(@"topview %@",self.navigationController.topViewController);
    // 发通知去更新账户中心
//    [NOTIFY_CENTER postNotificationName:KAssetUpdateNotification object:nil userInfo:@{@"frompage":@"KSOpenAccountResultVC"}];
    [USER_MGR updateUserAssets];
    self.cusBtn.hidden = YES;
    
    [self updateUI];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    禁用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    禁用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)updateUI
{
    
    self.reopenOrRechargeBtn.layer.borderWidth = 0.5;
    self.reopenOrRechargeBtn.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;
    
    if (kisOpenFail)
    {
        self.successFailImage.image = [UIImage imageNamed:@"error_circle"];
        self.openAccountLabel.text = [NSString stringWithFormat:@"很遗憾，开户失败"];
        //        KSYYLabel *investLabel = [[KSYYLabel alloc]init];
        NSString *custText = [NSString stringWithFormat:@"请重新开户或者联系客服%@",KCustomerServicePhone];
        [self.custoerLabel customerServiceRichText:custText];
        
        self.investLabel.hidden = YES;
        //        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:self.investLabel.text];
        //        [attributeStr addAttribute:NSFontAttributeName
        //                             value:[UIFont systemFontOfSize:14.0]
        //                             range:NSMakeRange(4, 4)];
        //        [attributeStr addAttribute:NSForegroundColorAttributeName value:NUI_HELPER.appOrangeColor range:NSMakeRange(4, 4)];
        //        self.custoerLabel.text = investLabel.text;
        
        self.cusBtn.hidden = NO;

        self.cusBtn.layer.borderWidth = 0.5;
        self.cusBtn.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;

        
        [self.investOrConfirmBtn setTitle:KConfirmTitle forState:(UIControlStateNormal)];
        
        [self.reopenOrRechargeBtn setTitle:KReopenAccountTitle forState:(UIControlStateNormal)];
        
        self.connView.backgroundColor = UIColorFromHexA(0xc1c1c1, 0.5);
        
        self.openAccountRound.image = [UIImage imageNamed:@"gray_circle"];
        
        
        
    }
    else
    {
        self.successFailImage.image = [UIImage imageNamed:@"right_circle"];
        
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:self.investLabel.text];
        [attributeStr addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:14.0]
                             range:NSMakeRange(4, 4)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:NUI_HELPER.appOrangeColor range:NSMakeRange(4, 4)];
        self.investLabel.attributedText = attributeStr;
        
        self.custoerLabel.hidden = YES;
        self.openAccountLabel.text = [NSString stringWithFormat:@"%@,恭喜您开户成功！",self.name];
        
        [self.investOrConfirmBtn setTitle:KImmediateInvestmentTitle forState:(UIControlStateNormal)];
        
        [self.reopenOrRechargeBtn setTitle:KImmediateRechargeTitle forState:(UIControlStateNormal)];
        

        self.connView.backgroundColor = NUI_HELPER.appOrangeColor;
        
        self.openAccountRound.image = [UIImage imageNamed:@"orange_circle"];
        
        //更新用户资料
        [USER_MGR updateUserAssets];
        //判断是否为自动投标流程
        
    }
}

#pragma mark -------内部方法-----------
//立即去投资／确定按钮操
- (IBAction)soonInvestClick:(UIButton *)sender
{
    if (kisOpenFail)
    {
        //失败页面
        DEBUGG(@"failed %s", __FUNCTION__);
    }
    else
    {
        //成功
//        NSArray *children = self.navigationController.childViewControllers;
//        INFO(@"childrens  %@",children);
        //切换到投资理财列表
        UITabBarController *tabbarVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarVC;
        if (tabbarVC.selectedIndex!=1)
        {
            [tabbarVC setSelectedIndex:1];
        }
    }
    
    if (self.type == KSWebSourceTypeRegister)
    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //关闭登录注册流程
        [USER_MGR dismissLoginProgressFor:self.navigationController completion:nil];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

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

#pragma mark - 立即去充值
- (IBAction)soonAddCashClick:(UIButton *)sender
{
    if (kisOpenFail)
    {
        [self turn2OpenAccountPage];
    }
    else
    {
        KSRechargeVC *addVc = [[KSRechargeVC alloc]init];
        //addVc.type = KSWebSourceTypeRegister;
        addVc.type = self.type;
        [self.navigationController pushViewController:addVc animated:YES];
    }
}

#pragma mark - 返回
-(void)leftButtonAction:(id)sender
{
    [self homeBtnClick];

}

- (void)homeBtnClick
{
//    NSArray *children = self.navigationController.childViewControllers;
//    INFO(@"childrens  %@",children);
    if (self.type == KSWebSourceTypeRegister)
    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [USER_MGR dismissLoginProgressFor:self.navigationController completion:nil];
    }
    else if(self.type == KSWebSourceTypeAutoLoan)
    {
        //自动投标进入的
        NSArray *vcArray = self.navigationController.viewControllers;
        for (UIViewController *vc in vcArray)
        {
            if ([vc isKindOfClass:KSAutoLoanVC.class])
            {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if(self.type == KSWebSourceTypeAutoLoanSetting)
    {
        //自动投标进入的
        NSArray *vcArray = self.navigationController.viewControllers;
        for (UIViewController *vc in vcArray)
        {
            if ([vc isKindOfClass:KSAutoLoanSettingVC.class])
            {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
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
