//
//  JXMCSUserManager.m
//

#import "JXMCSUserManager.h"

#import "JXMcsChatViewController.h"
#import "JXWebViewController.h"
#import "JXWorkgroupListController.h"

//#import "JXHistoricalVisitManager.h"

@interface JXMCSUserManager ()<JXClientDelegate>

@property(nonatomic, copy) JXUserActiveResponseBlock logoutResponseBlock;
@property(nonatomic, copy) JXUserActiveResponseBlock loginResponse;

@property(nonatomic, assign) BOOL isLogin;

// 评价列表显示
@property(nonatomic, strong) JXMcsEvaluation *evaluation;
// 快速提问列表
@property(nonatomic, strong) NSArray *quickQuestions;
// 未读消息数
@property(nonatomic, assign) NSInteger unreadMessageCount;

@property (nonatomic, strong) NSMutableArray *csDataSource;


@end

@implementation JXMCSUserManager

#pragma mark - public method

+ (instancetype)sharedInstance {
    static JXMCSUserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.isLogin = NO;
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [sClient.loginManager addDelegate:self];
        [sClient.mcsManager addDelegate:self];
        _unreadMessageCount = -1;
    }
    return self;
}

- (void)dealloc {
    [sClient.loginManager removeDelegate:self];
    [sClient.mcsManager removeDelegate:self];
}

// demo 使用随机生成的访客账号，可以根据需要使用自有账号
- (void)loginWithAppKey:(NSString *)appKey responseObject:(JXUserActiveResponseBlock)loginResponse {
    JXDebugAssert(appKey);
    self.loginResponse = loginResponse;
    JXError *error = [sClient registerSDKWithAppKey:appKey];
    if (error) {
        loginResponse(NO, error);
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:appKey forKey:kJXCachedAppKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __block NSString *mcsAccount = [self mcsAccountForApp:appKey];
    __block NSString *mcsPassword;

    void (^regCallback)(JXError *) = ^(JXError *error) {
        if (error) {
            if (error.errorCode == JXErrorTypeUsernameExist ||
                error.errorCode == JXErrorTypeUsernameLengthInvalid) {
                [self loginWithAppKey:appKey responseObject:loginResponse];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [sJXHUD showMessage:[error getLocalDescription] duration:1.6];
            });
        } else {
            [sClient.loginManager loginWithUserName:mcsAccount password:mcsPassword];
        }
    };
    // 账号没有缓存则重新生成
    if (!mcsAccount.length) {
        mcsAccount = [self generateMCSUsername];
        mcsPassword = [self mcsPasswordForAccount:mcsAccount];
        [sClient.loginManager registerWithUserName:mcsAccount
                                          password:mcsPassword
                                          callback:regCallback];
    } else {
        mcsPassword = [self mcsPasswordForAccount:mcsAccount];
        [sClient.loginManager loginWithUserName:mcsAccount password:mcsPassword];
    }
}

- (void)logoutWithResponseBlock:(JXUserActiveResponseBlock)logoutResponse {
    self.logoutResponseBlock = logoutResponse;
    [sJXHUD showMessageWithActivityIndicatorView:nil];
    [sClient.loginManager logout];
}

+ (void)GETWithApi:(NSString *)api
            params:(NSDictionary *)params
      withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableString *urlString = [NSMutableString stringWithString:url.absoluteString];
    if (params && params.count > 0) {
        [urlString appendString:@"?"];
        for (NSString *key in params.allKeys) {
            [urlString appendString:[NSString stringWithFormat:@"%@=%@&", key, params[key]]];
        }
        [urlString deleteCharactersInRange:NSMakeRange(urlString.length - 1, 1)];
    }
    urlString = (NSMutableString *)[urlString
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    [JXRestUtil sendRequest:request withCallback:callback];
}

+ (void)POSTWithApi:(NSString *)api
             params:(NSDictionary *)params
       withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        request.HTTPBody = data;
    }
    request.HTTPMethod = @"POST";
    [JXRestUtil sendRequest:request withCallback:callback];
}

+ (void)PUTWithApi:(NSString *)api
            params:(NSDictionary *)params
      withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        request.HTTPBody = data;
    }
    request.HTTPMethod = @"PUT";
    [JXRestUtil sendRequest:request withCallback:callback];
}

#pragma mark account

- (void)clearAccount {
    NSString *appkey = [[NSUserDefaults standardUserDefaults] objectForKey:kJXCachedAppKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:appkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveAccount:(NSString *)account {
    NSString *appkey = [[NSUserDefaults standardUserDefaults] objectForKey:kJXCachedAppKey];
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:appkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)mcsAccountForApp:(NSString *)appkey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:appkey];
}

- (NSString *)mcsPasswordForAccount:(NSString *)account {
    NSString *ret = [[NSUserDefaults standardUserDefaults] objectForKey:account];
    if (!ret.length) {
        ret = [self generateMCSPassword];
        [[NSUserDefaults standardUserDefaults] setObject:ret forKey:account];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return ret;
}

- (NSString *)generateMCSUsername {
    long currentTimeTamp = [[NSDate date] timeIntervalSince1970];
    NSString *usernameString = [NSString stringWithFormat:@"mcsios%ld", currentTimeTamp];
    NSString *usernameResult = [usernameString
            stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random_uniform(1000)]];
    return usernameResult;
}

- (NSString *)generateMCSPassword {
    int number = (arc4random() % 900000) + 100000;
    return [NSString stringWithFormat:@"%d", number];
}

#pragma mark - loginManagerDelegate

- (void)didLoginSuccess {
    //获取评价类型(登录完成请求一次)
    _evaluation = [sClient.mcsManager fetchEvaluationConfigSync];
    _quickQuestions = [sClient.mcsManager fetchQuickQuestionsSync];
    [self unreadMessageCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLogin = YES;
        self.loginResponse(YES, nil);
        [self saveAccount:[sClient.loginManager username]];
        [kDefaultNotificationCenter postNotificationName:kNotification_loginSucess object:nil];
    });
}

// 登陆失败，若出现账号冲突则重新生成登陆账号
- (void)didLoginFailureWithError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.errorCode == JXErrorTypeUserRemoved ||
            error.errorCode == JXErrorTypePasswordModified ||
            error.errorCode == JXErrorTypeLoginInvalidUsernameOrPassword ||
            error.errorCode == JXErrorTypeLoginUserNameNotExist) {
            [self clearAccount];
            NSString *appkey = [[NSUserDefaults standardUserDefaults] objectForKey:kJXCachedAppKey];
            [self loginWithAppKey:appkey responseObject:self.loginResponse];
            return;
        }
        self.loginResponse(NO, error);
    });
}

- (void)didLogoutSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLogin = NO;

        // FIXME: demo 清除历史商品信息
//        [[JXHistoricalVisitManager sharedInstance] clearHistory];
        _unreadMessageCount = -1;
        
        if (self.logoutResponseBlock) {
            self.logoutResponseBlock(YES, nil);
        }
    });
}

- (void)didConnectionChanged:(BOOL)isConnected withError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLogin = isConnected;
        if (!isConnected) {
            [kDefaultNotificationCenter postNotificationName:kNotification_disConnected object:nil];
        }
    });
}

// 被强制下线
- (void)didForceLogoutWithError:(JXError *)error {
    if (self.logoutResponseBlock) {
        self.logoutResponseBlock(NO, error);
    }
}

#pragma mark - JXMCSManagerDelegate

- (void)didReceiveAgentLeaveMessage:(NSDictionary *)info {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.unreadMessageCount++;
}

//// UI调用请求客服api
//- (void)requestCSForUI:(UINavigationController *)navC indexPath:(NSInteger)indexPath {
//    if (!navC) return;
//
//    JXWorkgroup *service = [sClient.mcsManager activeService];
//    UIViewController *nextVC;
//    if (service && service.status != JXMCSUserStatusInRobot) {
//        nextVC = [[JXMcsChatViewController alloc] initWithWorkgroup:service];
//    } else {
//        nextVC = [[JXWorkgroupListController alloc] init];
//        // FIXME: demo 发送商品信息
//        [[JXHistoricalVisitManager sharedInstance] setIsSendItem:YES];
//    }
//    nextVC.hidesBottomBarWhenPushed = YES;
//    [navC pushViewController:nextVC animated:IOSVersion > 8.0];
//}

// UI调用请求客服api
- (void)requestCSForUI:(UINavigationController *)navC indexPath:(NSInteger)indexPath {
    if (!navC) return;
    
    JXWorkgroup *service = [sClient.mcsManager activeService];
    __block UIViewController *nextVC;
    if (service && service.status != JXMCSUserStatusInRobot) {
        nextVC = [[JXMcsChatViewController alloc] initWithWorkgroup:service];
        nextVC.hidesBottomBarWhenPushed = YES;
        [navC pushViewController:nextVC animated:IOSVersion >= 8.0];
    } else {
        
        [sClient.mcsManager fetchCustomServicesWithCallback:^(id responseObject, JXError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    _csDataSource = responseObject;
                    NSUInteger count = _csDataSource.count;
                    if (count > 1) {
                        JXWorkgroupListController *wgList = [[JXWorkgroupListController alloc] init];
                        wgList.csDataSource = _csDataSource;
                        nextVC = wgList;
                        nextVC.hidesBottomBarWhenPushed = YES;
                        [navC pushViewController:nextVC animated:IOSVersion >= 8.0];
                        //                        return;
                    }
                    else if(count == 1)
                    {
                        nextVC = [[JXMcsChatViewController alloc] initWithWorkgroup:_csDataSource.firstObject];
                        nextVC.hidesBottomBarWhenPushed = YES;
                        [navC pushViewController:nextVC animated:IOSVersion >= 8.0];
                    }
                    else if (count == 0) {
                        sJXHUDMes(@"获取客服技能组列表为空", 1.f);
                        //                        [self popSelf];
                    }
                    //                    [self.tableView reloadData];
                } else {
                    sJXHUDMes(@"获取客服技能组列表失败", 1.f);
                    //                    [self popSelf];
                }
            });
        }];
        
    }
    
    
}
// UI加载在线留言
- (void)leaveMessageOnlineForUI:(UIViewController *)vc workgroup:(JXWorkgroup *)workgroup {
    NSString *urlString = [sClient.mcsManager leaveMessageURL:workgroup].absoluteString;
    JXWebViewController *webVC = [[JXWebViewController alloc] init];
    webVC.title = @"在线留言";
    webVC.netString = urlString;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];

    // FIXME: 设置navigationBar样式
    [nav.navigationBar setBackgroundImage:JXImage(@"basicNav") forBarMetrics:UIBarMetricsDefault];

    [vc presentViewController:nav animated:YES completion:nil];
}

- (NSInteger)unreadMessageCount {
    if (_unreadMessageCount >= 0) {
        return _unreadMessageCount;
    }
    NSString *api = [NSString stringWithFormat:@"visitor/msgbox/getUnreadCount?username=%@",
                                               [sClient.loginManager username]];
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    id response = nil;
    NSError *error = nil;
    [JXRestUtil sendSyncRequest:request withRes:&response error:&error];
    if (error || [response[@"code"] integerValue] != 200) {
        _unreadMessageCount = -1;
    } else {
        _unreadMessageCount = [response[@"receipt"][@"unreadCount"] integerValue];
    }
    return _unreadMessageCount;
}

- (BOOL)setAllMessageRead {
    if (self.unreadMessageCount == 0) return YES;

    NSDictionary *params = @{ @"username" : [sClient.loginManager username] };
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:@"visitor/msgbox/markAllAsRead"];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    id response = nil;
    NSError *error = nil;
    [JXRestUtil sendSyncRequest:request withRes:&response error:&error];
    if ([response[@"code"] integerValue] == 200) {
        self.unreadMessageCount = 0;
        return YES;
    } else {
        return NO;
    }
}

@end
