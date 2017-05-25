//
//  KSWebVC.h
//  kaisafax
//
//  Created by semny on 16/7/6.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import <WebKit/WebKit.h>

//typedef NS_ENUM(NSUInteger,KSWebSourceType)
//{
//    KSWebSourceTypeRegister=0,     //从注册入口来的
//    KSWebSourceTypeOther=1,      //从账户中心来的
//};

#define kProtocolStr   @"contract/template"
#define kPdfFileStr    @"pdf/"


@interface KSWebVC : KSNVBackVC

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, copy) NSString *webTitle;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *HTMLString;
@property (nonatomic,assign, readonly) KSWebSourceType type;
@property (nonatomic, assign, readonly) BOOL runJS;

//这个标志有点奇怪，属性作用不单一
@property (nonatomic, assign) BOOL needLogin;

//是否需要同步登陆态
@property (nonatomic, assign) BOOL syncSessionFlag;


@property (nonatomic, copy) void (^callback)(NSDictionary *data);



//@property (nonatomic,copy) NSString *urlString;

+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title;
+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type;
//仅仅为返回了结果的页面，如投标，提现，充值，开户等
+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title type:(NSInteger)type;
+ (instancetype)pushInController:(UINavigationController *)nav urlString:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type runJS:(BOOL)js;


- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title;

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title type:(NSInteger)type;

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type;

- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title params:(NSDictionary *)json type:(NSInteger)type  runJS:(BOOL)js;

/**
 *  @author semny
 *
 *  重新加载web请求(刷新)
 */
- (void)reloadRequest;

/**
 *  @author semny
 *
 *  重新加载web请求(刷新)
 */
- (void)reloadHTML;


@end
