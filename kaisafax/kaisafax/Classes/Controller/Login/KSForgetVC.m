//
//  KSForgetVC.m
//  kaisafax
//
//  Created by semny on 16/8/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSForgetVC.h"
#import "KSLRTextField.h"
#import "KSUserInfoBL.h"

@interface KSForgetVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet KSLRTextField *passwordTF1;
@property (weak, nonatomic) IBOutlet KSLRTextField *passwordTF2;
@property (weak, nonatomic) IBOutlet UIButton *nextActionBtn;

@property (strong, nonatomic) KSUserInfoBL *userInfoBL;
//修改密码请求序列号
@property (assign, nonatomic) NSInteger forgotPWReqNo;

//密码
@property (strong, nonatomic) NSString *pw1;
//确认密码
@property (strong, nonatomic) NSString *pw2;
//手机号
@property (copy, nonatomic) NSString *userName;
//验证码
@property (copy, nonatomic) NSString *verifyCode;

@end

@implementation KSForgetVC

- (instancetype)initWithUserName:(NSString *)userName verifyCode:(NSString*)verifyCode
{
    self = [super init];
    if (self)
    {
        _userName = userName;
        _verifyCode = verifyCode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //用户信息BL
    _userInfoBL = [[KSUserInfoBL alloc] init];
    _userInfoBL.delegate = self;
    
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
    self.title = KForgotPasswordText;
}

- (void)configTextField
{
    //密码输入框icon1
    UIImage *passwordIcon = LoadImage(@"password_icon");
    UIImageView *imgView = [[UIImageView alloc] initWithImage:passwordIcon];
    _passwordTF1.leftView =imgView;
//    [_passwordTF1 setLeftViewRectInsetsLeft:6.0f];
    _passwordTF1.placeholder = KPasswordInputPlaceholder1;
    [_passwordTF1 setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _passwordTF1.leftViewMode = UITextFieldViewModeAlways;
    //右边显示按钮
    UIButton *eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat height = _passwordTF1.frame.size.height;
    CGRect rect = CGRectMake(0.0f, 0.0f, height, height);
    [eyeBtn setFrame:rect];
    [eyeBtn setImage:LoadImage(@"eye_normal") forState:UIControlStateNormal];
    [eyeBtn setImage:LoadImage(@"eye_selected") forState:UIControlStateSelected];
    [eyeBtn addTarget:self action:@selector(passwordShowAction1:) forControlEvents:UIControlEventTouchUpInside];
    _passwordTF1.rightView = eyeBtn;
    _passwordTF1.rightViewMode = UITextFieldViewModeAlways;
    
    //密码输入框icon2
    UIImageView *imgView2 = [[UIImageView alloc] initWithImage:passwordIcon];
    _passwordTF2.leftView =imgView2;
    //    [_passwordTF2 setLeftViewRectInsetsLeft:6.0f];
    _passwordTF2.placeholder = KPasswordInputPlaceholder2;
    [_passwordTF2 setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _passwordTF2.leftViewMode = UITextFieldViewModeAlways;
    //右边显示按钮
    eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    height = _passwordTF2.frame.size.height;
    rect = CGRectMake(0.0f, 0.0f, height, height);
    [eyeBtn setFrame:rect];
    [eyeBtn setImage:LoadImage(@"eye_normal") forState:UIControlStateNormal];
    [eyeBtn setImage:LoadImage(@"eye_selected") forState:UIControlStateSelected];
    [eyeBtn addTarget:self action:@selector(passwordShowAction2:) forControlEvents:UIControlEventTouchUpInside];
    _passwordTF2.rightView = eyeBtn;
    _passwordTF2.rightViewMode = UITextFieldViewModeAlways;
    
    //增加校验事件
    @WeakObj(self);
//    RACSignal *signal1 = _passwordTF1.rac_textSignal;
//    RACSignal *signal2 = _passwordTF2.rac_textSignal;
//    [signal1 subscribeNext:^(NSString *number) {
//        if (number.length >= KPasswordMaxLength)
//        {
//            weakself.passwordTF1.text = [number substringToIndex:KPasswordMaxLength];
//        }
//    }];
//    [signal2 subscribeNext:^(NSString *number) {
//        if (number.length >= KPasswordMaxLength)
//        {
//            weakself.passwordTF2.text = [number substringToIndex:KPasswordMaxLength];
//        }
//    }];
    
    //密码
    RAC(self.passwordTF1, text) = [self.passwordTF1.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength) {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.pw1 = newValue;
        return newValue;
    }];
    
    //密码
    RAC(self.passwordTF2, text) = [self.passwordTF2.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.pw2 = newValue;
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
//    //组合判断
//    [[RACSignal combineLatest:array reduce:^(NSString *text1, NSString *text2){
//        weakself.pw1 = text1;
//        weakself.pw2 = text2;
//        //判断是否一致
//        NSNumber *flagNum = nil;
//        if (![text1 isEqualToString:text2])
//        {
//            flagNum = [NSNumber numberWithBool:NO];
//            return flagNum;
//        }
//        flagNum = [NSNumber numberWithBool:[weakself checkPasswordBy:text1]&[weakself checkPasswordBy:text2]];
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

#pragma mark - 内部方法
- (BOOL)checkPasswordBy:(NSString *)password
{
    BOOL flag = YES;
    //判断字符格式和长度
//    flag = [NSString checkIfAlphaNumeric:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    flag = [NSString checkIsValidPassword:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    return flag;
}

/**
 *  @author semny
 *
 *  密码显示／隐藏操作
 *
 *  @param sender 按钮
 */
- (void)passwordShowAction1:(UIButton *)sender
{
    if(_passwordTF1)
    {
        BOOL flag = _passwordTF1.secureTextEntry;
        _passwordTF1.secureTextEntry = !flag;
        sender.selected = flag;
    }
}

- (void)passwordShowAction2:(UIButton *)sender
{
    if(_passwordTF2)
    {
        BOOL flag = _passwordTF2.secureTextEntry;
        _passwordTF2.secureTextEntry = !flag;
        sender.selected = flag;
    }
}

#pragma mark - 事件方法
- (void)nextAction:(id)sender
{
    //密码两次输入校验
    if (![_pw1 isEqualToString:_pw2])
    {
        [self showToastWithTitle:KSetPasswordInputDifferText];
        return;
    }
    
    if(![self checkPasswordBy:_pw1] || ![self checkPasswordBy:_pw2])
    {
        [self showToastWithTitle:KInputPasswordErrorText1];
        return;
    }
    
    //转菊花
    [self showProgressHUD];
    
    //校验验证码
    NSString *newPW = _pw2;
    if (!_userInfoBL)
    {
        _userInfoBL = [[KSUserInfoBL alloc] init];
        _userInfoBL.delegate = self;
    }
    _forgotPWReqNo = [_userInfoBL doForgotUserPassword:newPW mobile:_userName verifyCode:_verifyCode];
}

/**
 *  @author semny
 *
 *  跳转到登录页面
 */
- (void)turn2LoginPage
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 请求回调
///业务处理成功代理回调
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    NSString *cmdId = resp.tradeId;
    NSInteger seqNo = resp.sid;
    if ([cmdId isEqualToString:KForgotPasswordTradeId])
    {
        if (seqNo == _forgotPWReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏菊花
                [weakself hideProgressHUD];
                
                //退出到登录界面
                [weakself turn2LoginPage];
                
                //显示修改密码成功
                [KEY_WINDOW makeToast:KSetPasswordSuccessText duration:3.0 position:CSToastPositionCenter];
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
    if ([cmdId isEqualToString:KForgotPasswordTradeId])
    {
        //校验验证码
        if (seqNo == _forgotPWReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏菊花
                [weakself hideProgressHUD];
                NSString *errorMsg = resp.errorDescription;
                if (!errorMsg || errorMsg.length <= 0)
                {
                    errorMsg = KSetPasswordFailedText;
                }
                [weakself.view makeToast:errorMsg duration:3.0 position:CSToastPositionCenter];
            });
        }
    }
}
@end
