//
//  KSGestureVC.m
//  kaisafax
//
//  Created by semny on 16/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSGestureSettingVC.h"
#import "SQLockLabel.h"
#import "SQGestureInfoView.h"
#import "SQGestureView.h"
#import "SQGestureConfig.h"
//#import "AppDelegate.h"
//#import "KSUserMgr.h"
#import "SQGestureMgr.h"


//最多输入5次
#define KMaxTimesForCheckInputGesture 5

@interface KSGestureSettingVC ()<SQGestureViewDelegate>

//解锁界面
@property (weak, nonatomic) IBOutlet SQGestureInfoView *gestureInfoView;
//提示Label
@property (weak, nonatomic) IBOutlet SQLockLabel *msgLabel;
//解锁界面
@property (weak, nonatomic) IBOutlet SQGestureView *gestureLockView;
//登录器他帐号按钮
//@property (weak, nonatomic) IBOutlet UIButton *loginOtherBtn;
//剩下的还可以校验的次数
//@property (assign, nonatomic) NSInteger restCheckTimes;

@end

@implementation KSGestureSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    [self configCheckInputTitle];
    [self configGestureLockView];
    [self configGestureInfoView];
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

#pragma mark - 加载视图
- (void)configNav
{
    self.title = KGesturePasswordSettingTitle;
    if (self.fromType == GestureFromTypeInStart)
    {
        //初始化首次启动
        [self setNavRightButtonByText:KJumpActionTitle titleColor:[UIColor whiteColor] imageName:nil selectedImageName:nil navBtnAction:@selector(jumpAction)];
    }
    else
    {
        //在个人中心或其他流程中启动的
        //设置返回按钮
        [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(dissmissAction)];
    }
}

//提示信息
- (void)configCheckInputTitle
{
    //设置默认显示的信息
    NSString *normalShowStr = [NSString stringWithFormat:@"%@%d%@",KGesturePasswordSettingInputTitle, KMinGestureSelectedItemCount, KGesturePasswordSettingInputUnitTitle];
    [self.msgLabel showNormalMsg:normalShowStr];
}

- (void)configGestureLockView
{
    //设置为校验
    //    [self.gestureLockView setType:CircleViewTypeLogin];
    [self.gestureLockView setDelegate:self];
}

- (void)configGestureInfoView
{
    //初始化
}

#pragma mark --------跳转操作-------------
//- (void)turn2LoginPage
//{
//    //切换root
//    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
//    [appDelegate startMainPage];
//    //跳转登录界面
//    [USER_MGR clearOwner];
//    [USER_MGR judgeLoginForVC:appDelegate.tabbarVC];
//}

//- (void)turn2MainPage
//{
//    //切换root
//    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
//    [appDelegate startMainPage];
//}

- (void)jumpAction
{
    //存储跳过的标志
    [SQGestureMgr setIsGestureJumpedForDefaultAccount:YES];
    //跳转主页面
//    [self turn2MainPage];
    
    //判断回调block
    if (self.gestureSettingFinishBlock)
    {
        self.gestureSettingFinishBlock(self, GestureActionTypeJump, nil);
    }
}

- (void)dissmissAction
{
    //取消设置
//    [self dismissViewControllerAnimated:YES completion:nil];
    //判断回调block
    if (self.gestureSettingFinishBlock)
    {
        self.gestureSettingFinishBlock(self, GestureActionTypeReturn, nil);
    }
}

- (void)hanldeGestureCompleteWith:(NSString*)gesture
{
//    if (!gesture || gesture.length <= 0)
//    {
//        return;
//    }
//    //设置新的手势密码
//    //存储新手势密码
//    [SQGestureMgr setGestureForDefaultAccount:gesture];
//    if (self.settingType == GestureFromTypeInStart)
//    {
//        //跳转到主页面
//        [self turn2MainPage];
//    }
//    else
//    {
//        //在APP过程中的设置
//        [self dissmissAction];
//    }
    
    NSError *error = nil;
    if (gesture && gesture.length > 0)
    {
        //存储新手势密码
        [SQGestureMgr setGestureForDefaultAccount:gesture];
    }
    else
    {
        error = [NSError errorWithDomain:@"Gesture setting empty" code:KGestureSettingErrorCode userInfo:nil];
    }
    //判断回调block
    if (self.gestureSettingFinishBlock)
    {
        //设置完成
        self.gestureSettingFinishBlock(self, GestureActionTypeCompleted, error);
    }
}

#pragma mark --------SQGestureViewDelegate---------
- (BOOL)gestureView:(SQGestureView *)gestureView didCompleteAtIndex:(NSInteger)index gesture:(NSString *)gesture
{
    //正常回调
    DEBUGG(@"%s, gesture: %@", __FUNCTION__, gesture);
    BOOL checkResult = YES;
    if (index == 0)
    {
        //第一次输入成功后
        //设置info view的显示
        [self.gestureInfoView showGesture:gesture];
        //设置信息
        [self.msgLabel showNormalMsg:KSettingGesturePasswordTitle2];
    }
    else if(index >= 1)
    {
        //两次输入一致
//        //设置新的手势密码
//        NSString *account = [KSUserMgr sharedInstance].user.user.mobile;
//        //存储新手势密码
//        [SQGestureMgr saveGesture:gesture key:account];
//        //跳转到主页面
//        [self turn2MainPage];
        [self hanldeGestureCompleteWith:gesture];
    }
    else
    {
        //other
    }
    return checkResult;
}

- (void)gestureView:(SQGestureView *)gestureView didFailedWithError:(NSError *)error
{
    //错误回调
    DEBUGG(@"%s, error: %@", __FUNCTION__, error);
    NSInteger errorCode = error.code;
    switch (errorCode)
    {
        case GestureErrorCodeLessLength:
        {
            //长度太小
            //密码校验错误
            NSInteger num = gestureView.minNumberOfSelectedItems;
            NSString *errorMsg = [NSString stringWithFormat:@"%@%d%@", KGesturePasswordInputLenthErrorTitle1, (int)num, KGesturePasswordInputLenthErrorTitle2];
            [self.msgLabel showWarnMsgAndShake:errorMsg];
        }
            break;
        case GestureErrorCodeDifferentData:
        {
            //与初始的数据不一致
            DEBUGG(@"Different input");
            NSString *errorMsg = KGesturePasswordInputDifferentErrorTitle;
            @WeakObj(self);
            [self.msgLabel showWarnMsgAndShake:errorMsg startBlock:nil finishBlock:^(BOOL finish) {
                //清理手势输入的状态
                [weakself.gestureLockView resetGestureInitializationState];
                //清理info视图
                [weakself.gestureInfoView resetGestureInitializationState];
                //请绘制解锁图案
                [weakself.msgLabel showNormalMsg:KSettingGesturePasswordTitle];
            }];
        }
            break;
        default:
        {
            //与初始的数据不一致
            DEBUGG(@"Unknown Error input");
        }
            break;
    }
}

- (NSInteger)minNumberOfSelectedItemsInGestureView:(SQGestureView *)gestureView
{
    //最小手势步骤
    return KMinGestureSelectedItemCount;
}

@end
