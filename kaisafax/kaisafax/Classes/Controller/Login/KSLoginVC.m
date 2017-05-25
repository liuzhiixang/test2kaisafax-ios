//
//  KSLoginVC.m
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLoginVC.h"
#import "UINavigationBar+Awesome.h"
#import "NSString+Format.h"
#import "KSUserMgr.h"
#import "YYText.h"
#import "KSConfirmVC.h"
#import "KSLRTextField.h"

@interface KSLoginVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet KSLRTextField *userNameTF;
@property (weak, nonatomic) IBOutlet KSLRTextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
//@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet YYLabel *turn2RegisterLabel;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;

//登录序列号
@property (nonatomic, assign) NSInteger loginMobileSeqNo;

//用户名或手机号
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *pw;
@end

@implementation KSLoginVC

- (instancetype)initWithUserName:(NSString *)userName
{
    self = [super init];
    if (self) {
        _userName = userName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //nav
    [self configNav];
    //输入框
    [self configTextField];
    //登录按钮
    [self configLoginBtn];
    //注册跳转
    [self configTurn2RegisterLabel];
    //忘记密码
    [self configForgetButton];
    
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
- (BOOL)transparentNavigationBar
{
    return YES;
}

#pragma mark - 加载视图
- (void)configNav
{
    UIColor *color = self.navigationController.navigationBar.barTintColor;
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
}

- (void)configTextField
{
    //用户名输入框icon
    UIImage *userNameIcon = LoadImage(@"user_name_icon");// [UIImage imageNamed:@"user_name_icon"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:userNameIcon];
    _userNameTF.leftView =imgView;
//    [_userNameTF setLeftViewRectInsetsLeft:6.0f];
    [_userNameTF setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    _userNameTF.placeholder = KLoginUserNameTextFieldPlaceholder;
    //填充数据
    NSString *userName = [USER_MGR getFirstLoginHistoryAccount];
    if (!_userName || _userName.length <= 0)
    {
        _userName = userName;
    }
    _userNameTF.text = _userName;
    
    //密码输入框icon
    UIImage *pwIcon = LoadImage(@"password_icon");//[UIImage imageNamed:@"password_icon"];
    imgView = [[UIImageView alloc] initWithImage:pwIcon];
    _passwordTF.leftView =imgView;
//    [_passwordTF setLeftViewRectInsetsLeft: 6.0f];
    [_passwordTF setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF.placeholder = KLoginPasswordTextFieldPlaceholder;
    
    //右边显示按钮
    UIButton *eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat height = _passwordTF.frame.size.height;
    CGRect rect = CGRectMake(0.0f, 0.0f, height, height);
    [eyeBtn setFrame:rect];
    [eyeBtn setImage:LoadImage(@"eye_normal") forState:UIControlStateNormal];
    [eyeBtn setImage:LoadImage(@"eye_selected") forState:UIControlStateSelected];
    [eyeBtn addTarget:self action:@selector(passwordShowAction:) forControlEvents:UIControlEventTouchUpInside];
    _passwordTF.rightView = eyeBtn;
    _passwordTF.rightViewMode = UITextFieldViewModeAlways;
    
    //增加校验事件
    @WeakObj(self);
    //用户名或手机号
    RAC(self.userNameTF, text) = [self.userNameTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KUserNameMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KUserNameMaxLength];
        }
        weakself.userName = newValue;
        return newValue;
    }];
    
    //密码
    RAC(self.passwordTF, text) = [self.passwordTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPasswordMaxLength];
        }
        weakself.pw = newValue;
        return newValue;
    }];
    
//    //增加校验事件
//    @WeakObj(self);
//    [[RACSignal combineLatest:@[_userNameTF.rac_textSignal, _passwordTF.rac_textSignal] reduce:^(NSString *text1, NSString *text2){
//        NSNumber *flagNum = [NSNumber numberWithBool:[weakself checkUserNameBy:text1]&[weakself checkPasswordBy:text2]];
//        return flagNum;
//    }] setKeyPath:@"enabled" onObject:_loginBtn];
}

- (void)configLoginBtn
{
    //按钮文字
    [_loginBtn setTitle:KLoginText forState:UIControlStateNormal];
    [_loginBtn setTitle:KLoginText forState:UIControlStateSelected];
    
    //点击事件
    [_loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configTurn2RegisterLabel
{
    NSAttributedString *text = [self createTurn2RegisterString];
    _turn2RegisterLabel.attributedText = text;
}

- (void)configForgetButton
{
    [_forgetBtn setTitle:KLoginForgetPasswordText forState:UIControlStateNormal];
    [_forgetBtn setTitle:KLoginForgetPasswordText forState:UIControlStateSelected];
    [_forgetBtn addTarget:self action:@selector(turn2ForgetPage) forControlEvents:UIControlEventTouchUpInside];
}

- (NSAttributedString *)createTurn2RegisterString
{
    DEBUGG(@"%s", __FUNCTION__);
    //文字
    NSString *text1 = KLoginTurn2RegisterText1;
    NSString *text2 = KLoginTurn2RegisterText2;
    NSString *allStr = [NSString stringWithFormat:@"%@%@",text1, text2];
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:allStr];
    
    //灰色文字
    NSInteger length1 = text1.length;
    NSDictionary *text1Dict = @{NSForegroundColorAttributeName:UIColorFromHex(0X929292), NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range1 = NSMakeRange(0, length1);
    [textString addAttributes:text1Dict range:range1];
    
    //橙色文字
    NSInteger length2 = text2.length;
    UIColor *orangeColor = UIColorFromHex(0Xee7700);
    NSDictionary *text2Dict = @{NSLinkAttributeName:@"Turn2RegisterString", NSForegroundColorAttributeName:orangeColor, NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range2 = NSMakeRange(length1, length2);
    [textString addAttributes:text2Dict range:range2];
    
    // 1. 创建一个"高亮"属性，当用户点击了高亮区域的文本时，"高亮"属性会替换掉原本的属性
    YYTextBorder *highlightBorder = [YYTextBorder borderWithFillColor:orangeColor cornerRadius:3];
    YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
    [highlight setColor:[UIColor whiteColor]];
    [highlight setBackgroundBorder:highlightBorder];
    @WeakObj(self);
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect)
    {
        //跳转注册页面
        [weakself turn2ConfirmPage];
    };
    [textString yy_setTextHighlight:highlight range:range2];
    
    return textString;
}

#pragma mark - 内部方法
- (BOOL)checkUserNameBy:(NSString *)username
{
    BOOL flag = YES;
    //判断字符格式和长度
    //TODO:由于老版本对于注册没有控制，登录不能做过多的严格限制
    //flag = [NSString checkIfInRange:username WithRange:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
    flag = username && username.length>0;
    return flag;
}

- (BOOL)checkPasswordBy:(NSString *)password
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIsValidPassword:password];
    //TODO:由于老版本对于注册没有控制，登录不能做过多的严格限制
    flag = [NSString checkIfInRange:password WithRange:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    return flag;
}

#pragma mark - 事件
/**
 *  @author semny
 *
 *  登录方法
 */
- (void)loginAction:(id)sender
{
    //用户名
    NSString *userName = _userName;
    if (![self checkUserNameBy:userName])
    {
        //提示信息
        [self showToastWithTitle:KInputUserNameOrPhoneErrorText];
        return;
    }
    //密码
    NSString *pw = _pw;
    if (![self checkPasswordBy:pw])
    {
        //提示信息
        [self showToastWithTitle:KInputPasswordErrorText];
        return;
    }
    //转菊花
    [self showProgressHUD];
    
    //发起登录操作
    KSUserMgr *userMgr = USER_MGR;
    userMgr.loginDelegate = self;
    _loginMobileSeqNo = [userMgr doLoginByMobile:userName andPassaword:pw];
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
 *  跳转到注册手机验证码校验页面
 */
- (void)turn2ConfirmPage
{
    KSConfirmVC *confirmVC = [[KSConfirmVC alloc] initWithUserName:_userName type:KSVerifyProcessTypeRegister];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

/**
 *  @author semny
 *
 *  跳转到忘记密码页面
 */
- (void)turn2ForgetPage
{
    //KSForgetVC *forgetVC = [[KSForgetVC alloc] init];
    KSConfirmVC *confirmVC = [[KSConfirmVC alloc] initWithUserName:_userName type:KSVerifyProcessTypeReSetPassword];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

/**
 *  @author semny
 *
 *  密码显示／隐藏操作
 *
 *  @param sender 按钮
 */
- (void)passwordShowAction:(UIButton *)sender
{
    if(_passwordTF)
    {
        BOOL flag = _passwordTF.secureTextEntry;
        _passwordTF.secureTextEntry = !flag;
        sender.selected = flag;
    }
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

#pragma mark -
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    DEBUGG(@"%s", __FUNCTION__);
    NSString *tradeId = result.tradeId;
    
    NSString *pCmdIdStr = result.processTradeId;
    NSInteger pSeqNo = result.processSeqNo;
    
    //判断是否为父流程中的子流程
    if (pSeqNo > 0)
    {
        //判断是不是在登录流程中
        if ([pCmdIdStr isEqualToString:KLoginMobileProcessTradeId])
        {
            //手机号登录流程
            if(pSeqNo == _loginMobileSeqNo)
            {
                if ([KLoginTradeId isEqualToString:tradeId])
                {
                    // VC层暂时不需要处理

                }
                else if ([KUserNewAssetsTradeId isEqualToString:tradeId])
                {
                    //通知账户中心更新隐藏信息
                    [USER_MGR setUserAssetsHiddenFlagAccordingtoRegisterOrLogin:YES];
                    
                    //停止菊花
                    [self hideProgressHUD];
                    
                    //退出当前页面
                    [self dismissLoginProgress];
                }
            }
        }
    }
    else
    {
        //其他非复合流程的操作
    }
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    DEBUGG(@"%s", __FUNCTION__);
    NSString *tradeId = result.tradeId;
    NSString *pCmdIdStr = result.processTradeId;
    NSInteger pSeqNo = result.processSeqNo;
    
    //判断是否为父流程中的子流程
    if (pSeqNo > 0)
    {
        //判断是不是在登录流程中
        if ([pCmdIdStr isEqualToString:KLoginMobileProcessTradeId])
        {
            //手机号登录流程
            if(pSeqNo == _loginMobileSeqNo)
            {
                [self hideProgressHUD];
                
                NSString *errorMsg = result.errorDescription;
                
                if ([KLoginTradeId isEqualToString:tradeId])
                {
                    if (!errorMsg || errorMsg.length <= 0)
                    {
                        errorMsg = KLoginFailedErrorMessage1;
                    }
                    [self.view makeToast:errorMsg duration:2.0 position:CSToastPositionCenter];
                }
                else if ([KUserNewAssetsTradeId isEqualToString:tradeId])
                {
                    if (!errorMsg || errorMsg.length <= 0)
                    {
                        errorMsg = KLoginFailedErrorMessage2;
                    }
                    [self.view makeToast:errorMsg duration:2.0 position:CSToastPositionCenter];
                }
            }
        }
    }
    else
    {
        //其他非复合流程的操作
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself hideProgressHUD];
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:2.0 position:CSToastPositionCenter];
    });
}

@end
