//
//  KSRegisterSuccessVC.m
//  kaisafax
//
//  Created by semny on 16/8/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRegisterSuccessVC.h"
#import "KSWebVC.h"
#import "KSUserMgr.h"
#import "KSWholeNewRedPacketVC.h"
//#import "KSMainVC.h"
#import "AppDelegate.h"
#import "KSOpenAccountVC.h"
#import "KSOpenAccountBL.h"

@interface KSRegisterSuccessVC ()
//对勾图标
@property (weak, nonatomic) IBOutlet UIImageView *rightCircleIcon;
//文字描述
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

//展示流程的效果
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

//操作按钮
@property (weak, nonatomic) IBOutlet UIButton *openAccountBtn;
@property (weak, nonatomic) IBOutlet UIButton *redPacketBtn;

@end

@implementation KSRegisterSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    //提示信息
    [self configRegisterMessage];
    //流程图信息
    [self configRegisterProcess];
    //按钮
    [self configRedPacketBtn];
    [self configOpenAccountBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)transparentNavigationBar
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 加载视图
- (void)configNav
{
    self.title = KRegisterSuccessText;
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
}

- (void)configRegisterMessage
{
    //注册成功提示
    _label1.text = KRegisterSuccessShowText;
    //注册红包提示
    _label2.text = KRegisterRedPacketShowText;
    //开通账户提示
    _label3.text = KOpenAccountShowText;
}

- (void)configRegisterProcess
{
    //注册
    [_btn1 setTitle:KRegisterText forState:UIControlStateNormal];
    [_btn1 setTitle:KRegisterText forState:UIControlStateSelected];
    _btn1.adjustsImageWhenHighlighted = NO;
    //开户
    [_btn2 setTitle:KOpenAccountText forState:UIControlStateNormal];
    [_btn2 setTitle:KOpenAccountText forState:UIControlStateSelected];
    _btn2.adjustsImageWhenHighlighted = NO;
    //投资
    [_btn3 setTitle:KInvestText forState:UIControlStateNormal];
    [_btn3 setTitle:KInvestText forState:UIControlStateSelected];
    _btn3.adjustsImageWhenHighlighted = NO;
}

- (void)configOpenAccountBtn
{
    //按钮文字
    [_openAccountBtn setTitle:KOpenAccountActionText forState:UIControlStateNormal];
    [_openAccountBtn setTitle:KOpenAccountActionText forState:UIControlStateSelected];
    
    //点击事件
    [_openAccountBtn addTarget:self action:@selector(openAccountAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configRedPacketBtn
{
    //按钮文字
    [_redPacketBtn setTitle:KRedPacketActionText forState:UIControlStateNormal];
    [_redPacketBtn setTitle:KRedPacketActionText forState:UIControlStateSelected];
    
    //点击事件
    [_redPacketBtn addTarget:self action:@selector(showRedpacketAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 事件方法
- (void)openAccountAction:(id)sender
{
    [self turn2OpenAccountPage];
}

- (void)showRedpacketAction:(id)sender
{
    [self turn2RedPacketPage];
}

/**
 *  @author semny
 *
 *  关闭登录流程
 */
- (void)dismissLoginProgress
{
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [USER_MGR dismissLoginProgressFor:self.navigationController completion:nil];
}

/**
 *  @author semny
 *
 *  回退方法
 *
 *  @param sender 回退按钮
 */
- (void)backAction:(id)sender
{
    [self hideProgressHUD];
    //退出登录页面
    [self dismissLoginProgress];
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
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KInvestText type:KSWebSourceTypeRegister];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeRegister];
}

/**
 *  @author semny
 *
 *  跳转到我的红包
 */
- (void)turn2RedPacketPage
{
    DEBUGG(@"%s <<>> %@", __FUNCTION__, self.navigationController);
    //推出当前登录流程
    @WeakObj(self);
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        //跳转到个人中心我的红包
//        [weakself gotoWholeRedPacket];
//    }];
    [USER_MGR dismissLoginProgressFor:self.navigationController completion:^{
        //跳转到个人中心我的红包
        [weakself gotoWholeRedPacket];
    }];
}

- (void)gotoWholeRedPacket
{
//    KSMainVC *mainVC = [KSMainVC sharedInstance];
//    //切换到tabbar的个人中心
//    [mainVC.tabbarVC setSelectedIndex:2];
    
    UITabBarController *tabbarVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarVC;
    [tabbarVC setSelectedIndex:2];
    
    //进入我的红包
    UINavigationController *nav = tabbarVC.selectedViewController;
    NSArray *array = nav.viewControllers;
    NSUInteger index = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[KSWholeNewRedPacketVC class]])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    //判断是否查找到
    if (index != NSNotFound)
    {
        array = [array subarrayWithRange:NSMakeRange(0, index+1)];
    }
    else
    {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
        KSWholeNewRedPacketVC *wholeVC = [[KSWholeNewRedPacketVC alloc] init];
        wholeVC.type = KSWebSourceTypeRegister;
        wholeVC.hidesBottomBarWhenPushed = YES;
        [tempArray addObject:wholeVC];
        array = tempArray;
    }
    [nav setViewControllers:array animated:YES];
}
@end
