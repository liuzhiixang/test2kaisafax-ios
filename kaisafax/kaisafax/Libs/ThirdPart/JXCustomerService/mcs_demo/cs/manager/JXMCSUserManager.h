//
//  JXMCSUserManager.h
//

#import <Foundation/Foundation.h>
#import "JXRestUtil.h"

#define kNotification_loginSucess @"KNotification_loginSucess"
#define kNotification_logoutUser @"kNotification_logoutUser"
#define kNotification_disConnected @"kNotification_disConnected"

typedef void (^JXUserActiveResponseBlock)(BOOL success, id response);

@interface JXMCSUserManager : NSObject

+ (instancetype)sharedInstance;

- (JXMcsEvaluation *)evaluation;

- (NSArray *)quickQuestions;

- (BOOL)isLogin;

- (void)loginWithAppKey:(NSString *)appKey responseObject:(JXUserActiveResponseBlock)loginResponse;

- (void)logoutWithResponseBlock:(JXUserActiveResponseBlock)logoutResponse;

- (void)requestCSForUI:(UINavigationController *)navC indexPath:(NSInteger)indexPath;

- (void)leaveMessageOnlineForUI:(UIViewController *)vc workgroup:(JXWorkgroup *)workgroup;

@property (nonatomic, assign, readonly) NSInteger unreadMessageCount;

@property (nonatomic, assign, readwrite) BOOL isInService;

- (BOOL)setAllMessageRead; // 设置所有离线消息已读

#pragma mark - rest请求接口相关方法

+ (void)GETWithApi:(NSString *)api params:(NSDictionary *)params withCallBack:(JXRestCallback)callback;

+ (void)POSTWithApi:(NSString *)api params:(NSDictionary *)params withCallBack:(JXRestCallback)callback;

+ (void)PUTWithApi:(NSString *)api params:(NSDictionary *)params withCallBack:(JXRestCallback)callback;

@end
