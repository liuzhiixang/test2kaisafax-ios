//
//  JXWebViewController.m
//

#import "JXHUD.h"
#import "JXWebViewController.h"

@interface JXWebViewController ()<UIWebViewDelegate>
@property(nonatomic, strong) UIWebView *webView;
@end

@implementation JXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDefaultLeftButtonItem];
    if (self.title.length == 0) {
        self.title = self.netString;
    }
    NSString *netString = [NSString stringWithFormat:@"%@", self.netString];
    NSURL *url = [NSURL URLWithString:netString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    self.webView = webView;
    self.webView.delegate = self;
    [webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showMessageWithActivityIndicator:@"正在加载"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHUD];
    if (self.webView) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"window.close = function () { "
                                                             @"location.href = "
                                                             @"'jiaxin://window.close'; }"];
    }
}

- (BOOL)webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
                    navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    NSString *scheme = @"jiaxin://";
    if ([urlString hasPrefix:scheme]) {
        NSString *function = [urlString substringFromIndex:scheme.length];
        if ([function isEqualToString:@"window.close"]) {
            [self popSelf];
        }
        return NO;
    }
    return YES;
}

@end
