//
//  KSTouchIdVC.m
//  kaisafax
//
//  Created by semny on 16/11/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSTouchIdVC.h"
#import "UIView+Toast.h"
#import "SQTouchLockMgr.h"
#import "KSUserMgr.h"
#import "KSStatisticalMgr.h"
#import "AppDelegate.h"

@interface KSTouchIdVC ()

@property (weak, nonatomic) IBOutlet UIImageView *userIconView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *fingerprintBtn;
@property (weak, nonatomic) IBOutlet UILabel *fingerprintTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *otherLoginBtn;
@end

@implementation KSTouchIdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    [self configUserName];
    [self configLockIconAndTitle];
    [self configOtherLoginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] beginLogPageView:self.pageName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //指纹校验
    [self touckLock];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] endLogPageView:self.pageName];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#ifdef DEBUG
- (void)dealloc
{
    DEBUGG(@"%s", __FUNCTION__);
}
#endif

#pragma mark - 加载视图
- (void)configNav
{
}

- (void)configUserName
{
    //    用户名
    KSUserBaseEntity *user = USER_MGR.user.user;
    NSString *userName = user.getFormateName;
    if (!userName || userName.length <= 0)
    {
        userName = user.getFormateLoginName;
    }
    if (!userName || userName.length <= 0)
    {
        userName = user.getFormateMobile;
    }
    _userNameLabel.text = userName;
}

- (void)configLockIconAndTitle
{
    //按钮文字
    NSString *text = KUseFingerprintLoginTitle;
    [_fingerprintBtn addTarget:self action:@selector(touckLock) forControlEvents:UIControlEventTouchUpInside];
    _fingerprintTitleLabel.text = text;
}

- (void)configOtherLoginButton
{
    [_otherLoginBtn setEnabled:NO];
    [_otherLoginBtn setTitle:KTurnToOtherLoginPageTitle forState:UIControlStateNormal];
    [_otherLoginBtn setTitle:KTurnToOtherLoginPageTitle forState:UIControlStateSelected];
    [_otherLoginBtn addTarget:self action:@selector(turn2LoginPage) forControlEvents:UIControlEventTouchUpInside];
    [self performSelector:@selector(enableOtherLogin) withObject:nil afterDelay:2.0f];
}

- (void)enableOtherLogin
{
    [_otherLoginBtn setEnabled:YES];
}

- (void)turn2LoginPage
{
    //清理掉登录态
    [USER_MGR clearOwner];
    //切换root
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    [appDelegate startMainPage];
    //跳转登录界面
//    [USER_MGR clearOwner];
    [USER_MGR judgeLoginForVC:appDelegate.tabbarVC needEndAnimation:YES];
}

//- (void)turn2MainPage
//{
//    //切换root
//    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
//    [appDelegate startMainPage];
//}

#pragma mark ----------指纹-----------
- (void)touckLock
{
    SQTouchLockMgr *touchLockMgr = [SQTouchLockMgr sharedInstance];
    NSString *reason = KAuthenticationWithFingerprintReasonText;
    @WeakObj(self);
    [touchLockMgr authenticateForAccessAndSwitchWithReason:reason succesBlock:^(SQTouchLockPolicy policy){
        //成功处理
        DEBUGG(@"touckLock success policy: %d", (int)policy);
        if (policy == SQTouchLockPolicyAuthenticationWithBiometrics)
        {
            //指纹验证
        }
        //结果回调
        if (weakself.touchIDCheckFinishBlock)
        {
            weakself.touchIDCheckFinishBlock(weakself,0, nil);
        }
    } failureBlock:^(NSError *error) {
        //失败处理
        DEBUGG(@"%s touckLock failed", __FUNCTION__);
        
        NSInteger errorCode = error.code;
        //多次输入出错
        if(errorCode == SQTouchLockErrorAuthenticationFailed)
        {
            [weakself.view makeToast:@"指纹校验失败" duration:3.0 position:CSToastPositionCenter];
        }
        else if (errorCode == SQTouchLockErrorTouchIDNotAvailable)
        {
            //指纹模块无效或者没有指纹识别模块
            [weakself showLGAlertTitle:@"此设备不支持指纹识别"];
        }
        else if(errorCode == SQTouchLockErrorTouchIDNotEnrolled)
        {
            //没有设置指纹
            [weakself showLGAlertTitle:@"你尚未设置Touch ID,请在手机系统\"设置>Touch ID与密吗\"中添加指纹"];
        }
        else if(errorCode == SQTouchLockErrorPasscodeNotSet)
        {
            //没有设置密码
            [weakself showLGAlertTitle:@"你尚未设置Touch ID,请在手机系统\"设置>Touch ID与密吗\"中添加指纹"];
        }
        
        //结果回调
        if (weakself.touchIDCheckFinishBlock)
        {
            weakself.touchIDCheckFinishBlock(weakself,0, error);
        }
    }];
}

#pragma mark ----------pageName-----------
- (NSString *)pageName
{
    NSString *tPageName = NSStringFromClass(self.class);
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"KS" withString:@""];
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"VC" withString:@"Page"];
    return tPageName;
}

@end
