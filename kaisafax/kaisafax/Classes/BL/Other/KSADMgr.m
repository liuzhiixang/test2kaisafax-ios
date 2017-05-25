//
//  KSADMgr.m
//  kaisafax
//
//  Created by semny on 16/10/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADMgr.h"
#import "KSCacheMgr.h"
#import "NSDate+Utilities.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import "KSADPushVC.h"
#import "NSUserDefaults+Coder.h"
#import "KSVersionMgr.h"
#import "KSUserMgr.h"
#import "KSAdvertEntity.h"
//#import "KSNavigationVC.h"

//新的服务端的启动广告数据缓存
#define KServerAdForNewConfigKey    @"ServerAdForNewConfigKey"
//旧的服务端的启动广告数据缓存
#define KServerAdForConfigKey       @"ServerAdForConfigKey"
//是否显示广告的标志
#define KADStartNeedShowFlagKey     @"ADStartNeedShowNewFlagKey"//@"ADStartNeedShowFlagKey"

@implementation KSADMgr
/**
 *  初始化服务端广告管理工具单例对象
 *
 *  @return 服务端广告管理工具单例对象
 */
+ (id)sharedInstance
{
    static KSADMgr *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance  == nil)
        {
            instance = [[KSADMgr alloc] init];
        }
    });
    return instance;
}

/**
 *  @author semny
 *
 *  获取服务端广告
 */
- (void)doGetServerADConfig
{
    NSString *tradeId = KGetAdForConfigurableTradeId;
    //请求
    [self requestWithTradeId:tradeId data:nil];
}

#pragma mark -
#pragma mark ------------回调（子类没有实现，默认调用父类的回调）----------
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    id body = responseEntity.body;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KGetAdForConfigurableTradeId])
    {
        //用户运营图数据
        KSAdvertEntity *item = (KSAdvertEntity *)body;
        //列表数据
        NSArray<KSBussinessItemEntity*> *businessData =  item.businessData;
        
        //缓存数据
        if (!businessData || businessData.count <= 0)
        {
            //清理缓存数据
            //清理图片缓存
            [KSADMgr clearADPushData];
        }
        else
        {
            //下载完成缓存广告数据
            [KSADMgr saveADPushData:item];
            
            //判断当前本地时间在不在广告目标时间内
            KSBussinessItemEntity *itemData = businessData[0];
            //判断是否存在广告图片数据，不存在就下载图片
            BOOL needDownload = [KSADMgr checkNeedDownload:itemData];
            if(needDownload)
            {
                //下载图片
                NSString *imageUrl = itemData.imageUrl;
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (!error && finished)
                    {
                        //下载正常完成,缓存数据
                        [KSCacheMgr storeImage:image forURL:imageURL];
                    }
                }];
            }
        }
    }
    [super succeedCallbackWithResponse:resp];
}

#pragma mark - 判断方法
/**
 *  @author semny
 *
 *  判断 是否需要显示服务端推送的广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (BOOL)checkNeedShowADPushPage
{
    //判断有没有广告数据
    NSArray *businessData = [self getPushADData].businessData;
    if(businessData.count <= 0)
    {
        return NO;
    }
    
    KSBussinessItemEntity *itemData = businessData[0];
    //判断登录
    NSString *urlStr = itemData.url;
    NSURL *url = [NSURL URLWithString:urlStr];
    //不存在点击连接
    if(url)
    {
        NSString *query = [url query];
        NSString *needLoginKey = @"needToLogin";
        //获取属性
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString *needToLogin = [self valueForKey:needLoginKey fromQueryItems:queryItems];
        //判断是否需要强制登录,并且未登录，此时不显示广告
        if (query && query.length > 0 && [query containsString:needLoginKey] && [needToLogin isEqualToString:@"true"] && ![USER_MGR isLogin])
        {
            return NO;
        }
    }
    
    //判断当前本地时间在不在广告目标时间内
    NSDate *startTime = itemData.startTime;
    NSDate *endTime = itemData.endTime;
    NSDate *nowTime = [NSDate date];
    BOOL flag1 = [nowTime isEarlierThanDate:startTime];
    BOOL flag2 = [nowTime isLaterThanDate:endTime];
    if (!startTime || !endTime || flag1 || flag2)
    {
        return NO;
    }

    //判断图片下载下来了没
    NSString *imageUrl = itemData.imageUrl;
    if(!imageUrl || imageUrl.length <= 0)
    {
        return NO;
    }
    UIImage *adImage = [KSCacheMgr getCacheImageByURL:[NSURL URLWithString:imageUrl]];
    if(!adImage || CGSizeEqualToSize(CGSizeZero, adImage.size))
    {
        return NO;
    }
    
    return YES;
}

+ (NSString *)valueForKey:(NSString *)key fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}

/**
 *  @author semny
 *
 *  判断 是否需要下载服务端推送的广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (BOOL)checkNeedDownload:(KSBussinessItemEntity *)itemData
{
    NSString *imageUrl = nil;
    if(!itemData || !(imageUrl=itemData.imageUrl) || imageUrl.length <= 0)
    {
        return NO;
    }
    
    //判断是否存在广告缓存数据
    UIImage *adImage = [KSCacheMgr getCacheImageByURL:[NSURL URLWithString:imageUrl]];
    if(adImage && !CGSizeEqualToSize(CGSizeZero, adImage.size))
    {
        return NO;
    }
    
    //判断当前本地时间在不在广告目标时间内
    NSDate *startTime = itemData.startTime;
    NSDate *endTime = itemData.endTime;
    NSDate *nowTime = [NSDate date];
    BOOL flag1 = [nowTime isEarlierThanDate:startTime];
    BOOL flag2 = [nowTime isLaterThanDate:endTime];
    if (!startTime || !endTime || flag1 || flag2)
    {
        return NO;
    }

    return YES;
}

/**
 *  @author semny
 *
 *  判断 是否需要显示广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (BOOL)checkNeedShowADStartPage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *needShowFlagNum = [userDefaults objectForKey:KADStartNeedShowFlagKey];
    BOOL needShowFlag = YES;
    if(needShowFlagNum)
    {
        needShowFlag = [needShowFlagNum boolValue];
    }
    return needShowFlag;
}

/**
 *  @author semny
 *
 *  设置不需要显示广告启动页
 */
+ (void)setUnshowFlagADStartPage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(NO) forKey:KADStartNeedShowFlagKey];
    [userDefaults synchronize];
}

/**
 *  @author semny
 *
 *  判断 是否需要显示服务端推送的广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (void)clearADPushData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    KSAdvertEntity *serverAdForConfig = [self getPushADData];
    //判断有没有广告数据
    NSArray *businessData = nil;
    if(!serverAdForConfig || !(businessData=serverAdForConfig.businessData) || businessData.count <= 0)
    {
        //清理广告数据
        if ([[NSUserDefaults standardUserDefaults]decodeObjectForKey:KServerAdForConfigKey])
        {
            [userDefaults removeObjectForKey:KServerAdForConfigKey];
        }
        [userDefaults removeObjectForKey:KServerAdForNewConfigKey];
        [userDefaults synchronize];
        return;
    }
    
    KSBussinessItemEntity *itemData = businessData[0];
    //清理图片数据
    NSString *imageUrl = itemData.imageUrl;
    [KSCacheMgr clearImageForURL:[NSURL URLWithString:imageUrl]];
    
    //清理广告数据
    if ([[NSUserDefaults standardUserDefaults]decodeObjectForKey:KServerAdForConfigKey])
    {
        [userDefaults removeObjectForKey:KServerAdForConfigKey];
    }
    [userDefaults removeObjectForKey:KServerAdForNewConfigKey];
    [userDefaults synchronize];
}

//获取远程的广告数据
+ (KSAdvertEntity *)getPushADData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    KSAdvertEntity *serverAdForConfig = [userDefaults decodeObjectForKey:KServerAdForNewConfigKey];
    return serverAdForConfig;
}

//存储广告数据
+ (void)saveADPushData:(KSAdvertEntity*)item
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setEncodeObject:item forKey:KServerAdForNewConfigKey];
    [userDefaults synchronize];
}

#pragma mark - 弹出广告页面
+ (void)presentADPageBy:(UIViewController *)controller
{
    if ([self checkNeedShowADPushPage] && controller)
    {
        DEBUGG(@"%s presentADPageBy %@",__FUNCTION__, controller);
        KSAdvertEntity *serverAdForConfig = [self getPushADData];
        //判断有没有广告数据
        NSArray *businessData = nil;
        if(!serverAdForConfig || !(businessData=serverAdForConfig.businessData) || businessData.count <= 0)
        {
            return;
        }
        KSBussinessItemEntity *itemData = businessData[0];
        KSADPushVC *adVC = [[KSADPushVC alloc] init];
        adVC.bitemData = itemData;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:adVC];
        [controller presentViewController:nav animated:YES completion:nil];
    }
}
@end
