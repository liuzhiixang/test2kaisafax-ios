//
//  KSADPushVC.m
//  kaisafax
//
//  Created by semny on 16/10/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADPushVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KSADWebVC.h"
#import "AppDelegate.h"
#import "KSStatisticalMgr.h"
#import "KSShareEntity.h"
//#import "KSNavigationVC.h"
#import "KSADMgr.h"

//验证码发送时间
const static NSInteger ADShowTimeCount = 3;
const static NSInteger ADShowTimeSplitValue = 1;

@interface KSADPushVC ()

//广告图片
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
//logo图片
@property (weak, nonatomic) IBOutlet UIImageView *adLogoView;
//跳过广告的按钮
@property (weak, nonatomic) IBOutlet UIButton *adJumpBtn;

//验证码发送定时器
@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timeCounter;

@end

@implementation KSADPushVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    
    //设置初始显示
    NSString *actionTitle = [NSString stringWithFormat:@"%@ %ds", KJumpActionTitle, (int)ADShowTimeCount];
    [self.adJumpBtn setTitle:actionTitle forState:UIControlStateNormal];
    [self.adJumpBtn setTitle:actionTitle forState:UIControlStateSelected];
    
    NSString *imageUrl = nil;
    if (self.bitemData && (imageUrl=self.bitemData.imageUrl) && imageUrl.length > 0)
    {
        //设置广告图片
        [self.adImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    }
    
    //点击事件
    NSString *linkUrl = nil;
    if (self.bitemData && (linkUrl=self.bitemData.url) && linkUrl.length > 0)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        self.adImageView.userInteractionEnabled = YES;
        [self.adImageView addGestureRecognizer:tapGesture];
    }
    
    //开启定时器
//    [self startTimer];
    //接收启动页面完成的通知
    @WeakObj(self);
    [[NOTIFY_CENTER rac_addObserverForName:KLaunchCompletedNotificationKey object:nil] subscribeNext:^(id x){
        [weakself startTimer];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] beginLogPageView:self.pageName];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] endLogPageView:self.pageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef DEBUG
- (void)dealloc
{
    DEBUGG(@"%s", __FUNCTION__);
    [self cancelTimer];
}
#endif

- (NSString *)pageName
{
    NSString *tPageName = NSStringFromClass(self.class);
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"KS" withString:@""];
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"VC" withString:@"Page"];
    return tPageName;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 点击事件
- (IBAction)jumpAction:(id)sender
{
    [self startAction];
}

- (void)startAction
{
    //停止定时器
    [self cancelTimer];
    //启动安全相关流程
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    UIViewController *securityVC = [appDelegate startSecurityPageWithBegin:nil afterBlock:nil];
    if (!securityVC)
    {
        //如果不需要安全流程的话
        //启动主界面
        [appDelegate startMainPage];
    }
}

- (void)tapAction:(id)sender
{
    //停止定时器
    [self cancelTimer];
    @WeakObj(self);
    //启动安全相关流程
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    [appDelegate startSecurityPageWithBegin:^(UIViewController *vc) {
        if (vc)
        {
            [weakself cancelTimer];
        }
        else
        {
            DEBUGG(@"%s", __FUNCTION__);
            //如果不需要安全流程的话
            //内部停止定时器
            [weakself startADDetailPageInADProgress];
        }
    } afterBlock:^(UIViewController *vc) {
        DEBUGG(@"%s", __FUNCTION__);
        //内部停止定时器
        [KSADPushVC startADDetailPageAfterCheckSecurityWith:appDelegate.tabbarVC];
    }];
}

+ (UIViewController *)configADWebVCWith:(KSBussinessItemEntity*)entity type:(NSInteger)type
{
    NSString *linkUrl = nil;
    KSADWebVC *webVC = nil;
    if (entity && (linkUrl=entity.url) && linkUrl.length > 0)
    {
        //跳转到广告h5页面
        NSString *webTitle = @"广告";
        if (!entity.shareStatus)
        {
            webVC = [[KSADWebVC alloc] initWithUrl:linkUrl title:webTitle type:type];
        }
        else
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"shareStatus"] = [NSNumber numberWithBool:entity.shareStatus];
            dict[@"shareTitle"] = entity.shareInfo.title;
            dict[@"shareURL"] = entity.shareInfo.url;
            dict[@"shareImage"] = entity.shareInfo.image;
            dict[@"shareContent"] = entity.shareInfo.content;
            webVC = [[KSADWebVC alloc] initWithUrl:linkUrl title:webTitle params:dict type:type];
        }
        webVC.syncSessionFlag = YES;
    }
    return webVC;
}

+ (BOOL)startADDetailPageAfterCheckSecurityWith:(UIViewController*)presentVC
{
    BOOL startFlag = NO;
    KSAdvertEntity *serverAdForConfig = [KSADMgr getPushADData];
    //判断有没有广告数据
    NSArray *businessData = nil;
    KSBussinessItemEntity *entity = nil;
    if(serverAdForConfig && (businessData=serverAdForConfig.businessData) && businessData.count > 0)
    {
        entity = businessData[0];
    }
    //点击事件
    NSString *linkUrl = nil;
    if (presentVC && entity && (linkUrl=entity.url) && linkUrl.length > 0)
    {
        //停止定时器
        //[self cancelTimer];
        //开启之前的
        [NOTIFY_CENTER postNotificationName:KBeforePageBeginAnimationNotificationKey object:nil userInfo:nil];
        //初始化ad web vc
        UIViewController *webVC = [self configADWebVCWith:entity type:KSWebSourceTypeADAfterCheck];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        webVC.hidesBottomBarWhenPushed = YES;
        [presentVC presentViewController:nav animated:YES completion:nil];
        startFlag = YES;
    }
    return startFlag;
}

- (BOOL)startADDetailPageInADProgress
{
    DEBUGG(@"%s 111", __FUNCTION__);
    BOOL startFlag = NO;
    //点击事件
    NSString *linkUrl = nil;
    KSBussinessItemEntity *entity = self.bitemData;
    if (entity && (linkUrl=entity.url) && linkUrl.length > 0)
    {
        DEBUGG(@"%s 222", __FUNCTION__);
        //停止定时器
        [self cancelTimer];
        
        //初始化ad web vc
        UIViewController *webVC = [[self class] configADWebVCWith:entity type:KSWebSourceTypeADStart];
        webVC.hidesBottomBarWhenPushed = YES;
        NSArray *vcs = [NSArray arrayWithObject:webVC];
        [self.navigationController setViewControllers:vcs animated:YES];
        startFlag = YES;
    }
    return startFlag;
}

#pragma mark - 定时器
- (void)startTimer
{
    _timeCounter = ADShowTimeCount;
    if (self.timer)
    {
        [self cancelTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ADShowTimeSplitValue target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
    else
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ADShowTimeSplitValue target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
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
    _timeCounter -= ADShowTimeSplitValue;
    
    if (_timeCounter == 0)
    {
        [timer invalidate];
        //设置为默认的
        [self setJumpActionBtnNormal];
        
        //跳转到首页
        [self startAction];
        
        return;
    }
    [self setJumpActionBtnTitleBy:_timeCounter];
}

- (void)setJumpActionBtnNormal
{
    NSString *title = KJumpActionTitle;
    [self.adJumpBtn setTitle:title forState:UIControlStateNormal];
    [self.adJumpBtn setTitle:title forState:UIControlStateSelected];
}

- (void)setJumpActionBtnTitleBy:(NSInteger)timeValue
{
    int timeInt = (int)timeValue;
    NSString *actionTitle = [NSString stringWithFormat:@"%@ %ds", KJumpActionTitle, timeInt];
    //避免btn奇葩的闪烁
    self.adJumpBtn.titleLabel.text = actionTitle;
    [self.adJumpBtn setTitle:actionTitle forState:UIControlStateNormal];
    [self.adJumpBtn setTitle:actionTitle forState:UIControlStateSelected];
}

@end
