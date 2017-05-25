//
//  KSConfirmVCViewController.m
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSConfirmVC.h"
#import "KSLRTextField.h"
#import "UINavigationBar+Awesome.h"
#import "NSString+Format.h"
#import "KSUserMgr.h"
#import "KSRegisterVC.h"
#import "KSForgetVC.h"

//验证码发送时间
const static NSInteger verifyCodeTimeCount = 60;
const static NSInteger verifyCodeTimeSplitValue = 1;

@interface KSConfirmVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet KSLRTextField *mobileTF;
@property (weak, nonatomic) IBOutlet KSLRTextField *verifyCodeTF;
@property (strong, nonatomic) UIButton *verifyCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextActionBtn;

//用户名或手机号
@property (copy, nonatomic) NSString *userName;
//验证码
@property (copy, nonatomic) NSString *verifyCode;
//流程类型
@property (assign, nonatomic) KSVerifyProcessType verifyProcessType;
//接口中使用到的类型
@property (copy, nonatomic) NSString *verifyProcessTypeStr;

//验证码发送定时器
@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timeCounter;

//验证码BL
@property (strong, nonatomic) KSVerifyCodeBL *verifyCodeBL;
//校验验证码请求序列号
@property (assign, nonatomic) NSInteger checkVerifyReqNo;
//发送验证码请求序列号
@property (assign, nonatomic) NSInteger sendVerifyReqNo;

@end

@implementation KSConfirmVC
/**
 *  @author semny
 *
 *  用户名或手机号初始化
 *
 *  @param userName 用户名或手机好
 *  @param type     流程类型
 *
 *  @return 手机验证码校验界面
 */
- (instancetype)initWithUserName:(NSString *)userName type:(KSVerifyProcessType)type
{
    self = [super init];
    if (self)
    {
        _userName = userName;
        _verifyProcessType = type;
        //发送验证码的接口
        if (!_verifyCodeBL)
        {
            _verifyCodeBL = [[KSVerifyCodeBL alloc] initWithType:_verifyProcessType];
        }
        if (!_verifyCodeBL.delegate)
        {
            _verifyCodeBL.delegate = self;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configNav];
    //输入框信息
    [self configTextField];
    //下一步
    [self configNextBtn];
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
    //根据流程类型设置标题
    NSString *titleStr = nil;
    switch (_verifyProcessType) {
        case KSVerifyProcessTypeRegister:
            titleStr = KRegisterText;
            break;
        case KSVerifyProcessTypeReSetPassword:
            titleStr = KForgotPasswordText;
            break;
        default:
            titleStr = KVerifyMobileText;
            break;
    }
    self.title = titleStr;
}

- (void)configTextField
{
    //用户名输入框icon
    UIImage *userNameIcon = LoadImage(@"user_name_icon");// [UIImage imageNamed:@"user_name_icon"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:userNameIcon];
    _mobileTF.leftView =imgView;
//    [_mobileTF setLeftViewRectInsetsLeft:6.0f];
    [_mobileTF setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _mobileTF.leftViewMode = UITextFieldViewModeAlways;
    _mobileTF.placeholder = KMobileTextFieldPlaceholder;
    //填充数据
    _mobileTF.text = _userName;

    //密码输入框icon
    UIImage *pwIcon = LoadImage(@"password_icon");//[UIImage imageNamed:@"password_icon"];
    imgView = [[UIImageView alloc] initWithImage:pwIcon];
    _verifyCodeTF.leftView =imgView;
//    [_verifyCodeTF setLeftViewRectInsetsLeft:6.0f];
    [_verifyCodeTF setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _verifyCodeTF.leftViewMode = UITextFieldViewModeAlways;
    _verifyCodeTF.placeholder = KVerifyCodeTextFieldPlaceholder;
    
    //右边显示按钮
    _verifyCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat height = _verifyCodeTF.frame.size.height;
    CGFloat width = 100.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    [_verifyCodeBtn setFrame:rect];
    [_verifyCodeBtn setTitle:KSendVerifyCodeActionText forState:UIControlStateNormal];
    [_verifyCodeBtn setTitle:KSendVerifyCodeActionText forState:UIControlStateSelected];
    [_verifyCodeBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
    [_verifyCodeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_verifyCodeBtn.titleLabel setFont:SYSFONT(14.0f)];
    [_verifyCodeBtn setTitleColor:NUI_HELPER.appOrangeColor forState:UIControlStateNormal];
    [_verifyCodeBtn setTitleColor:UIColorFromHexA(0x4A90E2, 1.0) forState:UIControlStateDisabled];
    [_verifyCodeBtn addTarget:self action:@selector(sendVerifyCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    _verifyCodeTF.rightView = _verifyCodeBtn;
//    [_verifyCodeTF setRightViewRectInsetsRight: 6.0f];
    [_verifyCodeTF setRightViewRectInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f)];
    _verifyCodeTF.rightViewMode = UITextFieldViewModeAlways;
    
    //增加校验事件
    @WeakObj(self);
//    RACSignal *signal1 = _mobileTF.rac_textSignal;
//    RACSignal *signal2 = _verifyCodeTF.rac_textSignal;
//    [signal1 subscribeNext:^(NSString *number) {
//        if (number.length >= KUserNameMaxLength)
//        {
//            weakself.mobileTF.text = [number substringToIndex:KUserNameMaxLength];
//        }
//    }];
//    [signal2 subscribeNext:^(NSString *number) {
//        if (number.length >= KVerifyCodeLength)
//        {
//            weakself.verifyCodeTF.text = [number substringToIndex:KVerifyCodeLength];
//        }
//    }];
    
    //手机号
    RAC(self.mobileTF, text) = [self.mobileTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPhoneNumberLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPhoneNumberLength];
        }
        weakself.userName = newValue;
        return newValue;
    }];
    
    //验证码
    RAC(self.verifyCodeTF, text) = [self.verifyCodeTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KVerifyCodeLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KVerifyCodeLength];
        }
        weakself.verifyCode = newValue;
        return newValue;
    }];
    
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
//    if (signal1)
//    {
//        [array addObject:signal1];
//    }
//    if (signal2)
//    {
//        [array addObject:signal2];
//    }
//    //组合校验
//    [[RACSignal combineLatest:array reduce:^(NSString *text1, NSString *text2){
//        weakself.userName = text1;
//        weakself.verifyCode = text2;
//        NSNumber *flagNum = [NSNumber numberWithBool:[weakself checkMobileBy:text1]&[weakself checkVerifyCodeBy:text2]];
//        return flagNum;
//    }] setKeyPath:@"enabled" onObject:_nextActionBtn];
}

- (void)configNextBtn
{
    //按钮文字
    [_nextActionBtn setTitle:KNextActionText forState:UIControlStateNormal];
    [_nextActionBtn setTitle:KNextActionText forState:UIControlStateSelected];
    
    //点击事件
    [_nextActionBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 事件方法
- (void)nextAction:(id)sender
{
    if(![self checkMobileBy:_userName])
    {
        [self showToastWithTitle:KInputPhoneErrorText];
        return;
    }
    
    if(![self checkVerifyCodeBy:_verifyCode])
    {
        [self showToastWithTitle:KInputVerifyCodeErrorText];
        return;
    }
    
    //转菊花
    [self showProgressHUD];
    
    //校验验证码
    _checkVerifyReqNo=[_verifyCodeBL doCheckVerifyCode:_verifyCode mobileNo:_userName];
}

- (void)sendVerifyCodeAction:(id)sender
{
    if(![self checkMobileBy:_userName])
    {
        [self showToastWithTitle:KInputPhoneErrorText];
        return;
    }
    //发送验证码
    _sendVerifyReqNo = [_verifyCodeBL doGetSMSVerifyCode:_userName];
}

/**
 *  @author semny
 *
 *  跳转到注册页面
 */
- (void)turn2RegisterPage
{
    KSRegisterVC *registerVC = [[KSRegisterVC alloc] initWithUserName:_userName verifyCode:_verifyCode];
    [self.navigationController pushViewController:registerVC animated:YES];
}

/**
 *  @author semny
 *
 *  跳转到忘记密码页面
 */
- (void)turn2ForgetPage
{
    DEBUGG(@"%s <<>> %@", __FUNCTION__, self.navigationController);
    KSForgetVC *forgetVC = [[KSForgetVC alloc] initWithUserName:_userName verifyCode:_verifyCode];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

#pragma mark - 内部方法
//- (BOOL)checkUserNameBy:(NSString *)username
//{
//    BOOL flag = YES;
//    //判断字符格式和长度
//    //flag = [NSString checkIfAlphaNumeric:username range:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
//    flag = [NSString checkIfAlphaNumeric:username range:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
//    return flag;
//}

- (BOOL)checkMobileBy:(NSString *)username
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:username range:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
    flag = [NSString checkIsPhoneNumber:username range:NSMakeRange(KPhoneNumberLength, KPhoneNumberLength)];
    return flag;
}

- (BOOL)checkVerifyCodeBy:(NSString *)verifyCode
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:verifyCode range:NSMakeRange(KVerifyCodeLength, KVerifyCodeLength)];
    flag = [NSString checkIsVerifyCode:verifyCode range:NSMakeRange(KVerifyCodeLength, KVerifyCodeLength)];
    return flag;
}

#pragma mark - 定时器
- (void)startTimer
{
    _timeCounter = verifyCodeTimeCount;
    if (self.timer)
    {
        [self cancelTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:verifyCodeTimeSplitValue target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
    else
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:verifyCodeTimeSplitValue target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
}

- (void)cancelTimer
{
    DEBUGG(@"%s, 1111", __FUNCTION__);
    @try
    {
        if (self.timer && [self.timer isValid])
        {
            DEBUGG(@"%s, 2222", __FUNCTION__);
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    @catch (NSException *exception)
    {
        ERROR(@"exception:%@",[exception name]);
    }
}

- (void)onTimer:(NSTimer*)timer
{
    _timeCounter -= verifyCodeTimeSplitValue;
    
    if (_timeCounter == 0)
    {
        [timer invalidate];
        
        [self setSendVerifyCodeBtnNormal];
        //[_verifyBtn setTitleColor:APPOrangeColor forState:UIControlStateNormal];
        
        return;
    }
//    int timeInt = (int)_timeCounter;
//    NSString *title = [NSString stringWithFormat:@"(%ds)%@", timeInt, KReSendVerifyCodeActionText];
//    [_verifyCodeBtn setTitle:title forState:UIControlStateDisabled];
    //[_verifyBtn setTitleColor:UIColorFromHexA(0x4A90E2, 1.0) forState:UIControlStateDisabled];
    
    [self setSendVerifyCodeBtnDisabledBy:_timeCounter];
}

- (void)setSendVerifyCodeBtnNormal
{
    _verifyCodeBtn.enabled = YES;
    NSString *title = KSendVerifyCodeActionText;
    [_verifyCodeBtn setTitle:title forState:UIControlStateNormal];
}

- (void)setSendVerifyCodeBtnDisabledBy:(NSInteger)timeValue
{
    _verifyCodeBtn.enabled = NO;
    int timeInt = (int)timeValue;
    NSString *title = [NSString stringWithFormat:@"(%ds)%@", timeInt, KReSendVerifyCodeActionText];
    [_verifyCodeBtn setTitle:title forState:UIControlStateDisabled];
}

#pragma mark - 请求回调
///业务处理成功代理回调
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    NSString *cmdId = resp.tradeId;
    NSInteger seqNo = resp.sid;
    if ([cmdId isEqualToString:kValideVerifiyCodeTradeId])
    {
        if (seqNo == _checkVerifyReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏菊花
                [weakself hideProgressHUD];
                //取消定时器
                [weakself cancelTimer];
                //设置按钮正常
                [weakself setSendVerifyCodeBtnNormal];
                
                KSVerifyCodeBL *codeBL = nil;
                if ([blEntity isKindOfClass:[KSVerifyCodeBL class]])
                {
                    codeBL = (KSVerifyCodeBL *)blEntity;
                }
                
                KSVerifyProcessType tempType = codeBL.type;
                if (tempType == KSVerifyProcessTypeRegister) {
                    //注册流程
                    [weakself turn2RegisterPage];
                }
                else if(tempType == KSVerifyProcessTypeReSetPassword)
                {
                    //忘记密码流程
                    [weakself turn2ForgetPage];
                }
            });
        }
    }
    else if([cmdId isEqualToString:kSendVerifiyCodeTradeId])
    {
        //发送验证码错误
        if (seqNo == _sendVerifyReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //开启定时器
                [weakself startTimer];
                //验证码按钮设置为不可用
                //weakself.verifyCodeBtn.enabled = NO;
                [self setSendVerifyCodeBtnDisabledBy:_timeCounter];
            });
        }
    }
}

//业务处理超时代理回调
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        [weakself hideProgressHUD];
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}

//业务失败处理
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    NSString *cmdId = resp.tradeId;
    NSInteger seqNo = resp.sid;
    if ([cmdId isEqualToString:kValideVerifiyCodeTradeId])
    {
        //校验验证码
        if (seqNo == _checkVerifyReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏菊花
                [weakself hideProgressHUD];
                NSString *errorMsg = resp.errorDescription;
                if (!errorMsg || errorMsg.length <= 0)
                {
                    errorMsg = KCheckVerifyCodeErrorText;
                }
                [weakself.view makeToast:errorMsg duration:3.0 position:CSToastPositionCenter];
            });
        }
    }
    else if([cmdId isEqualToString:kSendVerifiyCodeTradeId])
    {
        //发送验证码错误
        if (seqNo == _sendVerifyReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = resp.errorDescription;
                if (!errorMsg || errorMsg.length <= 0)
                {
                    errorMsg = KSendVerifyCodeErrorText;
                }
                [weakself.view makeToast:errorMsg duration:3.0 position:CSToastPositionCenter];
            });
        }
    }
}
@end
