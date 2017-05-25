//
//  KSModifyLoginPWVC.m
//  kaisafax
//
//  Created by semny on 16/11/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSModifyLoginPWVC.h"
#import "KSUserInfoBL.h"

//新密码输入框tag
#define KPasswordTFTag1     1611101
#define KPasswordTFTag2     1611102
//老密码输入框tag
#define KPasswordTFTag3     1611103

//新密码的title顶部间距(普通情况，没有错误信息)
#define KNewPasswordTitleNormalTopConstant     25.0f
#define KNewPasswordTitleErrorTopConstant     40.0f

//新密码的确认输入框顶部间距(普通情况，没有错误信息)
#define KNewPassword2NormalTopConstant     15.0f
#define KNewPassword2ErrorTopConstant      35.0f

//老密码输入框tag
#define KPasswordTFTag3     1611103

//老密码输入框tag
#define KPasswordTFTag3     1611103

@interface KSModifyLoginPWVC ()<KSBLDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIView *contentView;
//新的用户密码
@property (weak, nonatomic) IBOutlet UILabel *pwTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwDescLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF1;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn1;
@property (weak, nonatomic) IBOutlet UILabel *pwErrorLabel1;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF2;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn2;
@property (weak, nonatomic) IBOutlet UILabel *pwErrorLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTF2TopLayout;
//老的用户密码
@property (weak, nonatomic) IBOutlet UILabel *oldPWTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn3;
@property (weak, nonatomic) IBOutlet UILabel *oldPWErrorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oldPWTitleTopLayout;

//修改密码按钮
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

//修改登录密码BL
@property (strong, nonatomic) KSUserInfoBL *userInfoBL;
//注册请求序列号
@property (assign, nonatomic) NSInteger resetReqNo;

//密码
@property (copy, nonatomic) NSString *pw1;
//确认密码
@property (copy, nonatomic) NSString *pw2;
//老密码
@property (copy, nonatomic) NSString *oldPW;

@end

@implementation KSModifyLoginPWVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //导航栏
    [self configNav];
    //输入框
    [self configTextField];
    //修改密码按钮
    [self configResetBtn];
}

#pragma mark - 加载视图
- (void)configNav
{
    self.title = KChangeLoginPasswordText;
    //背景颜色
    self.contentView.backgroundColor = NUI_HELPER.appBackgroundColor;
    self.view.backgroundColor = NUI_HELPER.appBackgroundColor;
    self.contentScroll.backgroundColor = NUI_HELPER.appBackgroundColor;
}

- (void)configTextField
{
    //密码输入框icon1
    _passwordTF1.placeholder = KPasswordInputPlaceholder1;
    _pwTitleLabel.text = KSettingNewPasswordTitle;
    _pwDescLabel.text = KSettingNewPasswordDescriptionText;
    //右边显示按钮
    [_eyeBtn1 addTarget:self action:@selector(passwordShowAction1:) forControlEvents:UIControlEventTouchUpInside];
    //新密码格式错误
    _pwErrorLabel1.text = KInputPasswordErrorText1;
    
    //密码输入框icon2
    _passwordTF2.placeholder = KPasswordInputPlaceholder2;
    [_eyeBtn2 addTarget:self action:@selector(passwordShowAction2:) forControlEvents:UIControlEventTouchUpInside];
    //两次密码输入不一致
    _pwErrorLabel2.text = KInputPasswordErrorText1;//KSetPasswordInputDifferText;
    //新密码的确认输入框顶部间距(普通情况，没有错误信息)
    self.passwordTF2TopLayout.constant = KNewPassword2NormalTopConstant;
    
    //老密码 密码输入框
    _oldPasswordTF.placeholder = KOldPasswordInputPlaceholder;
    _oldPWTitleLabel.text = KVerifyCurrentPasswordTitle;
    //原始密码错误
    _oldPWErrorLabel.text = KInputOldPasswordErrorText;
    //老密码的错误信息为空的时候新密码的title的顶部间距
    self.oldPWTitleTopLayout.constant = KNewPasswordTitleNormalTopConstant;
    
    //右边显示按钮
    [_eyeBtn3 addTarget:self action:@selector(passwordShowAction3:) forControlEvents:UIControlEventTouchUpInside];
    
    //增加校验事件
    @WeakObj(self);
    //    RACSignal *signal1 = _passwordTF1.rac_textSignal;
    //    RACSignal *signal2 = _passwordTF2.rac_textSignal;
    //    RACSignal *signal3 = _oldPasswordTF.rac_textSignal;
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
    //    [signal3 subscribeNext:^(NSString *number) {
    //        if (number.length >= KPasswordMaxLength)
    //        {
    //            weakself.oldPasswordTF.text = [number substringToIndex:KPasswordMaxLength];
    //        }
    //    }];
    
    RACSignal *signal1 = self.passwordTF1.rac_textSignal;
    RACSignal *signal2 = self.passwordTF2.rac_textSignal;
    RACSignal *signal3 = self.oldPasswordTF.rac_textSignal;

    //密码
    RAC(self.passwordTF1, text) = [signal1 map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.pw1 = newValue;
        return newValue;
    }];
    
    //确认密码
    RAC(self.passwordTF2, text) = [signal2 map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.pw2 = newValue;
        return newValue;
    }];
    
    //老密码
    RAC(self.oldPasswordTF, text) = [signal3 map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.oldPW = newValue;
        return newValue;
    }];
    
    //组合判断，按钮是否有效
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (signal1)
    {
        [array addObject:signal1];
    }
    if (signal2)
    {
        [array addObject:signal2];
    }
    if (signal3)
    {
        [array addObject:signal3];
    }
    //组合判断
    [[RACSignal combineLatest:array reduce:^(NSString *text1, NSString *text2, NSString *text3){
        weakself.pw1 = text1;
        weakself.pw2 = text2;
        //老密码
        weakself.oldPW = text3;
        //判断是否一致
        NSNumber *flagNum = @(NO);
//        if (![text1 isEqualToString:text2])
//        {
//            flagNum = [NSNumber numberWithBool:NO];
//            return flagNum;
//        }
//        
//        flagNum = [NSNumber numberWithBool:[weakself checkOldPasswordBy:text3]&[weakself checkPasswordBy:text1]&[weakself checkPasswordBy:text2]];
        if (text1.length > 0 && text2.length > 0 && text3.length > 0)
        {
            flagNum = @(YES);
        }
        return flagNum;
    }] setKeyPath:@"enabled" onObject:self.resetBtn];
}

- (void)configResetBtn
{
    //按钮文字
    [_resetBtn setTitle:KConfirmSubmissionText forState:UIControlStateNormal];
    [_resetBtn setTitle:KConfirmSubmissionText forState:UIControlStateSelected];
    
    //点击事件
    [_resetBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -----UITextFieldDelegate--------
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    //编辑开始
//    NSInteger tag = textField.tag;
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //编辑结束
    NSInteger tag = textField.tag;
    NSString *pw = textField.text;
    switch (tag)
    {
        case KPasswordTFTag1:
        {
            //新密码
            BOOL flag = [self checkPasswordBy:pw];
            if (flag)
            {
                self.pwErrorLabel1.hidden = YES;
                //新密码的确认输入框顶部间距(普通情况，没有错误信息)
                self.passwordTF2TopLayout.constant = KNewPassword2NormalTopConstant;
            }
            else
            {
                self.pwErrorLabel1.hidden = NO;
                self.passwordTF2TopLayout.constant = KNewPassword2ErrorTopConstant;
            }
        }
            break;
        case KPasswordTFTag2:
        {
            //确认密码
            BOOL flag = [self checkPasswordBy:pw];
            if (flag)
            {
                NSString *pw1 = self.passwordTF1.text;
                //判断两次输入的密码是否一致
                if (![pw isEqualToString:pw1])
                {
                    //不一致提示
                    self.pwErrorLabel2.hidden = NO;
                    self.pwErrorLabel2.text = KSetPasswordInputDifferText;
                }
                else
                {
                    //隐藏
                    self.pwErrorLabel2.hidden = YES;
                }
            }
            else
            {
                //格式错误提示
                self.pwErrorLabel2.hidden = NO;
                self.pwErrorLabel2.text = KInputPasswordErrorText1;
            }
        }
            break;
        case KPasswordTFTag3:
        {
            //老密码
            BOOL flag = [self checkOldPasswordBy:pw];
            if (flag)
            {
                self.oldPWErrorLabel.hidden = YES;
                //新密码的title顶部间距(普通情况，没有错误信息)
                self.oldPWTitleTopLayout.constant = KNewPasswordTitleNormalTopConstant;
            }
            else
            {
                self.oldPWErrorLabel.hidden = NO;
                self.oldPWTitleTopLayout.constant = KNewPasswordTitleErrorTopConstant;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 事件
- (void)confirmBtnClick:(UIButton *)sender
{
    //老密码格式校验
    if(![self checkOldPasswordBy:_oldPW] )
    {
        [self showToastWithTitle:KInputOldPasswordErrorText];
        return;
    }
    
    //密码两次输入校验
    if (![_pw1 isEqualToString:_pw2])
    {
        [self showToastWithTitle:KSetPasswordInputDifferText];
        return;
    }
    
    //密码格式校验
    if(![self checkPasswordBy:_pw1] || ![self checkPasswordBy:_pw2])
    {
        [self showToastWithTitle:KInputPasswordErrorText1];
        return;
    }
    
    //老密码和新密码
    if([_pw1 isEqualToString:_oldPW])
    {
        [self showToastWithTitle:KNewAndOldPasswordInputSameText];
        return;
    }
    
    NSString *newPW = _pw2;
    NSString *oldPW = _oldPW;
    if (!_userInfoBL)
    {
        _userInfoBL = [[KSUserInfoBL alloc] init];
        _userInfoBL.delegate = self;
    }
    //转菊花
    [self showProgressHUD];
    
    //  请求修改
    _resetReqNo = [_userInfoBL doModifyUserPassword:oldPW newPW:newPW];
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

- (void)passwordShowAction3:(UIButton *)sender
{
    if(_oldPasswordTF)
    {
        BOOL flag = _oldPasswordTF.secureTextEntry;
        _oldPasswordTF.secureTextEntry = !flag;
        sender.selected = flag;
    }
}

/**
 *  @author semny
 *
 *  跳转到登录页面
 */
- (void)turn2LoginPage
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    //退出登录态
    [USER_MGR doLogout];
}

#pragma mark - 内部方法
- (BOOL)checkOldPasswordBy:(NSString *)password
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    //TODO:由于老版本对于注册没有控制，修改登录密码的老密码不能做过多的严格限制
    flag = [NSString checkIfInRange:password WithRange:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    return flag;
}

- (BOOL)checkPasswordBy:(NSString *)password
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    flag = [NSString checkIsValidPassword:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    return flag;
}

#pragma mark - 请求回调
///业务处理成功代理回调
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)resp
{
    NSString *cmdId = resp.tradeId;
    NSInteger seqNo = resp.sid;
    if ([cmdId isEqualToString:KModifyLoginPwdTradeId])
    {
        if (seqNo == _resetReqNo)
        {
            @WeakObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏菊花
                [weakself hideProgressHUD];
                
                //退出到登录界面
                [weakself turn2LoginPage];
                
                //显示修改密码成功
                [KEY_WINDOW makeToast:KChangeLoginPasswordSuccessText duration:3.0 position:CSToastPositionCenter];
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
    if ([cmdId isEqualToString:KModifyLoginPwdTradeId])
    {
        //校验验证码
        if (seqNo == _resetReqNo)
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
