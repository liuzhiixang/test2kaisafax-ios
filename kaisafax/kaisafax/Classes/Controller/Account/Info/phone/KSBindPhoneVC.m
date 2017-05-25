//
//  KSBindPhoneVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBindPhoneVC.h"
#import "KSVerifyCodeBL.h"
#import "KSPhoneBL.h"
#import "KSAccountInfoVC.h"


//验证码发送时间
const static NSInteger verifyCodeTimeCount = 60;
const static NSInteger verifyCodeTimeSplitValue = 1;

@interface KSBindPhoneVC ()<KSBLDelegate>
//点击行为
- (IBAction)getVerCodeAction:(UIButton *)sender;
- (IBAction)saveAction:(UIButton *)sender;

//手机号，验证码控件
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *verCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *verifyCodeBtn;

//手机号和验证码的字符串
@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *verifyCode;

//验证码发送定时器
@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timeCounter;

//验证码BL
@property (strong, nonatomic) KSVerifyCodeBL *verifyCodeBL;
//流程类型
@property (assign, nonatomic) KSVerifyProcessType verifyProcessType;
//修改手机号的BL
@property (strong, nonatomic) KSPhoneBL *phoneBL;
//校验验证码请求序列号
@property (assign, nonatomic) NSInteger checkPhoneReqNo;
//发送验证码请求序列号
@property (assign, nonatomic) NSInteger sendVerifyReqNo;


@property (weak, nonatomic) IBOutlet UILabel *errorVerifyLabel;

@property (weak, nonatomic) IBOutlet UILabel *errorPhoneLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorPhoneConstraintH;

@end

@implementation KSBindPhoneVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = KBindPhoneTitle;
    
    self.errorPhoneConstraintH.constant = 0.0;
    
    [self configBL];
    
    [self addObserver];

}

-(void)configBL
{
    _verifyProcessType = KSVerifyProcessTypeVerPhone;
    if (!_verifyCodeBL)
    {
        _verifyCodeBL = [[KSVerifyCodeBL alloc]initWithType:_verifyProcessType];
        _verifyCodeBL.delegate = self;
    }
    
    if (!_phoneBL)
    {
        _phoneBL= [[KSPhoneBL alloc]init];
        _phoneBL.delegate = self;
    }
}

-(void)addObserver
{
    //增加校验事件
    @WeakObj(self);
    //手机号
    RAC(self.mobileTF, text) = [self.mobileTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPhoneNumberLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPhoneNumberLength];
        }
        weakself.mobile = newValue;
        return newValue;
    }];
    
    //验证码
    RAC(self.verCodeTF, text) = [self.verCodeTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KVerifyCodeLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KVerifyCodeLength];
        }
        weakself.verifyCode = newValue;
        return newValue;
    }];
}
#pragma mark  - 内部方法
- (BOOL)checkMobileBy:(NSString *)mobile
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:username range:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
    flag = [NSString checkIsPhoneNumber:mobile range:NSMakeRange(KPhoneNumberLength, KPhoneNumberLength)];
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

- (IBAction)getVerCodeAction:(UIButton *)sender
{
    if(![self checkMobileBy:_mobile])
    {
//        [self showToastWithTitle:KInputPhoneErrorText];
        if (self.errorPhoneLabel.hidden) {
            self.errorPhoneConstraintH.constant = 12.0;
            self.errorPhoneLabel.hidden = NO;
        }
        return;
    }
    //发送验证码
    _sendVerifyReqNo = [_verifyCodeBL doGetSMSVerifyCode:_mobile];
}

- (IBAction)saveAction:(UIButton *)sender
{
    [self.view endEditing:YES];

    if(![self checkVerifyCodeBy:_verifyCode])
    {
//        [self showToastWithTitle:KInputVerifyCodeErrorText];
        if (self.errorVerifyLabel.hidden)
        {
            self.errorVerifyLabel.hidden = NO;
        }
        return;
    }
    _checkPhoneReqNo = [_phoneBL doSetPhoneWithStr:_mobile mobileCap:_verifyCode];
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
    if ([cmdId isEqualToString:KModifyPhoneTradeId])
    {
        if (seqNo == _checkPhoneReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //取消定时器
                [weakself cancelTimer];
                //设置按钮正常
                [weakself setSendVerifyCodeBtnNormal];
                
                void (^comp)() = ^{
                    //跳转到个人中心
                    NSArray *childArray = self.navigationController.childViewControllers;
                    int i;
                    for (i=0; i<childArray.count; i++)
                    {
                        if([childArray[i] isKindOfClass:[KSAccountInfoVC class]])
                            break;
                    }
                    if (i!=childArray.count) {
                        [self.navigationController popToViewController:childArray[i] animated:YES];
                    }
                    
                };
                [weakself showOperationHUDToJumpWithStr:@"绑定成功" completion:comp];
                //通知去更新个人中心
                [NOTIFY_CENTER postNotificationName:KAccountInfoChangeNotificationKey object:nil userInfo:nil];
            });
        }
    }
    else if([cmdId isEqualToString:kSendVerifiyCodeTradeId])
    {
        //发送验证码正确
        if (seqNo == _sendVerifyReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //开启定时器
                [weakself startTimer];
                //验证码按钮设置为不可用
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
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}

//业务失败处理
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    NSString *cmdId = resp.tradeId;
    NSInteger seqNo = resp.sid;
    if ([cmdId isEqualToString:KModifyPhoneTradeId])
    {
        //校验验证码
        if (seqNo == _checkPhoneReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
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
