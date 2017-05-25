//
//  KSGestureVerifyVC.m
//  kaisafax
//
//  Created by semny on 16/11/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSGestureVerifyVC.h"
#import "SQLockLabel.h"
#import "SQGestureView.h"
#import "AppDelegate.h"
#import "KSUserMgr.h"
#import "SQGestureMgr.h"

//最多输入5次
#define KMaxTimesForCheckInputGesture 5

@interface KSGestureVerifyVC ()<SQGestureViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userIconView;
//提示Label
@property (weak, nonatomic) IBOutlet SQLockLabel *msgLabel;
//解锁界面
@property (weak, nonatomic) IBOutlet SQGestureView *gestureLockView;
//登录器他帐号按钮
@property (weak, nonatomic) IBOutlet UIButton *loginOtherBtn;

//剩下的还可以校验的次数
@property (assign, nonatomic) NSInteger restCheckTimes;

@end

@implementation KSGestureVerifyVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    [self configCheckInputTitle];
    [self configGestureLockView];
    [self configLoginOtherBtn];
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
    self.title = @"验证手势密码";
    if (self.fromType != GestureFromTypeInStart)
    {
        //在个人中心或其他流程中启动的
        //设置返回按钮
        [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(dissmissAction)];
    }
    else
    {
        self.needShowNavBar = NO;
    }
}

//提示信息
- (void)configCheckInputTitle
{
    //设置默认显示的信息
    NSString *normalShowStr = KGesturePasswordCheckInputTitle;
    [self.msgLabel showNormalMsg:normalShowStr];
}

- (void)configGestureLockView
{
    //设置为校验
//    [self.gestureLockView setType:CircleViewTypeLogin];
    self.restCheckTimes = KMaxTimesForCheckInputGesture;
    [self.gestureLockView setDelegate:self];
}

- (void)configLoginOtherBtn
{
    //按钮文字
    NSString *text = KLoginOtherAccountTitle;
    [_loginOtherBtn setTitle:text forState:UIControlStateNormal];
    [_loginOtherBtn setTitle:text forState:UIControlStateSelected];
    [_loginOtherBtn addTarget:self action:@selector(turn2LoginPage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)turn2LoginPage
{
    //清理掉登录态
    [USER_MGR clearOwner];
    //切换root
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    [appDelegate startMainPage];
    //跳转登录界面
    [USER_MGR judgeLoginForVC:appDelegate.tabbarVC needEndAnimation:YES];
}

//- (void)turn2MainPage
//{
//    //切换root
//    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
//    [appDelegate startMainPage];
//}

#pragma mark --------SQGestureViewDelegate---------
- (BOOL)gestureView:(SQGestureView *)gestureView didCompleteAtIndex:(NSInteger)index gesture:(NSString *)gesture
{
    //正常回调
    DEBUGG(@"%s, gesture: %@", __FUNCTION__, gesture);
    //判断是否和设置的手势密码一致
    BOOL checkResult = [SQGestureMgr checkInputGestureForDefaultAccount:gesture];
    if (!checkResult)
    {
        //次数递减
        --self.restCheckTimes;
        //密码校验错误
        NSString *errorMsg = [NSString stringWithFormat:@"%@%d%@", KGesturePasswordCheckInputErrorTitle, (int)self.restCheckTimes, KTimesTitle];
        [self.msgLabel showWarnMsgAndShake:errorMsg];
        
        //校验次数用完
        if (self.restCheckTimes <= 0)
        {
            //跳转到登录流程
//            [self turn2LoginPage];
            
            //新增回调处理
            NSError *error = [NSError errorWithDomain:@"Gesture verify error" code:KGestureVerifyErrorCode userInfo:nil];;
            [self hanldeGestureCompleteWith:error];
        }
    }
    else
    {
        //完成
        [self hanldeGestureCompleteWith:nil];
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

#pragma mark --------跳转操作-------------
- (void)dissmissAction
{
    //取消设置
    //    [self dismissViewControllerAnimated:YES completion:nil];
    //判断回调block
    if (self.gestureVerifyFinishBlock)
    {
        self.gestureVerifyFinishBlock(self, GestureActionTypeReturn, nil);
    }
}

- (void)hanldeGestureCompleteWith:(NSError*)error
{
    //判断回调block
    if (self.gestureVerifyFinishBlock)
    {
        //设置完成
        self.gestureVerifyFinishBlock(self, GestureActionTypeCompleted, error);
    }
}

@end



