//
//  KSBidResultVC.m
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSBidResultVC.h"
#import "KSWholeInvestVC.h"
#import "UIViewController+BackButtonHandler.h"
#import "KSConst.h"
#import "KSUserMgr.h"
#import "AppDelegate.h"
#import "KSJXCustomerServiceMgr.h"
#import "JXMCSUserManager.h"

@interface KSBidResultVC ()
@property (weak, nonatomic) IBOutlet UIButton *failBtn;

@property (weak, nonatomic) IBOutlet UIView *failView;
- (IBAction)failBtnClick:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIButton *sucBtn;

@property (weak, nonatomic) IBOutlet UIView *sucView;
@property (weak, nonatomic) IBOutlet UILabel *sucLabel;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
- (IBAction)sucBtnClick:(UIButton *)sender;

- (IBAction)investBtnClick:(UIButton *)sender;
- (IBAction)contactCusSerAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cusBtn;

@end

@implementation KSBidResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"投标结果";
    [USER_MGR performSelector:@selector(updateUserAssets) withObject:nil afterDelay:1.5f];

    //投资成功
    if ([self.result isEqualToString:@"true"])
    {
        self.sucBtn.layer.borderColor = UIColorFromHex(0x4c4c4e).CGColor;
        self.sucBtn.layer.borderWidth = 1.0;
        self.sucLabel.text = [NSString stringWithFormat:@"金额 %.2f元",[self.amount doubleValue]];
        self.sucView.hidden = NO;
        
        // 发通知去更新账户中心
//        [NOTIFY_CENTER postNotificationName:KAssetUpdateNotification object:nil userInfo:@{@"frompage":@"KSBidResultVC"}];
    }
    else
    {
        self.failBtn.layer.borderColor = UIColorFromHex(0x4c4c4e).CGColor;
        self.failBtn.layer.borderWidth = 0.5;
        self.cusBtn.layer.borderWidth = 0.5;
        self.cusBtn.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;
        if(!self.respCode || !self.respDesc)
            self.failLabel.text = @"";
        else
            self.failLabel.text = [NSString stringWithFormat:@"失败原因:(code:%@)%@",self.respCode,self.respDesc];
        self.failView.hidden = NO;
    }
    

}


-(void)leftButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    //    禁用侧滑手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//}
//
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //    启用侧滑手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//}


//- (IBAction)back:(UIButton *)sender
//{
//    NSArray *vcsArray = [self.navigationController viewControllers];
//    
//    //   跳转到账户页面
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    if(!([vcsArray[0] isKindOfClass:[SXRecommendController class]] &&
//         [vcsArray[1] isKindOfClass:[SXWuYeBaoVController class]]))
//    {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            AppDelegate *myDelegate = (AppDelegate *)kAppdelegate;
//            UITabBar *tabbar = myDelegate.tabVc.view.subviews[1];
//            SXTabBar *sxTabbar = tabbar.subviews[1];
//            SXTabBarButton *tabBarButton = sxTabbar.subviews[2];
//            [sxTabbar buttonClick:tabBarButton];
//        });
//    }
//   
//}

//- (IBAction)finishBtnClick:(UIButton *)sender
//{
//    NSArray *vcsArray = [self.navigationController viewControllers];
//
////   跳转到账户页面
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    if(!([vcsArray[0] isKindOfClass:[SXRecommendController class]] &&
//       [vcsArray[1] isKindOfClass:[SXWuYeBaoVController class]]))
//    {
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            AppDelegate *myDelegate = (AppDelegate *)kAppdelegate;
//            UITabBar *tabbar = myDelegate.tabVc.view.subviews[1];
//            SXTabBar *sxTabbar = tabbar.subviews[1];
//            SXTabBarButton *tabBarButton = sxTabbar.subviews[2];
//            [sxTabbar buttonClick:tabBarButton];
//        });
//    }
//
//
//}

- (IBAction)failBtnClick:(UIButton *)sender
{
    [self sucBtnClick:sender];
}

- (IBAction)sucBtnClick:(UIButton *)sender
{
    UITabBarController *tabbarVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarVC;
    if (tabbarVC.selectedIndex!=1)
    {
        [tabbarVC setSelectedIndex:1];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)investBtnClick:(UIButton *)sender
{
    NSArray *vcArray = self.navigationController.viewControllers;
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:vcArray];
    NSInteger count = 0;
    if ((count=tempArray.count) > 1)
    {
        [tempArray removeObjectsInRange:NSMakeRange(1, tempArray.count-1)];
    }
    KSWholeInvestVC *wholeInvestVC = [[KSWholeInvestVC alloc]initWithIndex:WMPageControllerTypeInvestResult];
    [tempArray addObject:wholeInvestVC];
//    去投资记录列表页
    [self.navigationController setViewControllers:tempArray animated:YES];
}

- (IBAction)contactCusSerAction:(UIButton *)sender
{
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
