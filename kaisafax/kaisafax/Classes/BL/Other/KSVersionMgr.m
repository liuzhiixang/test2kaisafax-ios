
#import "KSVersionMgr.h"
#import "NSUserDefaults+Coder.h"

#import "KSUpdateAlert.h"

@interface KSVersionMgr()<UpdateViewDelegate>



@end

@implementation KSVersionMgr

#pragma mark-
#pragma mark ----- Public methods -----

+ (KSVersionMgr *)sharedInstance
{
    static KSVersionMgr * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KSVersionMgr alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _errorDescription = nil;
    }
    return self;
}

#pragma mark -

- (NSInteger)doCheckUpdate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    int versionNo = [self getAppVersion];
    
    [params setObject:[NSNumber numberWithInt:versionNo] forKey:kVersionNumberKey];
    NSString *tradeId = KCheckAPPUpdateStatusTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark-
#pragma mark ----- Private Methods -----
- (int)getAppVersion
{
    int versionNum = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"] intValue];
    return versionNum;
}

- (NSString *)getVersionName
{
    NSString *versionName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    return versionName;
}

- (NSString *)getAppName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"];
    return appName;
}

#pragma mark -Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 请求回调
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //检测更新接口
    NSString *tempCmdId = responseEntity.tradeId;
    
    //包体数据
    //id bodyObj = nil;
    KSResponseEntity *resultResp = responseEntity;
    id respData = resultResp.body;
    //判断几种登录
    if ([KCheckAPPUpdateStatusTradeId isEqualToString:tempCmdId])
    {
        KSVersionEntity *versionInfo = nil;
        if (respData && [respData isKindOfClass:[KSVersionEntity class]])
        {
            versionInfo = (KSVersionEntity*)respData;
           _versionData = versionInfo;
            self.errorDescription = nil;
            
            //判断是否需要升级
           BOOL must = versionInfo.must;
            NSString *title = versionInfo.title;
            NSString *desc = versionInfo.desc;
            NSString *verDes = versionInfo.verDes;
            NSString *actionTitle = KUpdateActionTitle;
            
            //显示升级提示
            [self showUpdatePopupWindowWithMust:must version:verDes title:title description:desc actionTitle:actionTitle];
        }
    }
    
    [super succeedCallbackWithResponse:responseEntity];
}

- (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    self.versionData = nil;
    self.errorDescription = responseEntity.errorDescription;
    //啥都不干
    [super failedCallbackWithResponse:responseEntity];
}

- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    self.versionData = nil;
    self.errorDescription = responseEntity.errorDescription;
    //啥都不干
    [super sysErrorCallbackWithResponse:responseEntity];
}

#pragma mark - 显示升级弹出框
- (void)showUpdatePopupWindowWithMust:(BOOL)must version:(NSString*)version title:(NSString *)title description:(NSString *)description actionTitle:(NSString *)actionTitle
{
//    title = nil;
//    description = nil;
    
    BOOL mustUpdate = must;
    //BOOL mustUpdate = YES;
    //显示弹出框
    [[KSUpdateAlert sharedInstance] showUpdatePopupWindowWithVersion:version title:title description:description actionTitle:actionTitle close:!mustUpdate delegate:self];
}

#pragma mark - updateView delegate
- (void)updateViewCancel:(KSUpdateView *)updateView
{
    DEBUGG(@"%s, %@", __FUNCTION__, updateView);
    [[KSUpdateAlert sharedInstance] hiddenUpdatePopupWindow];
}

- (void)updateViewOther:(KSUpdateView *)updateView
{
    DEBUGG(@"%s, %@", __FUNCTION__, updateView);
    //跳转到url
    NSString *urlStr = _versionData.url;
    if (urlStr && urlStr.length > 0)
    {
        NSURL *updateURL = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:updateURL];
    }
    
    //跳转的时候是否需要隐藏
    if (updateView.needClose)
    {
        //关闭对话框
        [[KSUpdateAlert sharedInstance] hiddenUpdatePopupWindow];
    }
}
@end
