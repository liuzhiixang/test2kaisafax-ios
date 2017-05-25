//
//  KSPDFViewVC.m
//  kaisafax
//
//  Created by okline.kwan on 16/12/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPDFViewVC.h"
#import "KSVersionMgr.h"

@interface KSPDFViewVC ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation KSPDFViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *platform = [NSString stringWithFormat:@"&%@=%d",kPlatformTypeKey,kPlatformTypeValue];
    NSString *version = [NSString stringWithFormat:@"&%@=%@",kAppVersionsKey,[[KSVersionMgr sharedInstance] getVersionName]];
    NSString *channels = [NSString stringWithFormat:@"&%@=%@",kAppChannelsKey,kChannelVID];
    
    NSString *appId = [NSString stringWithFormat:@"app=%@", @"1"];
    NSString *imei = USER_SESSIONID;
    
    NSMutableString *requestString = [NSMutableString stringWithString:_filePath];
    if ([requestString rangeOfString:appId].location == NSNotFound)
    {
        [requestString appendFormat:@"%@%@", [requestString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&", appId];
    }
    if (imei)
    {
        [requestString appendFormat:@"&imei=%@", imei];
    }
    [requestString appendString:platform];
    [requestString appendString:version];
    [requestString appendString:channels];
    
    
    INFO(@"KSPDFViewVC=>%@", requestString);
    
    NSString *tempStr = [self URLEncodedString:requestString];
    NSURL *url = [NSURL URLWithString:tempStr];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    _webView.scrollView.backgroundColor = NUI_HELPER.appBackgroundColor;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self.view addSubview:_webView];
    
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(MAIN_BOUNDS), 0)];
    _progressView.nuiClass = @"WebProgressView";
    [self.view addSubview:_progressView];
    [self addObserver];
    
    [_webView loadRequest:request];
    
    
}

-(void)addObserver
{
    // KVO
    @WeakObj(self);
    [RACObserve(_webView, estimatedProgress) subscribeNext:^(NSNumber *progress) {
        // 登录状态发生了变化
        [weakself updateProgress:progress.doubleValue];
        
    }];
    
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

- (NSString *)URLEncodedString:(NSString *)string
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)string,
                                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                                    NULL,
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}

#pragma mark - WKWebView Delegate

// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 类似 UIWebView 的 －webViewDidFinishLoad:
    if (webView.title.length > 0) {
        self.title = webView.title;
    }
    
}


// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    if (!error)
    {
        return;
    }
    
    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled)
    {
        return;
    }
    
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
    {
        return;
    }
    
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
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

@end
