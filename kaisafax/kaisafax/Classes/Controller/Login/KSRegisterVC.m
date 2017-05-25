//
//  KSRegisterVC.m
//  kaisafax
//
//  Created by semny on 16/8/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRegisterVC.h"
#import "KSLRTextField.h"
#import "BEMCheckBox.h"
#import "KSWebVC.h"
#import <YYText/YYText.h>
#import "KSRegisterBL.h"
#import "KSRegisterSuccessVC.h"

@interface KSRegisterVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIView *contentView;
//注册的用户密码
@property (weak, nonatomic) IBOutlet KSLRTextField *passwordTF1;
@property (weak, nonatomic) IBOutlet KSLRTextField *passwordTF2;
//推荐人手机或推荐码
@property (weak, nonatomic) IBOutlet KSLRTextField *morTF;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet BEMCheckBox *agreeCheckBox;
@property (weak, nonatomic) IBOutlet YYLabel *agreeProtocolLabel;

//注册BL
@property (strong, nonatomic) KSRegisterBL *registerBL;
//注册请求序列号
@property (assign, nonatomic) NSInteger registerReqNo;

//手机号
@property (strong, nonatomic) NSString *userName;
//验证码
@property (strong, nonatomic) NSString *verifyCode;
//密码
@property (strong, nonatomic) NSString *pw1;
//确认密码
@property (strong, nonatomic) NSString *pw2;
//手机号码或推荐码
@property (copy, nonatomic) NSString *mobileOrRecommend;

@end

@implementation KSRegisterVC

- (instancetype)initWithUserName:(NSString *)userName verifyCode:(NSString*)verifyCode
{
    self = [super init];
    if (self) {
        _userName = userName;
        _verifyCode = verifyCode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //导航栏
    [self configNav];
    //输入框
    [self configTextField];
    //注册按钮
    [self configRegisterBtn];
    //注册协议
    [self configTurn2RegisterProtocolLabel];
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
    self.title = KRegisterText;
}

- (void)configTextField
{
    //密码输入框icon1
    UIImage *passwordIcon = LoadImage(@"password_icon");
    UIImageView *imgView = [[UIImageView alloc] initWithImage:passwordIcon];
    _passwordTF1.leftView =imgView;
//    [_passwordTF1 setLeftViewRectInsetsLeft:6.0f];
    [_passwordTF1 setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _passwordTF1.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF1.placeholder = KRegisterPasswordInputPlaceholder1;
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
    imgView = [[UIImageView alloc] initWithImage:passwordIcon];
    _passwordTF2.leftView =imgView;
//    [_passwordTF2 setLeftViewRectInsetsLeft:6.0f];
    [_passwordTF2 setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _passwordTF2.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF2.placeholder = KRegisterPasswordInputPlaceholder2;
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
    
    //推荐人输入框icon2
    UIImage *userNameIcon = LoadImage(@"user_name_icon");
    imgView = [[UIImageView alloc] initWithImage:userNameIcon];
    _morTF.leftView =imgView;
//    [_morTF setLeftViewRectInsetsLeft:6.0f];
    [_morTF setLeftViewRectInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    _morTF.leftViewMode = UITextFieldViewModeAlways;
    _morTF.placeholder = KRecommendedMobilePlaceholder;
    
    //增加校验事件
    @WeakObj(self);
//    RACSignal *signal1 = _passwordTF1.rac_textSignal;
//    RACSignal *signal2 = _passwordTF2.rac_textSignal;
//    [signal1 subscribeNext:^(NSString *number) {
//        NSInteger length = number.length;
//        if (length >= KPasswordMaxLength)
//        {
//            NSString *subText = [number substringToIndex:KPasswordMaxLength];
//            weakself.passwordTF1.text = subText;
//        }
//    }];
//    [signal2 subscribeNext:^(NSString *number) {
//        NSInteger length = number.length;
//        if (length >= KPasswordMaxLength)
//        {
//            NSString *subText = [number substringToIndex:KPasswordMaxLength];
//            weakself.passwordTF2.text = subText;
//        }
//    }];
    
    //密码
    RAC(self.passwordTF1, text) = [self.passwordTF1.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPasswordMaxLength)
        {
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
//    }] setKeyPath:@"enabled" onObject:_registerBtn];
}

- (void)configTurn2RegisterProtocolLabel
{
    NSAttributedString *text = [self createTurn2RegisterProtocolString];
    _agreeProtocolLabel.attributedText = text;
}

- (NSAttributedString *)createTurn2RegisterProtocolString
{
    DEBUGG(@"%s", __FUNCTION__);
    //文字
    NSString *text1 = KReadAndAgreeText;
    NSString *text2 = KRegisterProtocolText;
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
        //跳转注册协议页面
        [weakself turn2ProtocolPage];
    };
    [textString yy_setTextHighlight:highlight range:range2];
    
    return textString;
}

- (void)configRegisterBtn
{
    //按钮文字
    [_registerBtn setTitle:KRegisterAndGetRedpacketText forState:UIControlStateNormal];
    [_registerBtn setTitle:KRegisterAndGetRedpacketText forState:UIControlStateSelected];
    
    //点击事件
    [_registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 事件方法
- (void)registerAction:(id)sender
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
    
    //协议判断
    if(!_agreeCheckBox.on)
    {
        [self showToastWithTitle:KRegisterProtocolUnCheckedText];
        return;
    }
    
    //转菊花
    [self showProgressHUD];
    
    //注册
    NSString *newPW = _pw2;
    if (!_registerBL)
    {
        _registerBL = [[KSRegisterBL alloc] init];
        _registerBL.delegate = self;
    }
    _registerReqNo = [_registerBL doRegisterWith:_userName withPassword:newPW verifyCode:_verifyCode referee:_morTF.text];
}

/**
 *  @author semny
 *
 *  跳转到注册协议页面(web)
 */
- (void)turn2ProtocolPage
{
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KRegisterProtocolPage data:nil error:nil];
    NSString *title = KRegisterProtocolText;
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:title type:KSWebSourceTypeRegister];
}

/**
 *  @author semny
 *
 *  跳转到注册成功页面
 */
- (void)turn2RegisterSuccessPage
{
    //注册成功页面
    KSRegisterSuccessVC *resultVC = [[KSRegisterSuccessVC alloc] init];
    //推出注册流程所有界面只保留结果页面
    NSArray *navArray = [NSArray arrayWithObject:resultVC];
    INFO(@"before----------------------");
    INFO(@"childrens %@",self.navigationController.childViewControllers);
    INFO(@"topview %@",self.navigationController.topViewController);
    [self.navigationController setViewControllers:navArray];
    

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

#pragma mark - 内部方法
- (BOOL)checkPasswordBy:(NSString *)password
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    flag = [NSString checkIsValidPassword:password range:NSMakeRange(KPasswordMinLength, KPasswordMaxLength)];
    return flag;
}

#pragma mark -请求回调
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
        if ([pCmdIdStr isEqualToString:KRegisterProcessTradeId])
        {
            //手机号登录流程
            if(pSeqNo == _registerReqNo)
            {
                if ([KRegisterTradeId isEqualToString:tradeId])
                {
                    // VC层暂时不需要处理
                }
                else if ([KUserNewAssetsTradeId isEqualToString:tradeId])
                {
                    //通知账户中心更新隐藏信息
                    [USER_MGR setUserAssetsHiddenFlagAccordingtoRegisterOrLogin:NO];
                    
                    //停止菊花
                    [self hideProgressHUD];
                    
                    //退出当前页面
                    [self turn2RegisterSuccessPage];
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
        if ([pCmdIdStr isEqualToString:KRegisterProcessTradeId])
        {
            //手机号登录流程
            if(pSeqNo == _registerReqNo)
            {
                [self hideProgressHUD];
                
                NSString *errorMsg = result.errorDescription;
                if (!errorMsg || errorMsg.length <= 0)
                {
                    errorMsg = KRegisterFailedText;
                }
                if ([KRegisterTradeId isEqualToString:tradeId])
                {
                    [self.view makeToast:errorMsg duration:2.0 position:CSToastPositionCenter];
                }
                else if ([KUserNewAssetsTradeId isEqualToString:tradeId])
                {
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
