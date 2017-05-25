//
//  KSDepositResultVC.m
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSDepositResultVC.h"
#import "UIViewController+BackButtonHandler.h"
#import "KSUserMgr.h"
#import "KSYYLabel.h"
#import "KSJXCustomerServiceMgr.h"
#import "JXMCSUserManager.h"
// 汇付普通提现
#define TYPE_HF_GENERAL @"GENERAL"
// 汇付加急提现
#define TYPE_HF_IMMEDIATE @"IMMEDIATE"

#define kProcessingStr    @"请求正在处理中"


@interface KSDepositResultVC ()
//
@property (weak, nonatomic) IBOutlet UIView *progressView;
//
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
//
- (IBAction)progressFinishClick:(UIButton *)sender;

//失败的view
@property (weak, nonatomic) IBOutlet UIView *failView;
//失败原因
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
//提示联系客服
@property (weak, nonatomic) IBOutlet KSYYLabel *failCustomerServiceLabel;


//
- (IBAction)failFinishClick:(UIButton *)sender;
//
@property (weak, nonatomic) IBOutlet UIView *sucView;
//
@property (weak, nonatomic) IBOutlet UILabel *sucAmountLabel;
//
- (IBAction)knowBtnClick:(UIButton *)sender;
//成功之后的提示文案，加急和普通不一样
@property (weak, nonatomic) IBOutlet UIButton *cusBtn;
@property (weak, nonatomic) IBOutlet UILabel *sucBankTips;
- (IBAction)contactCusSerAction:(UIButton *)sender;
@end

@implementation KSDepositResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"提现结果";
    
    
    
    if ([self.result isEqualToString:@"true"])
    {

        self.sucAmountLabel.text = [NSString stringWithFormat:@"金额为%.2f元",[self.amount doubleValue]];
        self.sucView.hidden = NO;
        NSString *firstStr = [self.cashChl isEqualToString:TYPE_HF_GENERAL]?@"T+1个工作日到账":@"2小时内到账";
        NSString *finalStr = [NSString stringWithFormat:@"%@,具体以银行短信为准",firstStr];
        
        self.sucBankTips.text = finalStr;
        
        // 发通知去更新账户中心
//        [NOTIFY_CENTER postNotificationName:KAssetUpdateNotification object:nil userInfo:@{@"frompage":@"KSRechargeResultVC"}];
        [USER_MGR updateUserAssets];
    }
    else
    {
        if([self.amount containsString:kProcessingStr])
        {
            self.progressView.hidden = NO;
        }
        else
        {
            self.failLabel.text = [NSString stringWithFormat:@"失败原因:%@",self.amount];
            [self.failCustomerServiceLabel customerServiceRichText:KCallCustomerService1];
            self.cusBtn.layer.borderWidth = 0.5;
            self.cusBtn.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;

            self.failView.hidden = NO;
        }
    }
//    self.cashGetLabel.text = [NSString stringWithFormat:@"您已成功提现：%.2f元",[self.amount doubleValue]];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //    禁用侧滑手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//}
-(void)leftButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)progressFinishClick:(UIButton *)sender
{
     [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)failFinishClick:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)knowBtnClick:(UIButton *)sender
{
     [self.navigationController popToRootViewControllerAnimated:YES];
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
