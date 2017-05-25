//
//  KSAccountSettingVC.m
//  kaisafax
//
//  Created by Jjyo on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountSettingVC.h"
#import "KSPWMgrVC.h"
#import "KSAboutVC.h"
#import "KSAccountInfoVC.h"
#import "SQTouchLockMgr.h"
#import "SQGestureMgr.h"
#import "KSGestureSettingVC.h"
#import "KSGestureVerifyVC.h"
#import "KSSwitch.h"

@interface KSAccountSettingVC ()

@property (nonatomic, weak) IBOutlet KSSwitch *fingerprintSwitch;
@property (nonatomic, assign) BOOL fingerprintSwitchFlag;
@property (nonatomic, weak) IBOutlet KSSwitch *gestureSwitch;
@property (nonatomic, assign) BOOL gestureSwitchFlag;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIView *touchView;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@end

@implementation KSAccountSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"账户设置";
    _stackView.spacing = 0;
    
    KSUserInfoEntity *entity = USER_MGR.user;
    //    用户名
//    NSString *userName = entity.user.name;
//    if (!userName || userName.length <= 0)
//    {
//        userName = entity.user.loginName;
//    }
//    if (!userName || userName.length <= 0)
//    {
//        userName = entity.user.mobile;
//    }
    NSString *userName = [entity.user showName];
     _userLabel.text = userName;
    
    //不支持指纹隐藏
    BOOL supportTouch = [[SQTouchLockMgr sharedInstance] isSupportTouchID];
    if (!supportTouch) {
        _touchView.hidden = YES;
    }
    
    //配置手势和指纹的开关状态
    [self configGestureAndTouchLockSwitchStatus];
    
    //指纹锁开关操作的处理方法
    [self configTouchLockAction];
    
    //手势锁开关操作的处理方法
    [self configGestureAction];
}

//个人信息
- (IBAction)userInfoAction:(id)sender
{
    KSAccountInfoVC *infoVc = [[KSAccountInfoVC alloc]initWithNibName:@"KSAccountInfoVC" bundle:nil];
    infoVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoVc animated:YES];
}

//密码管理
- (IBAction)passwordManagerAction:(id)sender {
    if (USER_MGR.isLogin)
    {
        KSPWMgrVC *pwMgrVC = [[KSPWMgrVC alloc] initWithNibName:@"KSPWMgrVC" bundle:nil];
        [self.navigationController pushViewController:pwMgrVC animated:YES];
    }
}

//关于我们
- (IBAction)aboutUsAction:(id)sender {
    KSAboutVC *vc = [[KSAboutVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

//安全退出
- (IBAction)logoutAction:(id)sender {
    NSString *title = @"是否退出当前账户？";
    NSString *cancelTitle = @"取消";
    NSString *okTitle = @"确定";
    [self showLGAlertTitle:title message:nil cancelButtonTitle:cancelTitle okButtonTitle:okTitle cancelBlock:nil okBlock:^(id alert) {
        //被打败了，只能做个假退出登录了
        if([USER_MGR isLogin])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [USER_MGR doLogout];
        }
    }];
}

#pragma mark -----初始效果-----------
//配置手势和指纹的开关状态
- (void)configGestureAndTouchLockSwitchStatus
{
    //判断是否开启了指纹密码
    BOOL isOpenTouchLock = [[SQTouchLockMgr sharedInstance] isAuthenticationEnabledForDefaultFeature];
    //判断是否开启了手势密码
    GestureType gtype = [SQGestureMgr checkAuthenticationTypeByGestureAndLogin];
    if (isOpenTouchLock)
    {
        //指纹密码开启了
        //指纹密码开
        self.fingerprintSwitch.on = YES;
        //手势密码关
        self.gestureSwitch.on = NO;
    }
    else if(gtype == GestureTypeLogin)
    {
        //手势密码开启了
        //指纹密码关
        self.fingerprintSwitch.on = NO;
        //手势密码开
        self.gestureSwitch.on = YES;
    }
    else
    {
        //指纹密码关
        self.fingerprintSwitch.on = NO;
        //手势密码关
        self.gestureSwitch.on = NO;
    }
}

#pragma mark -----指纹校验-----------
//配置指纹操作
- (void)configTouchLockAction
{
    @WeakObj(self);
    //开关按下
    self.fingerprintSwitch.touchBlock = ^(KSSwitch *tSwitch, NSInteger actionType){
        DEBUGG(@"tSwitch111: %@, %d", tSwitch, weakself.fingerprintSwitchFlag);
        if (actionType == TouchActionTypeBegin)
        {
            weakself.fingerprintSwitchFlag = tSwitch.isOn;
            DEBUGG(@"tSwitch222: %@, %d", tSwitch, weakself.fingerprintSwitchFlag);
        }
    };
    
    //设置开关操作回调
    [[self.fingerprintSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *tSwitch) {
        DEBUGG(@"tSwitch666: %@, %d", tSwitch, weakself.fingerprintSwitchFlag);
        //指纹开关处理
        BOOL open = tSwitch.isOn;
        if (!IOS10_AND_LATER)
        {
            //如果跟原始数据一样就不需要处理
            if (weakself.fingerprintSwitchFlag == open)
            {
                //暂时先屏蔽
                return;
            }
        }
        
        //判断是否开启了手势密码
        GestureType gtype = [SQGestureMgr checkAuthenticationTypeByGestureAndLogin];
        if (open)
        {
            if (gtype == GestureTypeLogin)
            {
                //已经开启手势锁
                //弹出提示框
                NSString *title = @"继续开启指纹解锁将关闭手势解锁";
                [weakself showLGAlertTitle:title okButtonTitle:@"继续" cancelButtonTitle:@"取消" okBlock:^(id alert) {
                    //指纹密码开启了
                    //指纹密码关闭，等待校验接口结果
                    weakself.fingerprintSwitch.on = NO;
                    //打开了手势开关的话，关闭手势需要校验手势密码
                    //[weakself turn2GestureVerifyPageForOpenTouchLock];
                    
                    //产品改为不需要校验指纹的关闭方式
                    //跳转到指纹校验
                    [weakself handleAuthenticateForAccess];
                } cancelBlock:^(id alert) {
                    //取消开启指纹解锁
                    [weakself handleTouchLockClickWith:NO];
                }];
            }
            else
            {
                //没有开启的话直接走指纹校验流程
                [weakself handleAuthenticateForAccess];
            }
        }
        else
        {
            //显示关闭的提示alert
            NSString *title = @"确认关闭指纹解锁";
            [weakself showLGAlertTitle:title okButtonTitle:@"关闭" cancelButtonTitle:@"取消" okBlock:^(id alert) {
                //关闭
                [weakself handleTouchLockClickWith:NO];
            } cancelBlock:^(id alert) {
                //取消关闭
                weakself.fingerprintSwitch.on = YES;
            }];
        }
    }];
}

- (void)handleAuthenticateForAccess
{
    SQTouchLockMgr *touchLockMgr = [SQTouchLockMgr sharedInstance];
    NSString *reason = KAuthenticationWithFingerprintInSettingPasswordReasonText;
    @WeakObj(self);
    [touchLockMgr authenticateForAccessWithReason:reason succesBlock:^(SQTouchLockPolicy policy){
        //成功处理
        DEBUGG(@"touckLock success policy: %d", (int)policy);
        if (policy == SQTouchLockPolicyAuthenticationWithBiometrics)
        {
            //如果是指纹验证完成后,直接跳转到主页
        }
        //关闭手势
        [self handleGestureClickWith:NO];
        //开启指纹
        [weakself handleTouchLockClickWith:YES];
        //提示信息
        [weakself showOperationHUDWithStr:@"指纹密码已开启"];
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
        
        //设置为关闭
//        weakself.fingerprintSwitch.on = NO;
        [weakself handleTouchLockClickWith:NO];
    }];
}

#pragma mark -------手势开关操作----------------
//配置手势操作
- (void)configGestureAction
{
    @WeakObj(self);
    //开关按下
//    [[self.gestureSwitch rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UISwitch *tSwitch) {
//        weakself.gestureSwitchFlag = tSwitch.isOn;
//        DEBUGG(@"tSwitch333: %@", tSwitch);
//    }];
    
    //开关按下
    self.gestureSwitch.touchBlock = ^(KSSwitch *tSwitch, NSInteger actionType){
        DEBUGG(@"tSwitch333: %@, %d", tSwitch, weakself.fingerprintSwitchFlag);
        if (actionType == TouchActionTypeBegin)
        {
            weakself.gestureSwitchFlag = tSwitch.isOn;
            DEBUGG(@"tSwitch777: %@, %d", tSwitch, weakself.gestureSwitchFlag);
        }
    };
    
    [[self.gestureSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *tSwitch) {
        DEBUGG(@"tSwitch555: %@, %d", tSwitch, weakself.gestureSwitchFlag);
        //手势开关
        BOOL open = tSwitch.isOn;
        //如果跟原始数据一样就不需要处理
        if (!IOS10_AND_LATER)
        {
            if (weakself.gestureSwitchFlag == open)
            {
                //暂时先屏蔽
                return;
            }
        }
        
        //判断是否开启了指纹密码
        BOOL isOpenTouchLock = [[SQTouchLockMgr sharedInstance] isAuthenticationEnabledForDefaultFeature];
        if (open)
        {
            //判断是否已经打开了指纹密码
            if (isOpenTouchLock)
            {
                //弹出提示框
                NSString *title = @"继续开启手势解锁将关闭指纹解锁";
                [weakself showLGAlertTitle:title okButtonTitle:@"继续" cancelButtonTitle:@"取消" okBlock:^(id alert) {
                    //手势密码开启了
                    //开启的时候设置手势密码
                    [weakself turn2GestureSettingPage];
                } cancelBlock:^(id alert) {
                    //取消开启指纹解锁
                    [weakself handleGestureClickWith:NO];
                }];
            }
            else
            {
                //开启的时候设置手势密码
                [weakself turn2GestureSettingPage];
            }
        }
        else
        {
            //关闭手势密码需要验证
            //[weakself turn2GestureVerifyPageForClose];
            
            //产品改为不需要校验指纹的关闭方式
            //显示关闭的提示alert
            NSString *title = @"确认关闭手势密码";
            [weakself showLGAlertTitle:title okButtonTitle:@"关闭" cancelButtonTitle:@"取消" okBlock:^(id alert) {
                //关闭
                [weakself handleGestureClickWith:NO];
            } cancelBlock:^(id alert) {
                //取消关闭
                weakself.gestureSwitch.on = YES;
            }];
        }
    }];
}

//打开指纹开关的时候如果手势密码已经开启需要校验手势密码
- (void)turn2GestureVerifyPageForOpenTouchLock
{
    @WeakObj(self);
    [self turn2GestureVerifyPageWith:^(UIViewController *vc, NSInteger actionType, NSError *error) {
        if (actionType == GestureActionTypeCompleted)
        {
            if (error)
            {
                //报错，判断错误类型
                NSInteger errorCode = error.code;
                if(errorCode == KGestureVerifyErrorCode)
                {
                    //跳转登录
                    [weakself turn2LoginPage];
                }
            }
            else
            {
                //关闭手势校验页面
                [weakself.navigationController popToViewController:weakself animated:YES];
                //跳转到指纹校验
                [weakself handleAuthenticateForAccess];
            }
        }
        else if(actionType == GestureActionTypeReturn)
        {
            //回退返回处理
            [weakself.navigationController popToViewController:weakself animated:YES];
            //指纹开关关闭
            weakself.fingerprintSwitch.on = NO;
        }
        else
        {
            //跳过，暂时不处理
            [weakself.navigationController popToViewController:weakself animated:YES];
        }
    }];
}

//关闭手势开关的时候需要校验手势密码
- (void)turn2GestureVerifyPageForClose
{
    @WeakObj(self);
    [self turn2GestureVerifyPageWith:^(UIViewController *vc, NSInteger actionType, NSError *error) {
        if (actionType == GestureActionTypeCompleted)
        {
            //手势关闭校验完成,关闭开关
//            weakself.gestureSwitch.on = NO;
//            //删除手势密码
//            [SQGestureMgr deleteGestureForDefaultAccount];
            //完成设置
            if (error)
            {
                //报错，判断错误类型
                NSInteger errorCode = error.code;
                if(errorCode == KGestureVerifyErrorCode)
                {
                    //跳转登录
                    [weakself turn2LoginPage];
                }
            }
            else
            {
                [weakself handleGestureClickWith:NO];
                [weakself showOperationHUDWithStr:@"手势密码已关闭"];
            }
        }
        else if(actionType == GestureActionTypeReturn)
        {
            //回退返回处理
            //手势密码开关开启
            weakself.gestureSwitch.on = YES;
        }
        else
        {
            //跳过，暂时不处理
        }
        //跳过，暂时不处理
        [weakself.navigationController popToViewController:weakself animated:YES];
    }];
}

- (void)turn2GestureVerifyPageWith:(void(^)(UIViewController *vc, NSInteger actionType, NSError *error))verifyBlock
{
    //手势设置
    KSGestureVerifyVC *verifyVC = [[KSGestureVerifyVC alloc] initWithNibName:@"KSGestureVerifyVC" bundle:nil];
    verifyVC.fromType = GestureFromTypeInUserCenter;
    //设置页面操作回调
    verifyVC.gestureVerifyFinishBlock = verifyBlock;
    [self.navigationController pushViewController:verifyVC animated:YES];
}

- (void)turn2GestureSettingPage
{
    //手势设置
    KSGestureSettingVC *settingVC = [[KSGestureSettingVC alloc] initWithNibName:@"KSGestureSettingVC" bundle:nil];
    settingVC.fromType = GestureFromTypeInUserCenter;
    @WeakObj(self);
    //设置页面操作回调
    settingVC.gestureSettingFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error){
        if (actionType == GestureActionTypeCompleted)
        {
            if (error)
            {
                //错误状态 关闭状态
//                weakself.gestureSwitch.on = NO;
                [weakself handleGestureClickWith:NO];
                return;
            }
            //完成设置,开启开关
//            weakself.gestureSwitch.on = YES;
//            weakself.fingerprintSwitch.on = NO;
            [weakself handleGestureClickWith:YES];
            //指纹开关关闭
            [weakself handleTouchLockClickWith:NO];
        }
        else
        {
            //返回操作, 跳过操作 都是关闭状态
//            weakself.gestureSwitch.on = NO;
            [weakself handleGestureClickWith:NO];
        }
        //跳过，暂时不处理
        [weakself.navigationController popToViewController:weakself animated:YES];
    };
    [self.navigationController pushViewController:settingVC animated:YES];
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

#pragma mark ------开关标志设置-------------
//指纹开关
- (void)handleTouchLockClickWith:(BOOL)isOpen
{
    //开关状态
    self.fingerprintSwitch.on = isOpen;
    //标志设置
    [[SQTouchLockMgr sharedInstance] setAuthenticationEnabledForDefault:isOpen];
}

//手势开关
- (void)handleGestureClickWith:(BOOL)isOpen
{
    self.gestureSwitch.on = isOpen;
    if (isOpen)
    {
        //在设置页面已经处理
    }
    else
    {
        //标志设置
        [SQGestureMgr deleteGestureForDefaultAccount];
    }
}

@end

