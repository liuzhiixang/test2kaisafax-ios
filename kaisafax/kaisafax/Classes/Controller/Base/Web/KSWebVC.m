//
//  KSWebVC.m
//  kaisafax
//
//  Created by semny on 16/7/6.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSWebVC.h"
@import XWebView;
#import "JSClient.h"
#import "KSUserMgr.h"
#import "KSOpenAccountResultVC.h"
#import "KSRechargeResultVC.h"
#import "WebParseManager.h"
#import "KSDepositResultVC.h"
#import "KSBidResultVC.h"
#import "KSVersionMgr.h"
//#import "KSMainVC.h"
#import "JSONKit.h"
#import "SocialService.h"
#import "AppDelegate.h"
#import "UIViewController+BackButtonHandler.h"
#import "EmptyLoginView.h"

#import "KSHomeVC.h"
#import <Masonry/Masonry.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "NSString+Additions.h"

//#define APP_ID @"1" //暂时用1, 服务端还有没有作处理
#define kIOSLength      6
#define kLength(str)   (str.length)
#define kAmountLength (kLength(@"amount:"))


#define  kRespCode   @"respCode"
#define  kRespDesc   @"respDesc"


@interface KSWebVC ()<WKNavigationDelegate, WKUIDelegate, JSClientDelegate, SocialDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
//@property (nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,copy) NSString *compareStr;
@property (nonatomic,strong) NSMutableDictionary *webShare;
//@property (nonatomic, weak) JSClient *jsClient;
@property (nonatomic, strong) EmptyLoginView *emptyLoginView;

//share按钮显示的标志
@property (nonatomic, assign) BOOL isNeedShare;
//主要为防止像banner登录页登陆后返回两次的问题
@property (nonatomic,assign) BOOL isBackFlag;

@property (nonatomic, assign) BOOL hasCloseButtonItem;

//无网络或者加载出错的提示
//@property (nonatomic,strong) UIControl *noNetworkView;

//完整组合好的URL字符串
//@property (nonatomic,copy) NSString *requestURLStr;
//@property (nonatomic, strong) NSURL *url;

//完整组合好的URL字符串
@property (nonatomic,strong) NSURL *requestURL;
//@property (nonatomic,strong) NSString *requestURLStr;
//@property (nonatomic,copy) NSString *baseURLStr;

//失败加载的loading
@property (nonatomic, getter=didFailLoading) BOOL failedLoading;

@property (nonatomic,strong) NSDictionary *json;
@end

@implementation KSWebVC
////懒加载
-(NSMutableDictionary*)webShare
{
    if (_webShare== nil) {
        self.webShare = [NSMutableDictionary dictionary];
    }
    return _webShare;
}

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title
{
    self = [self initWithUrl:urlString title:title type:0];
    if (self)
    {
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title type:(NSInteger)type
{
    self = [self initWithUrl:urlString title:title params:nil type:type runJS:YES];
    if (self)
    {
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type
{
    self = [self initWithUrl:urlString title:title params:json type:type runJS:YES];
    if (self)
    {
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type runJS:(BOOL)js
{
    self = [super init];
    if (self)
    {
//        _urlString = urlString;
//        _baseURLStr = urlString;
        
        //20170502 semny
        _requestURL = [NSURL URLWithString:urlString];
        
        _webTitle = title;
        _type = type;
        _json = json;
        _runJS = js;
        _isNeedShare = NO;
        
        if ([json[kShareStatus] isEqual:(@YES)])
        {
            if(self.webShare)
            {
                self.webShare[kShareTitle] = json[kShareTitle];
                self.webShare[kShareURL] = json[kShareURL];
                self.webShare[kShareImage] = json[kShareImage];
                self.webShare[kShareContent] = json[kShareContent];
            }
            _isNeedShare = YES;
        }
        //_syncSessionFlag = YES;
    }
    return self;
}

#pragma mark - 类方法启动
+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title
{
    return [self pushInController:nav urlString:urlString title:title params:nil type:0];
}

+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title type:(NSInteger)type
{
    return [self pushInController:nav urlString:urlString title:title params:nil type:type];
}

+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type
{
    return [self pushInController:nav urlString:urlString title:title params:json type:type runJS:YES];
}

+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type runJS:(BOOL)js
{
    KSWebVC *vc = [[self.class alloc] initWithUrl:urlString title:title params:json type:type runJS:js];
    vc.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:vc animated:YES];
    return vc;
}


#pragma mark - 生命周期
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //不明白为什么会变成全屏幕
    if (!CGRectEqualToRect(MAIN_BOUNDS, self.view.bounds)) {
        
        _webView.frame = self.view.bounds;
        _emptyLoginView.frame = self.view.bounds;
        [_webView.scrollView reloadEmptyDataSet];
    }
    INFO(@"%s====== WebView Frame > %@ ======",__FUNCTION__, NSStringFromCGRect(self.view.bounds));

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //解析数据，初始标志参数，组合同步登陆态后的url(必须在configNav之前)
//    NSString *requestString = [self getRequestWithUrlSting:_baseURLStr json:_json];
//    DEBUGG(@"open webview -> %@", requestString);
//    _requestURL = [NSURL URLWithString:requestString];
    
    //nav配置
    [self configNav];
    
    //webview
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    _webView.scrollView.backgroundColor = NUI_HELPER.appBackgroundColor;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    //DZN,空数据显示
    _webView.scrollView.emptyDataSetSource = self;
    _webView.scrollView.emptyDataSetDelegate = self;
    [self.view addSubview:_webView];
    
    //设置无网络显示的视图
//    [self configNoNetworkView];
    
    if (_runJS)
    {
        JSClient *jsClient = [[JSClient alloc] initWithDelegate:self];
        //TODO 使用了loadPlugin 会导致controll 无法dealloc. 有待细查
        [_webView loadPlugin:jsClient namespace:@"client"];
    }
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(MAIN_BOUNDS), 0)];
    _progressView.nuiClass = @"WebProgressView";
    [self.view addSubview:_progressView];
    [self addObserver];
    
    //webview加载url
    [self inner_loadRequest];
}

- (void)addBarCloseButtonItem
{
    if (_hasCloseButtonItem) {
        
        return;
    }
    _hasCloseButtonItem = YES;
    NSArray *items = self.navigationItem.leftBarButtonItems;
    
    if (items) {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [closeButton addTarget:self action:@selector(closeAllAction:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage imageNamed:@"ic_cancel_x"] forState:UIControlStateNormal];
        
        
        UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:closeButton ];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:items];
        [array addObject:navBtnItem];
        self.navigationItem.leftBarButtonItems = array;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)updateProgress:(CGFloat)progress
{
    if (progress == 1 || progress == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        [self.progressView setProgress:progress animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
-(NSString *)getRequestWithUrlSting:(NSString*)urlString json:(NSDictionary*)json
{
    DEBUGG(@"%@ %s %@ %@", self.class, __FUNCTION__,urlString, json);
    NSString *platform = [NSString stringWithFormat:@"&%@=%d",kPlatformTypeKey,kPlatformTypeValue];
    NSString *appVersion = [[KSVersionMgr sharedInstance] getVersionName];
    NSString *version = [NSString stringWithFormat:@"&%@=%@",kAppVersionsKey,appVersion];
    NSString *channels = [NSString stringWithFormat:@"&%@=%@",kAppChannelsKey,kChannelVID];
    
    NSString *appId = [NSString stringWithFormat:@"app=%d", 1];
    NSString *imei = USER_SESSIONID;
    NSMutableString *requestString = [NSMutableString string];
    //9999指的是从活动页过来的，需要在登录之后刷新web页
    //@author semny  判断是否需要同步登陆态
    if (_syncSessionFlag)
    {
        NSString *encodeStr = [urlString stringByAddingPercentEncodingForFormData:YES];
//        NSString *imei = USER_SESSIONID;
        NSString *formatUrlStr = [NSString stringWithFormat:@"%@?app=1&url=%@&imei=%@&id=%ld",KSyncSession,encodeStr,imei,(long)0];
        [requestString appendString:formatUrlStr];
    }
    else
    {
        if (urlString && urlString.length > 0)
        {
            [requestString appendString:urlString];
        }
    }
    
    if ([requestString rangeOfString:appId].location == NSNotFound)
    {
        [requestString appendFormat:@"%@%@", [requestString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&", appId];
    }
    
    if (imei)
    {
        [requestString appendFormat:@"&imei=%@", imei];
    }
    
    for (NSString *key in json.allKeys)
    {
        if (!([key isEqualToString:kShareStatus] ||
              [key isEqualToString:kShareTitle]||
              [key isEqualToString:kShareURL]||
              [key isEqualToString:kShareImage]||
              [key isEqualToString:kShareContent]
              ))
        {
            [requestString appendFormat:@"&%@=%@", key, json[key]];
        }
    }
    
    [requestString appendString:platform];
    [requestString appendString:version];
    [requestString appendString:channels];
    
    if ([json[@"shareStatus"] isEqual:(@YES)])
    {
        if(self.webShare)
        {
            self.webShare[kShareTitle] = json[kShareTitle];
            self.webShare[kShareURL] = json[kShareURL];
            self.webShare[kShareImage] = json[kShareImage];
            self.webShare[kShareContent] = json[kShareContent];
        }
        _isNeedShare = YES;
    }
    //_url = [NSURL URLWithString:(NSString*)requestString];
    
    NSString *tempStr = nil;
    if (requestString && requestString.length > 0)
    {
        tempStr = [requestString copy];
    }
    return tempStr;
}
 */

-(void)addObserver
{
    // KVO
    @WeakObj(self);
    [RACObserve(_webView, estimatedProgress) subscribeNext:^(NSNumber *progress) {
        // 登录状态发生了变化
        [weakself updateProgress:progress.doubleValue];
        
    }];
    
    [[NOTIFY_CENTER rac_addObserverForName:KLoginStatusNotification object:nil] subscribeNext:^(id x) {
        DEBUGG(@"%@ %s %@", weakself.class, __FUNCTION__, x);
        //需要登录
        if (weakself.needLogin)
        {
            [weakself setNeedLogin:![USER_MGR isLogin]];
        }
        
        //登录态该表的时候需要刷新requestURL，主要是imei等参数需要传进去
//        NSString *requestString = [weakself getRequestWithUrlSting:weakself.baseURLStr json:weakself.json];
//        weakself.requestURL = [NSURL URLWithString:requestString];
        
        //解析url字符串
        NSString *requestString = [weakself getRequestURLString];
        weakself.requestURL = [NSURL URLWithString:requestString];
        //刷新
        [weakself reloadRequest];
        //返回标志
        weakself.isBackFlag = YES;
    }];
}

- (NSString *)getRequestURLString
{
    //解析url字符串
    NSString *query = self.requestURL.query;
    NSString *urlStr = self.requestURL.absoluteString;
    if (urlStr && query && query.length > 0 && [query containsString:kHeadKey])
    {
        NSArray *subUrl = [urlStr componentsSeparatedByString:@"?"];
        if (subUrl.count > 0)
        {
            urlStr = subUrl.firstObject;
        }
        else
        {
            return urlStr;
        }
        
        //处理url刷新url参数
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.requestURL resolvingAgainstBaseURL:NO];
        NSArray *array = urlComponents.queryItems;
        NSString *headStr = [self valueForKey:kHeadKey fromQueryItems:array];
        if ([headStr isKindOfClass:[NSString class]] && headStr.length > 0)
        {
            //head参数
            headStr = [headStr URLDecodingString];
            NSDictionary *headDict = [headStr objectFromJSONString];
            NSString *tradeId = headDict[kMethodKey];
            NSNumber *seqNoNum = headDict[kSeqNoKey];
            
            //body参数
            NSString *bodyStr = [self valueForKey:kBodyKey fromQueryItems:array];
            bodyStr = [bodyStr URLDecodingString];
            NSDictionary *bodyDict = [bodyStr objectFromJSONString];
            urlStr = [KSRequestBL createGetRequestURLWithURL:urlStr tradeId:tradeId seqNo:seqNoNum.longLongValue data:bodyDict error:nil];
        }
    }
    return urlStr;
}

- (NSString *)valueForKey:(NSString *)key fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}

#pragma mark - 视图加载
- (void)configNav
{
    self.title = self.webTitle;
    //分享按钮
    if (self.isNeedShare)
    {
        [self setNavRightButtonByImage:@"ic_share" selectedImageName:@"ic_share" navBtnAction:@selector(shareAction)];
    }
    else
    {
        //空白按钮
        [self setNavRightButtonByImage:@"" selectedImageName:@"" navBtnAction:nil];
    }
}

/**
 *  @author semny
 *
 *  配置无网络视图
 */
- (void)configNoNetworkView
{
    //包含的视图
    UIControl *control = [[UIControl alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:control];
    @WeakObj(self);
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view.mas_top);
        make.bottom.equalTo(weakself.view.mas_bottom);
        make.leading.equalTo(weakself.view.mas_leading);
        make.trailing.equalTo(weakself.view.mas_trailing);
    }];
    
    //无网络图标
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *webNoNetworkImg = [UIImage imageNamed:@"web_no_network"];
    imageView.image = webNoNetworkImg;
    CGFloat iconW = webNoNetworkImg.size.width;
    CGFloat iconH = webNoNetworkImg.size.height;
    imageView.frame = CGRectMake(0.0f, 0.0f, iconW, iconH);
    [control addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(control);
        make.height.equalTo(@(iconH));
        make.width.equalTo(@(iconW));
    }];
//    self.noNetworkView = control;
    //设置为隐藏
    [control setHidden:YES];
    [control addTarget:self action:@selector(reloadWebview) forControlEvents:UIControlEventTouchUpInside];
    
    
//    [self.webView ];
}

#pragma mark - 内部方法

- (void)setUrl:(NSURL *)url
{
    _url = url;
//    _baseURLStr = url.absoluteString;
    _requestURL = url;
    //如果url不为空，则将htmlString文件地址置为空
    if (url)
    {
        _HTMLString = nil;
    }
}

- (void)setHTMLString:(NSString *)HTMLString
{
    _HTMLString = HTMLString;
    //如果HTMLString不为空，则将url相关的远程web文件地址置为空
    if (HTMLString && HTMLString.length > 0)
    {
        _url = nil;
//        _baseURLStr = nil;
        _requestURL = nil;
    }
}

//load 本地缓存默认页
- (void)inner_loadDefault
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webView loadHTMLString:htmlString baseURL:nil];
    [_webView reload];
    [_webView.scrollView reloadEmptyDataSet];
}

- (void)inner_loadRequest
{
    DEBUGG(@"%@ %s 111", self.class, __FUNCTION__);
    if (!self.webView)
    {
        return;
    }
    
    //判断是否需要登录
    if(self.needLogin && ![USER_MGR isLogin])
    {
        //直接显示空页面
//        [self reloadEmptyView];
        [self inner_loadDefault];
        return;
    }
    [self.webView reload];
    
    DEBUGG(@"%@ %s 222", self.class, __FUNCTION__);
    if (self.requestURL)
    {
        //URL网页加载
        [self reloadRequest];
    }
    else if(self.HTMLString && self.HTMLString.length > 0)
    {
        //本地html加载
        [self reloadHTML];
    }
}

/**
 *  @author semny
 *
 *  重新加载web请求(刷新)
 */
- (void)reloadRequest
{
    DEBUGG(@"%@ %s 111", self.class, __FUNCTION__);
    if (self.requestURL && self.webView)
    {
        DEBUGG(@"%@ %s 222", self.class, __FUNCTION__);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL];
        [request setValue:@"text/html;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//        [request setValue:@"application/pdf" forHTTPHeaderField:@"Content-Type"];
        [self.webView loadRequest:request];
    }
}

/**
 *  @author semny
 *
 *  重新加载web请求(刷新)
 */
- (void)reloadHTML
{
    if (self.HTMLString && self.webView)
    {
        [self.webView loadHTMLString:self.HTMLString baseURL:nil];
    }
}

- (void)setNeedLogin:(BOOL)needLogin
{
    DEBUGG(@"%@ %s 111", self.class, __FUNCTION__);
    _needLogin = needLogin;
    if (_needLogin && ![USER_MGR isLogin])
    {
        DEBUGG(@"%@ %s 222", self.class, __FUNCTION__);
        self.emptyLoginView = ViewFromNib(@"EmptyLoginView", 0);
        @WeakObj(self);
        [[_emptyLoginView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [USER_MGR judgeLoginForVC:weakself];
        }];
        
    }else{
        DEBUGG(@"%@ %s 333", self.class, __FUNCTION__);
        self.emptyLoginView = nil;
    }
    DEBUGG(@"%@ %s 555", self.class, __FUNCTION__);
    [self reloadEmptyView];
}

#pragma mark - 网络错误处理
-(void)reloadEmptyView
{
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    //    [self.noNetworkView setHidden:NO];
    [self.webView.scrollView reloadEmptyDataSet];
}

/**
 *  @author semny
 *
 *  重新刷新加载web数据
 */
- (void)reloadWebview
{
    //隐藏无网络视图
//    [self.noNetworkView setHidden:YES];
    
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    //刷新数据
    [self reloadRequest];
}

#pragma mark -  DZNEmptyDataSet

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    UIImage *webNoNetworkImg = [UIImage imageNamed:@"web_no_network"];
    return webNoNetworkImg;
}


- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    DEBUGG(@"%@ %s _emptyLoginView: %@, scrollView: %@", self.class, __FUNCTION__, _emptyLoginView, scrollView);
    if (_needLogin && ![USER_MGR isLogin])
    {
        return _emptyLoginView;
    }
    
//    if (_needLogin) {
//        DEBUGG(@"%@ %s _emptyLoginView: %@, scrollView: %@", self.class, __FUNCTION__, _emptyLoginView, scrollView);
//        return _emptyLoginView;
//    }
    return nil;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    //需要登录并且未登录
    if (_needLogin && ![USER_MGR isLogin])
    {
        return;
    }
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    [self reloadWebview];
    
//    if (!_needLogin) {
//        DEBUGG(@"%@ %s", self.class, __FUNCTION__);
//        [self reloadWebview];
//    }
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    DEBUGG(@"%@ %s 111", self.class, __FUNCTION__);
    if (_needLogin && ![USER_MGR isLogin])
    {
        return YES;
    }
    DEBUGG(@"%@ %s 222", self.class, __FUNCTION__);
    return self.failedLoading;
}

#pragma mark - WKWebView Delegate

// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    DEBUGG(@"%@ %s", self.class, __FUNCTION__);
    //load失败
    self.failedLoading = NO;
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 类似 UIWebView 的 －webViewDidFinishLoad:
    if (webView.title.length > 0) {
        self.title = webView.title;
    }
    _failedLoading = NO;
    DEBUGG(@"%@ %s %@", self.class, __FUNCTION__,  webView.URL);
    //加载完成刷新
    [self reloadEmptyView];
}

/**
 *  @author semny
 *
 *  跳转逻辑很奇怪 [KSWebVC webView:didFailNavigation:withError:] http://mertest.chinapnr.com/muser/publicRequests Error Domain=NSURLErrorDomain Code=-999 "(null)" UserInfo={NSErrorFailingURLKey=http://mertest.chinapnr.com/muser/publicRequests, _WKRecoveryAttempterErrorKey=<WKReloadFrameErrorRecoveryAttempter: 0x131d87550>, NSErrorFailingURLStringKey=http://mertest.chinapnr.com/muser/publicRequests}
 [;[fg0,0,255;2016-09-27 18:21:29:055 kaisafax[3760:280434] KSOwnerLoanVC -[KSWebVC reloadEmptyView]
 */
//- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
//{
//    DEBUGG(@"%@ %s %@ %@", self.class, __FUNCTION__,  webView.URL, error);
//    //load失败
//    self.failedLoading = YES;
//    //网络错误显示
//    [self reloadEmptyView];
//}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    DEBUGG(@"%s, %@",__FUNCTION__,  webView.URL);
//    NSInteger errorCode = error.code;
//    //判断网络错误
//    if(errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorCannotConnectToHost || errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorNetworkConnectionLost)
//    {
//        //网络错误显示
//        [self handleNoNetwork];
//    }
    if (!error)
    {
        return;
    }
    
    DEBUGG(@"%@ %s %@ %@", self.class, __FUNCTION__,  webView.URL, error);
    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled)
    {
        return;
    }
    
    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    // Error Domain=WebKitErrorDomain Code=102 "帧框加载已中断"
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
    {
        return;
    }
    
    //load失败
    self.failedLoading = YES;
    //网络错误显示
    [self reloadEmptyView];
}

// 接收到服务器跳转请求之后调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    INFO(@"%s -- %@ %@",__FUNCTION__,navigationAction,webView.URL);
    NSString *absoluteString = navigationAction.request.URL.absoluteString;
    
    WKFrameInfo *targetFrame = navigationAction.targetFrame;
    if (!targetFrame &&([absoluteString containsString:kProtocolStr] ||
                        [absoluteString containsString:kPdfFileStr] ))
    {
    
        //仅为测试
//        NSString *urlStr = @"https://testfspublic.kaisafax.com/kaisaFile/2016/10/9/1463724836658728960INSoNb.pdf";
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [webView loadRequest:/*request*/navigationAction.request];
    }
    //    else if (!targetFrame.isMainFrame)
    //    {
    //        //点击打开新页面，然后在这个协议方法里，navigationAction.request 竟然是空的！request的URL是空的！
    //        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    //    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    DEBUGG(@"%@ %s %@ %@", self.class, __FUNCTION__,  webView.URL, navigationAction);
    WKFrameInfo *targetFrame = navigationAction.targetFrame;
    if (!targetFrame.isMainFrame)
    {
        //如果 targetFrame 的 mainFrame 属性为NO，表明这个 WKNavigationAction 将会新开一个页面。
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void (^)())completionHandler;
// 从web界面中接收到一个脚本时调用
//WKScriptMessageHandler 这个协议中包含一个必须实现的方法，这个方法是提高App与web端交互的关键，它可以直接将接收到的JS脚本转为OC或Swift对象
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

#pragma mark - 返回时一级级返回

- (void)closeAllAction:(id)sender
{
    self.isBackFlag = NO;
    [super leftButtonAction:sender];
    [self backAndClearAction:sender];
}



-(void)leftButtonAction:(id)sender
{
    INFO(@"%@ \n ",self.webView.backForwardList.backList);
    
    NSInteger count = self.webView.backForwardList.backList.count;
    
    if (self.webView.canGoBack)
    {
        if (self.isBackFlag && count == 1)
        {
            self.isBackFlag = NO;
            [super leftButtonAction:sender];
            [self backAndClearAction:sender];
            return;
        }
        //TODO jjyo
        //当历史记录大于2时..添加一个关闭按钮
//        if (count > 1) {
//            [self addBarCloseButtonItem];
//        }
        [self.webView goBack];
    }
    else
    {
        [super leftButtonAction:sender];
        [self backAndClearAction:sender];
    }
}

- (void)backAndClearAction:(id)sender
{
    DEBUGG(@"%@ %s %@", self.class, __FUNCTION__,  _webView.URL);
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    _webView = nil;
    self.progressView = nil;
    self.compareStr = nil;
    self.webShare = nil;
//    self.jsClient = nil;
//    self.noNetworkView = nil;
    self.requestURL = nil;
//    self.baseURLStr = nil;
    //外面的
    self.webTitle = nil;
//    self.urlString = nil;
    self.HTMLString = nil;
    self.json = nil;
    self.url = nil;
}

#pragma mark - JSClient Delegate

- (void)startPage:(NSString *)jsonString
{
    NSDictionary *json = [jsonString objectFromJSONString];
    INFO(@"%@",json);
    

//    if([_compareStr isEqualToString:jsonString])
//    {
//        return;
//    }
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        WebParseManager *mgr = [WebParseManager sharedInstance];
        NSDictionary *dict = [mgr parse:jsonString];
        NSDictionary *mapList = mgr.parseDict;
        
        BOOL needLogin = [dict[kLogin] boolValue];
        NSString *resultName = dict[kResult];
        NSString *amountStr = nil;
        NSString *actionStr = dict[kAction];
        BOOL willClose = [dict[@"close"] boolValue];
        NSDictionary *data = dict[@"data"];
        //已经剥离到外层
        amountStr = dict[kAmount];
        
        
        //判断是否需要登录
        if (needLogin && ![USER_MGR isLogin])
        {
            BOOL isLogin = [USER_MGR judgeLoginForVC:weakself];
            if (!isLogin)
            {
                //未登录
                return;
            }
            //登录了进行其他页面跳转
            [weakself toOriginPageAccrodingtoControllerName:resultName index:0];
        }
        
        //只是开户而已
        NSString *actionResultName = dict[kName];
        if (actionResultName && actionResultName.length > 0)
        {
            KSOpenAccountResultVC *resultVC = [[KSOpenAccountResultVC alloc]init];
            resultVC.type = weakself.type;
            resultVC.name = actionResultName;
            [weakself.navigationController pushViewController:resultVC animated:YES];
            return;
        }
        
        //行为代码，中文的 充值，提现，投标
        if (actionStr && actionStr.length > 0)
        {
            NSString *key = actionStr;
            NSString *mapVC = mapList[key];
            if ([mapVC isEqualToString:@"KSRechargeResultVC"])
            {
                //充值
                KSRechargeResultVC *sucVc = [[KSRechargeResultVC alloc]init];
                sucVc.result = resultName;
                sucVc.amount = amountStr;
                sucVc.type = weakself.type;
                if([resultName isEqualToString:@"false"])
                {
                    sucVc.code = dict[kCode];
                }
                
                //判断充值类型
                NSNumber *actionFlagNum = dict[kActionFlag];
                NSInteger actionFlag = 0;
                if (actionFlagNum)
                {
                    actionFlag = actionFlagNum.integerValue;
                }
                sucVc.actionFlag = actionFlag;
                
                //页面跳转
                NSArray *vcArray = weakself.navigationController.viewControllers;
                NSInteger index = [vcArray indexOfObject:weakself];
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:vcArray];
                NSInteger count = 0;
                if ((count=tempArray.count) > 1 && index < count)
                {
                    [tempArray removeObjectsInRange:NSMakeRange(index, count-index)];
                }
                [tempArray addObject:sucVc];
                sucVc.hidesBottomBarWhenPushed = YES;
                [weakself.navigationController setViewControllers:tempArray animated:YES];
            }
            else if([mapVC isEqualToString:@"KSDepositResultVC"])
            {
                //提现
                KSDepositResultVC *sucVc = [[KSDepositResultVC alloc]init];
                sucVc.result = resultName;
                sucVc.amount = amountStr;
                sucVc.cashChl = dict[kcashchl];
                sucVc.type = weakself.type;
                NSArray *vcArray = weakself.navigationController.viewControllers;
                NSInteger index = [vcArray indexOfObject:weakself];
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:vcArray];
                NSInteger count = 0;
                if ((count=tempArray.count) > 1 && index < count)
                {
                    [tempArray removeObjectsInRange:NSMakeRange(index, count-index)];
                    //[tempArray removeObjectsInRange:NSMakeRange(1, tempArray.count-1)];
                }
                [tempArray addObject:sucVc];
                sucVc.hidesBottomBarWhenPushed = YES;
                [weakself.navigationController setViewControllers:tempArray animated:YES];
            }
            else if ([mapVC isEqualToString:@"KSBidResultVC"])
            {
                //投标
                KSBidResultVC *sucVc = [[KSBidResultVC alloc]init];
                sucVc.result = resultName;
                sucVc.amount = amountStr;
                sucVc.type = weakself.type;
                if([resultName isEqualToString:@"false"])
                {
                    sucVc.respCode = dict[kRespCode];
                    sucVc.respDesc = dict[kRespDesc];
                }
                NSArray *vcArray = weakself.navigationController.viewControllers;
                NSInteger index = [vcArray indexOfObject:weakself];
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:vcArray];
                NSInteger count = 0;
                if ((count=tempArray.count) > 1 && index < count)
                {
                    [tempArray removeObjectsInRange:NSMakeRange(index, count-index)];
                    //[tempArray removeObjectsInRange:NSMakeRange(1, tempArray.count-1)];
                }
                [tempArray addObject:sucVc];
                sucVc.hidesBottomBarWhenPushed = YES;
                [weakself.navigationController setViewControllers:tempArray animated:YES];
            }
        }
        else{
            if (willClose) {
                if (!data) {
                    NSDictionary *json = [jsonString objectFromJSONString];
                    data = [json objectForKey:@"data"];
                }
                
                if (data && _callback) {
                    _callback(data);
//                    return;
                }
                
                NSString *controlName = dict[kiOS];
//                if(data && [controlName isEqualToString:@"SXRecommendController"])
                if(controlName)
                {
                    [weakself toOriginPageAccrodingtoControllerName:controlName index:0];
                }
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            else
            {
                NSString *controlName = dict[kiOS];
                if(controlName)
                {
                    [weakself toOriginPageAccrodingtoControllerName:controlName index:0];
                }
            }
                
        }
        
        
    });
}

//在h5点击按钮跳转h5页面
/**
-(void)syncSession:(NSString *)sessionString
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[sessionString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *needToLogin = jsonDic[@"needToLogin"];
        NSString *jumpUrl = jsonDic[@"targetUrl"];
        NSString *imeiStr = USER_SESSIONID;
        NSString *covNeedToLogin = @"false";
        NSMutableString *mutStr = [[NSMutableString alloc]init];
        
        if ([needToLogin isEqual:@(YES)])
        {
            covNeedToLogin = @"true";
            if (![USER_MGR isLogin])
            {
                mutStr = nil;
                
                [USER_MGR judgeLoginForVC:weakself];
            }
            else
            {
                //拼接字符串
                NSString *imeiKeyValue = [NSString stringWithFormat:@"imei=%@&",imeiStr];
                [mutStr appendString:imeiKeyValue];
                NSString *sourceKeyValue = [NSString stringWithFormat:@"source=ios&"];
                [mutStr appendString:sourceKeyValue];
                [mutStr appendString:@"targetUrl="];
                NSString *urlKeyValue = [jumpUrl stringByAddingPercentEncodingForFormData:YES];
                [mutStr appendString:urlKeyValue];
                [mutStr appendString:@"&"];
                
                NSString *loginKeyValue = [NSString stringWithFormat:@"needToLogin=%@",covNeedToLogin];
                [mutStr appendString:loginKeyValue];
                
                [weakself.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:showInfo('%@')",(NSString*) mutStr] completionHandler:^(id _Nullable impl, NSError * _Nullable error) {
                   DEBUGG(@"%@",error);
                }];
                
            }
        }
    });
}
*/
//确定要去跳转的原生页面
-(void)toOriginPageAccrodingtoControllerName:(NSString*)controllerName index:(long)index
{
    WebParseManager *mgr = [WebParseManager sharedInstance];
    NSDictionary *mapList = mgr.parseDict;
    
    //广告启动进来的
    if (self.type == KSWebSourceTypeADAfterCheck || self.type == KSWebSourceTypeADStart)
    {
        //启动主界面
        [self dismissViewControllerAnimated:YES completion:^{
            [NOTIFY_CENTER postNotificationName:KAfterPageCloseAnimationNotificationKey object:nil userInfo:nil];
        }];
    }
    
    if([controllerName isEqualToString:@"SXTabBarController"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UITabBarController *tabbarVC = appDelegate.tabbarVC;
        if (!tabbarVC)
        {
            tabbarVC = [appDelegate startMainPage];
        }
        [tabbarVC setSelectedIndex:1];
        
        //回退到首页
        UIViewController *viewController = tabbarVC.selectedViewController;
        UINavigationController *nav = nil;
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            nav = (UINavigationController *)viewController;
        }
        [nav popToRootViewControllerAnimated:YES];
    }
    else if([controllerName isEqualToString:@"SXRecommendController"])
    {
        //发送刷新物业宝的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KOwnerAuthenticateSuccessNotificationKey object:nil];
        
        //切换到第一个
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UITabBarController *tabbarVC = appDelegate.tabbarVC;
        if (!tabbarVC)
        {
            tabbarVC = [appDelegate startMainPage];
        }
        [tabbarVC setSelectedIndex:0];
        
        //回退到首页
        UIViewController *viewController = tabbarVC.selectedViewController;
        UINavigationController *nav = nil;
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            nav = (UINavigationController *)viewController;
        }
        [nav popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSString *transfer = mapList[controllerName];
        if (transfer && transfer.length > 0)
        {
             Class controllerClass = NSClassFromString(transfer);
            if (controllerClass && [controllerClass isSubclassOfClass:[UIViewController class]])
            {
                if ([controllerClass isSubclassOfClass:[KSHomeVC class]])
                {
                    //判断是不是首页
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UITabBarController *tabbarVC = appDelegate.tabbarVC;
                    if (!tabbarVC)
                    {
                        tabbarVC = [appDelegate startMainPage];
                    }
                    [tabbarVC setSelectedIndex:0];
                }
                else
                {
                    [self.navigationController pushViewController:[[controllerClass alloc]init] animated:YES];
                }
            }
        }
    }
}

- (void)share:(NSString *)jsonString
{
//    NSDictionary *json = [jsonString objectFromJSONString];
//    INFO(@"%@",json);
}

#pragma mark - Data Action

//- (void)operation:(NSString *)jsonString
//{
//    // 视为返回了开户结果
//    if ([jsonString containsString:@"name:"])
//    {
//        KSOpenAccountResultVC *resultVC = [[KSOpenAccountResultVC alloc]init];
//        resultVC.type = self.type;
//        NSRange rangeAmount = [jsonString rangeOfString:@"name:" options:NSBackwardsSearch];
//        NSRange rangeBackcle = [jsonString rangeOfString:@"}" options:NSBackwardsSearch range:NSMakeRange(rangeAmount.location, jsonString.length- rangeAmount.location - 1)];
//        resultVC.name = [jsonString substringWithRange:NSMakeRange(rangeAmount.location+5, rangeBackcle.location-rangeAmount.location-5)];
//        
//       DEBUGG(@"name:%@",resultVC.name);
//        
//        if([resultVC.name isEqualToString:@"开户失败"])
//            ;
//        //            [MBProgressHUD showError:@"开户失败" detail:nil];
//        else
//            [self.navigationController pushViewController:resultVC animated:YES];
//    }
//    
//    if([jsonString containsString:@"充值"])
//    {
//        KSRechargeResultVC *sucVc = [[KSRechargeResultVC alloc]init];
//        
//        //amount所在的位置
//        NSRange iosRange =  [jsonString rangeOfString:@"ios"];
//        NSRange resultRange = [jsonString rangeOfString:@"\"," options:NSBackwardsSearch];
//        sucVc.result = [jsonString substringWithRange:NSMakeRange(iosRange.location+6, resultRange.location-6-iosRange.location)];
//        
//        NSRange rangeAmount = [jsonString rangeOfString:@"amount:" options:NSBackwardsSearch];
//        NSRange rangeBackcle = [jsonString rangeOfString:@"}," options:NSBackwardsSearch];
//        sucVc.amount = [jsonString substringWithRange:NSMakeRange(rangeAmount.location+7, rangeBackcle.location-rangeAmount.location-7)];
//        
//        sucVc.type = self.type;
//        if([sucVc.result isEqualToString:@"false"])
//        {
//            //错误的code
//            NSRange code = [jsonString rangeOfString:@"code"];
//            sucVc.code = [jsonString substringWithRange:NSMakeRange(code.location+5, iosRange.location-code.location-5-1)];
//        }
//        
//        [self.navigationController pushViewController:sucVc animated:YES];
//    }
//}


#pragma mark - tools

- (void)closeSelf
{
    if (self.navigationController) {
        NSArray *array = self.navigationController.viewControllers;
        if (array.count > 1) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
            [newArray removeObject:self];
            if (newArray.count < array.count) {
                [self.navigationController setViewControllers:newArray];
            }
        }
    }
}

#pragma mark - 分享
-(void)shareAction
{
    if (!self.webShare)  return;

    //分享
    NSString *shareImgURLStr = self.webShare[kShareImage];
    NSURL *shareImgURL = nil;
    NSData *data = nil;
    if (shareImgURLStr && shareImgURLStr.length > 0)
    {
        shareImgURL = [NSURL URLWithString:shareImgURLStr];
        data = [NSData dataWithContentsOfURL:shareImgURL];
    }
    SocialService *socialService = [SocialService sharedInstance];
    socialService.platformArray = nil;
    [socialService presentShareDialogWithTitle:self.webShare[kShareTitle] text:self.webShare[kShareContent] image:data
                                      imageURL:shareImgURLStr URL:self.webShare[kShareURL] delegate:nil];
}

@end
