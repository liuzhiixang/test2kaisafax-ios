//
//  KSNewWebVC.h
//  kaisafax
//
//  Created by semny on 17/4/26.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import <WebKit/WebKit.h>

#ifndef KS_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define KS_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define KS_REQUIRES_SUPER
#endif
#endif

NS_ASSUME_NONNULL_BEGIN
@class KSNewWebVC;

typedef NS_ENUM(NSInteger, KSNewWebVCNavigationType) {
    /// Navigation bar items.
    KSNewWebVCNavigationBarItem,
    /// Tool bar items.
    KSNewWebVCNavigationToolItem
};

@protocol KSNewWebVCDelegate <NSObject>
@optional
/// Called when web view will go back.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillGoBack:(KSNewWebVC *)webViewController;
/// Called when web view will go forward.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillGoForward:(KSNewWebVC *)webViewController;
/// Called when web view will reload.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillReload:(KSNewWebVC *)webViewController;
/// Called when web view will stop load.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillStop:(KSNewWebVC *)webViewController;
/// Called when web view did start loading.
///
/// @param webViewController a web view controller.
- (void)webViewControllerDidStartLoad:(KSNewWebVC *)webViewController;
/// Called when web view did finish loading.
///
/// @param webViewController a web view controller.
- (void)webViewControllerDidFinishLoad:(KSNewWebVC *)webViewController;
/// Called when web viw did fail loading.
///
/// @param webViewController a web view controller.
///
/// @param error a failed loading error.
- (void)webViewController:(KSNewWebVC *)webViewController didFailLoadWithError:(NSError *)error;
@end

@interface KSNewWebVC : KSNVBackVC <WKUIDelegate, WKNavigationDelegate>
{
@protected
    WKWebView *_webView;
    NSURL *_URL;
}
/// Delegate.
@property(assign, nonatomic) id<KSNewWebVCDelegate>delegate;
/// WebKit web view.
@property(readonly, nonatomic) WKWebView *webView;
/// Time out internal.
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
/// Cache policy.
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
/// Url.
@property(readonly, nonatomic) NSURL *URL;
/// Shows tool bar.
@property(assign, nonatomic) BOOL showsToolBar;
/// Shows showsBackgroundLabel default YES.
@property(assign, nonatomic) BOOL showsBackgroundLabel;
/// Navigation type.
@property(assign, nonatomic) KSNewWebVCNavigationType navigationType;
/// Get a instance of `KSNewWebVC` by a url string.
///
/// @param urlString a string of url to be loaded.
///
/// @return a instance `KSNewWebVC`.
- (instancetype)initWithAddress:(NSString*)urlString;
/// Get a instance of `KSNewWebVC` by a url.
///
/// @param URL a URL to be loaded.
///
/// @return a instance of `KSNewWebVC`.
- (instancetype)initWithURL:(NSURL*)URL;
/// Get a instance of `KSNewWebVC` by a url request.
///
/// @param request a URL request to be loaded.
///
/// @return a instance of `KSNewWebVC`.
- (instancetype)initWithRequest:(NSURLRequest *)request;

/// Get a instance of `KSNewWebVC` by a url and configuration of web view.
///
/// @param URL a URL to be loaded.
/// @param configuration configuration instance of WKWebViewConfiguration to create web view.
///
/// @return a instance of `KSNewWebVC`.
- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration;
/// Get a instance of `KSNewWebVC` by a request and configuration of web view.
///
/// @param request a URL request to be loaded.
/// @param configuration configuration instance of WKWebViewConfiguration to create web view.
///
/// @return a instance of `KSNewWebVC`.
- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration;

/// Get a instance of `KSNewWebVC` by a HTML string and a base URL.
///
/// @param HTMLString a HTML string object.
/// @param baseURL a baseURL to be loaded.
///
/// @return a instance of `KSNewWebVC`.
- (instancetype)initWithHTMLString:(NSString*)HTMLString baseURL:(NSURL*)baseURL;
/// Load a new url.
///
/// @param URL a new url.
- (void)loadURL:(NSURL*)URL;
/// Load a new html string.
///
/// @param HTMLString a encoded html string.
/// @param baseURL base url of bundle.
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL;
@end

@interface KSNewWebVC (SubclassingHooks)
/// Called when web view will go back. Do not call this directly. Same to the bottom methods.
/// @discussion 使用的时候需要子类化，并且调用super的方法!切记！！！
///
- (void)willGoBack KS_REQUIRES_SUPER;
/// Called when web view will go forward. Do not call this directly.
///
- (void)willGoForward KS_REQUIRES_SUPER;
/// Called when web view will reload. Do not call this directly.
///
- (void)willReload KS_REQUIRES_SUPER;
/// Called when web view will stop load. Do not call this directly.
///
- (void)willStop KS_REQUIRES_SUPER;
/// Called when web view did start loading. Do not call this directly.
///
- (void)didStartLoad KS_REQUIRES_SUPER;
/// Called when web view did finish loading. Do not call this directly.
///
- (void)didFinishLoad KS_REQUIRES_SUPER;
/// Called when web viw did fail loading. Do not call this directly.
///
/// @param error a failed loading error.
- (void)didFailLoadWithError:(NSError *)error KS_REQUIRES_SUPER;
@end

/**
 WebCache clearing.
 */
@interface KSNewWebVC (WebCache)
/// Clear cache data of web view.
///
/// @param completion completion block.
+ (void)clearWebCacheCompletion:(dispatch_block_t)completion;
@end

/**
 Accessibility to background label.
 */
@interface KSNewWebVC (BackgroundLabel)
/// Description label of web content's info.
///
@property(readonly, nonatomic) UILabel *descriptionLabel;
@end

NS_ASSUME_NONNULL_END
