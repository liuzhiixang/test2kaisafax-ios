//
//  KSJingDongCardDetailVC.m
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

//

#import "KSJDCardDetailVC.h"
#import "JXMCSUserManager.h"
#import <Masonry/Masonry.h>
#import "LGAlertView.h"
#import "KSJDCardActionBL.h"
#import "KSJDGetPwdListEntity.h"


#import "NSDate+Utilities.h"
#import "NSString+AddBlank.h"
#import "UIImage+CreateImage.h"



#define MAX_CUTDOWN_TIME 60

@interface KSJDCardDetailVC ()


//验证视图
@property (strong, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UILabel *cutdownLabel;
@property (weak, nonatomic) IBOutlet UIView *cutdownView;
@property (weak, nonatomic) IBOutlet UILabel *hintLab;
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property(assign,nonatomic)BOOL cancel;
//京东卡详情

@property (weak, nonatomic) IBOutlet UIImageView *JDCardOrangeBG;
@property (weak, nonatomic) IBOutlet UIImageView *JDCardWhiteBG;
//领取时间

@property (weak, nonatomic) IBOutlet UILabel *getTimeLab;
//制卡状态
@property (weak, nonatomic) IBOutlet UILabel *cardStatusLab;

//京东E卡
@property (weak, nonatomic) IBOutlet UILabel *JDECardLab;
//5000元
@property (weak, nonatomic) IBOutlet UILabel *moneyCardLabel;


@property (weak, nonatomic) IBOutlet UIView *cardFeildView;
// 卡号
@property (weak, nonatomic) IBOutlet UILabel *cardNumLab;


@property (nonatomic, strong) HYScratchCardView *scratchCardView;
  // 密码
@property (weak, nonatomic) IBOutlet UILabel *passWordLable;
//密码图片
@property (weak, nonatomic) IBOutlet UIImageView *passWordImageView;
//BL
@property (strong, nonatomic) KSJDCardActionBL *cardActionBL;
@property(strong ,nonatomic)KSJDGetPwdListEntity *listEntity;

@property (nonatomic,assign)float deviceMultiple;

@end

@implementation KSJDCardDetailVC



- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _deviceMultiple = [self getDeviceResolutions];
    _cardActionBL = [[KSJDCardActionBL alloc]init];
    _cardActionBL.delegate = self;
    
    pwdLabel = [[UILabel alloc]init];
    pwdLabel.nuiClass = NUIAppNormalDarkGrayLabel;
    
    [self.view addSubview:pwdLabel];
    
    @WeakObj(self);
    eableClicklab = [[PCBClickLabel alloc]initLabelViewWithLab:@"请尝试重新领取或联系在线客服。" clickTextRange:NSMakeRange(10, 4) clickAtion:^{
        
        //跳转客服页面
        [weakself jumpToCustomerCenter];
              //  NSLog(@"点击了");
            }];
    [self.view addSubview:eableClicklab];
    
    eableClicklab.hidden = YES;
    pwdLabel.hidden = NO;
    _passWordImageView.hidden = NO;
    _passWordLable.hidden = NO;
    _cardNumLab.hidden = NO;
   // _entity.status = _Section;
    
    _cutdownView.hidden = YES;
    

    [[_smsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [weakself getCaptchaAction];
    }];
    
    [RACObserve(_cutdownView, hidden) subscribeNext:^(id x) {
        weakself.smsButton.hidden = ![x boolValue];
    }];
    
    _getTimeLab.text =[NSString stringWithFormat:@"领取时间: %@",[_entity.createTime dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss"]] ;
    
   [[_codeTextField rac_textSignal] subscribeNext:^(NSString *text) {
       _hintLab.hidden = text.length > 0;
   }];
    
    
    [self setMasonryAllView];

    [self showCardStatus:(int)_entity.status];
    
 }
-(void)setMasonryAllView{

    [self.JDCardOrangeBG mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
        
    }];
    
    
    [self.JDCardWhiteBG mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
        make.top.equalTo(self.view).with.offset(60*_deviceMultiple);
        
        make.bottom.equalTo(self.view).with.offset(-60*_deviceMultiple);
        
    }];
    
    
    [self.JDECardLab mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(120);
        make.right.equalTo(self.view).with.offset(-120);
        make.top.equalTo(self.view).with.offset(120*_deviceMultiple);
        
    }];
    
    [self.moneyCardLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(80);
        make.right.equalTo(self.view).with.offset(-80);
        make.top.equalTo(self.JDECardLab.mas_bottom).with.offset(20*_deviceMultiple);
        
    }];
    
    [self.getTimeLab mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(60);
        make.right.equalTo(self.view).with.offset(-60);
        make.top.equalTo(self.moneyCardLabel.mas_bottom).with.offset(20*_deviceMultiple);
        
    }];
    
    [self.cardStatusLab mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(80);
        make.right.equalTo(self.view).with.offset(-80);
        make.top.equalTo(self.getTimeLab.mas_bottom).with.offset(40*_deviceMultiple);
        
    }];
    
    int leftLength = 75;
    if (_entity.status ==2) {
        leftLength = 80;
    }
   
    
    [self.cardFeildView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view).with.offset(leftLength*_deviceMultiple);
        make.right.equalTo(self.view).with.offset(-70*_deviceMultiple);
        make.top.equalTo(self.cardStatusLab.mas_bottom).with.offset(40*_deviceMultiple);
        
    }];
    

    UITextView *promptingLanguageTV = [UITextView new];
    [promptingLanguageTV setText:@"温馨提示：\n 1、为有效保护京东卡的安全使用,每次查看密码时需验证平台绑定手机号; \n 2、京东E卡有效期为激活日期起36个月,请在有效期内使用京东卡; \n 3、京东E卡不记名、不挂失、不计息、不兌现、不可修改密码、请妥善保管卡号及密码; \n 4、平台不对京东E卡开具发票。                                                 "];
    
    [promptingLanguageTV setDelegate:(id)self];
    [promptingLanguageTV setEditable:YES];
    [promptingLanguageTV setScrollEnabled:NO];
    
    
    
    promptingLanguageTV.nuiClass = NUIAppSmallLightGrayLabel ;
    [self.view addSubview:promptingLanguageTV];
    
    //@weakify(self);
    [promptingLanguageTV mas_makeConstraints:^(MASConstraintMaker *make) {
        //@strongify(self);
        make.left.equalTo(self.view).with.offset(40);
        make.right.equalTo(self.view).with.offset(-40);
        make.height.mas_equalTo(@150);
        make.bottom.equalTo(self.view).with.offset(-60*_deviceMultiple);
    }];
    [self.view addSubview:promptingLanguageTV];

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}
-(float)getDeviceResolutions{
    float mutliple=0;
    
    int type=[UIDevice getCurrentIPhoneType];
    if ( type == 0) {
        mutliple= 0.72;
    } else if(type == 1){
        mutliple=0.85;
    }else if(type == 2){
        mutliple= 1;
    }
    else if(type == 3){
        mutliple= 1.1;
    }
    return  mutliple;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}
-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    NSMutableAttributedString * noteStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.0f元",_entity.amount.doubleValue]];
    NSRange redRangeTwo = NSMakeRange([[noteStr string] rangeOfString:@"元"].location, [[noteStr string] rangeOfString:@"元"].length);
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:redRangeTwo];
    [_moneyCardLabel setAttributedText:noteStr];
    
    
   eableClicklab.hidden = YES;
    
    if (_entity.status==0) {
        
        pwdLabel.frame = CGRectMake(_passWordImageView.frame.origin.x+_cardFeildView.frame.origin.x, _passWordImageView.frame.origin.y+_cardFeildView.frame.origin.y, _passWordImageView.frame.size.width,_passWordImageView.frame.size.height);
        
        pwdLabel.hidden = NO;
        
    } else if(_entity.status==1) {
        
        self.scratchCardView.frame = CGRectMake(_passWordImageView.frame.origin.x+_cardFeildView.frame.origin.x, _passWordImageView.frame.origin.y+_cardFeildView.frame.origin.y, _passWordImageView.frame.size.width+20,_passWordImageView.frame.size.height);
        
    }else if(_entity.status==2){
    
        eableClicklab.frame = CGRectMake(_cardNumLab.frame.origin.x+_cardFeildView.frame.origin.x, _cardNumLab.frame.origin.y+_cardFeildView.frame.origin.y, _cardNumLab.frame.size.width,_cardNumLab.frame.size.height);

        eableClicklab.hidden = NO;
        _passWordImageView.hidden = YES;
        _passWordLable.hidden = YES;
        
    }
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


-(void)showCardStatus:(int )cardStatus
{

    NSString *cardStatusStr,*cardNumStr,*passWordStr;
    switch (cardStatus) {
        case 0:
            cardStatusStr = @"制卡中";
            cardNumStr =[NSString stringWithFormat:@"卡号 :%@",@"  -- --"];
            passWordStr =@" -- --";
            pwdLabel.text = passWordStr;
            break;
        case 1:
            cardStatusStr = @"制卡成功";
            cardNumStr =[NSString stringWithFormat:@"卡号 : %@",_entity.cardNum];
            [self createScratchCardView];
            break;
        case 2:
            cardStatusStr = @"制卡失败";
            break;
            
        default:
            break;
    }
   //制卡状态
    self.cardStatusLab.text = cardStatusStr;
    //卡号
    self.cardNumLab.text = cardNumStr;
    
}

-(void)createScratchCardView
{
  
    UIImage *image = [UIImage createPassWordImage:_entity.cardPwd];
    

    self.scratchCardView = [[HYScratchCardView alloc]initWithFrame:CGRectMake(85, 100, 159, 29)];
    
    self.scratchCardView.image = image;
    
    self.scratchCardView.surfaceImage = [UIImage imageNamed:@"account_jingdong_pwd_paintcoat"];
    [self.view addSubview:self.scratchCardView];
    
    @WeakObj(self);
    self.scratchCardView.completion = ^(id userInfo) {
        [weakself.cardActionBL doGetJDCardPasswordWithCardId:weakself.entity.ID];
    };
}

//验证密码 UIview
-(void)showVerifyView
{
    
    _hintLab.hidden = YES;
    self.phoneTextField.text = _entity.mobile;
    self.phoneTextField.userInteractionEnabled = NO;
    
    CGFloat fitHeight  = [_verifyView systemLayoutSizeFittingSize:CGSizeMake(280, 200)].height;
    _verifyView.frame = CGRectMake(0, 0, 280, fitHeight);
    [_verifyView layoutIfNeeded];

    
    
    _alertView =  [self showLGAlertTitle:@"安全验证"
                                             message:@"为了您京东卡安全, 请您验证手机:"
                                                view:_verifyView
                                   otherButtonTitles:nil
                                   cancelButtonTitle:@"取消"
                                       okButtonTitle:@"确定"
                                    otherButtonBlock:nil
                                         cancelBlock:^(id alert) {
                                             [self cancelDismissAlertView:alert];
                                         } okBlock:^(id alert) {
                                             [self okDismissAlertView:alert];
                                         } completionBlock:nil];
    _alertView.cancelOnTouch = NO;
    _alertView.dismissOnAction = NO;
    
    UIScrollView *scrollView = [_alertView valueForKey:@"scrollView"];
    scrollView.scrollEnabled = NO;
   
    
    
    CFAbsoluteTime prevTime = [self getBeginCutdownTime];//获取上一次请求验证码的系统时间
    int delay =(int) (CFAbsoluteTimeGetCurrent() - prevTime);
    //判断时间是否大于60秒, 防止退出UI进来重复请求
    if (delay < MAX_CUTDOWN_TIME) {
        [self countDownTime:MAX_CUTDOWN_TIME - delay];
    }else{
     [self getCaptchaAction];
    
    }
     
}


- (void)reductionButtonStateAtView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        [(UIButton *)view setSelected:NO];
    }else{
        for (UIView *subView in view.subviews) {
            [self reductionButtonStateAtView:subView];
        }
    }
}


- (void)okDismissAlertView:(LGAlertView *)alertView
{
    NSString * codeText =_codeTextField.text;
    
    if (![codeText isEqualToString:@""]) {
        
        [self.cardActionBL doGetJDCardPasswordWithCaptcha:codeText cardId:_entity.ID];
        
    } else {
        //提示输入验证码
        _hintLab.text = @"请输入验证码";
        _hintLab.hidden = NO;
        //请输入正确验证码
        UIView *rootView = [alertView valueForKey:@"view"];
        [self reductionButtonStateAtView:rootView];
        return;
    }
    
    //[self dismissAlertView:_alertView];
}
- (void)cancelDismissAlertView:(LGAlertView *)alertView
{
    [self dismissAlertView:alertView];
}

- (void)dismissAlertView:(LGAlertView *)alertView
{
    _cancel = YES;
    
    [_codeTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [alertView dismissAnimated:YES completionHandler:nil];
}

- (IBAction)clickBackButton:(id)sender {
    _cancel = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getCaptchaAction
{
    
    [self setBeginCutdownTime:CFAbsoluteTimeGetCurrent()];
    [self countDownTime:MAX_CUTDOWN_TIME];
    [_cardActionBL doSendMobileCaptchaForJDCard];
}


//倒计时
- (void)countDownTime:(int)secondTime
{
    @WeakObj(self);
    
    _cutdownView.hidden = NO;
    _cancel = NO;
    
    __block int timeout = secondTime; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0 || _cancel){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakself.cutdownView.hidden =  YES;
                weakself.hintLab.hidden = YES;
            });
        }else{
            //倒计时中....
            NSString *strTime = [NSString stringWithFormat:@"%ds", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakself.cutdownLabel.text = strTime;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}



- (CFAbsoluteTime)getBeginCutdownTime
{
    return [USER_DEFAULT floatForKey:[self getCacheCutdown]];
}

- (void)setBeginCutdownTime:(CFAbsoluteTime)time
{
    [USER_DEFAULT setFloat:time forKey:[self getCacheCutdown]];
}

- (NSString *)getCacheCutdown
{
    return [NSString stringWithFormat:@"%lld.jdcard.cutdown.cache", USER_MGR.user.user.userId];
}

#pragma mark - 佳信客服
#pragma mark - 调用客服API

-(void)jumpToCustomerCenter
{
    [[JXMCSUserManager sharedInstance] requestCSForUI:self.navigationController indexPath:1];
}

#pragma mark - KSBLDelegate

- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    NSString *tradeId = result.tradeId;
   
   

    if ([tradeId isEqualToString:KGetJDPwdTradeId]) {
        
        
        KSJDExtractItemEntity *entity = result.body;
        
            if (entity.cardPwd.length !=0) {
                
                UIImage *image = [UIImage createPassWordImage:entity.cardPwd];
                
                self.scratchCardView.image = image;
                //验证成功 直接 显示密码
                [self.scratchCardView openCard];
              
                } else {
                  [self.scratchCardView reset];
                  //验证失败 弹出 短信视图
                  [self showVerifyView];
                }
        
    }
    else if ([tradeId isEqualToString:KSendMobileCaptchaForJDTradeId]){
    //提示填写验证码
        
        NSLog(@"---)))))%@------",@"提示填写验证码");
    
    }
    else if ([tradeId isEqualToString:KGetJDDetailTradeId]){
        
        KSJDExtractItemEntity  *entity =(KSJDExtractItemEntity *)[KSJDExtractItemEntity yy_modelWithJSON:result.body];

        
        UIImage *image = [UIImage createPassWordImage:entity.cardPwd];
        
        self.scratchCardView.image = image;
        
        [self.scratchCardView openCard];
        [self dismissAlertView:_alertView];

    }
    
}
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    DEBUGG(@"%s %@",__FUNCTION__,result.body);
    NSString *tradeId = result.tradeId;
    if ([tradeId isEqualToString:KSendMobileCaptchaForJDTradeId]){
        _cancel = YES;
        self.cutdownView.hidden =  YES;
        [self setBeginCutdownTime:0];
       // [self dismissAlertView:_alertView];
    }
    if ([tradeId isEqualToString:KGetJDDetailTradeId]){
       
       
        [self dismissAlertView:_alertView];
    }
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (result.errorCode != 0 && result.errorDescription)
        {
            if ([tradeId isEqualToString:KSendMobileCaptchaForJDTradeId]){
                [weakself showToastWithTitle:result.errorDescription position:@"CSToastPositionBottom"];
            }else{
                [weakself showToastWithTitle:result.errorDescription];
            }
        }
        
    });
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    NSString *tradeId = result.tradeId;
    if ([tradeId isEqualToString:KSendMobileCaptchaForJDTradeId]){
        _cancel = YES;
        [self setBeginCutdownTime:0];
    }
    
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

@end
