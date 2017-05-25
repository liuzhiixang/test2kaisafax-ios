//
//  TencentQQ.h
//  
//
//  Created by Semny on 14-9-25.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIBasePlatform.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface SocialAPITencentQQ : SocialAPIBasePlatform<QQApiInterfaceDelegate>

@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@property (nonatomic, weak) id<TencentSessionDelegate> sessionDelegate;

/**
 *@brief 分享内容到QQ空间
 *
 *@param contentDic 该字典中需要包含：Title, Summary, ImagesURL, URL为键的键值对
 */
//- (long)shareContent:(NSMutableDictionary *)contentDic;

/*! 检查手机是否安装QQ客户端
 * @return BOOL  YES---已经安装；NO---未安装
 */
- (BOOL)isQQInstalled;

/**
 *  @author semny
 *
 *  分享到QQ空间
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToQZoneWith:(SocialEntity *)content;

- (NSInteger)shareContentToQZoneWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate;
@end
