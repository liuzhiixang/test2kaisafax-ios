//
//  SocialAPIBasePlatform.m
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIBasePlatform.h"

@interface SocialAPIBasePlatform ()

@end

@implementation SocialAPIBasePlatform

/*! @brief 初始化实例对象
 *
 * @return 实例
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SocialKeyConfig" ofType:@"plist"];
        _platformsConfigDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return self;
}

- (void)registerApp {
    
}

- (long)getUserInfo {
    return -1;
}

- (long)ssoLogin {
    return -1;
}

- (long)ssoLogout {
    return -1;
}

//- (long)shareContent:(NSMutableDictionary *)contentDic
//{
//    return -1;
//}
/**
 *  @author semny
 *
 *  分享信息到相关平台
 *
 *  @param content 数据内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentWith:(SocialEntity *)content
{
    return [self shareContentWith:content delegate:_delegate];
}

- (NSInteger)shareContentWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    return -1;
}

- (long)getUserInfo:(NSInteger)pCmdId processSeqNo:(long)pSeqNo
{
    return -1;
}

- (void)clearUserInfo
{
    //清理用户信息
}

- (NSDictionary *)composeTPResultBy:(NSDictionary *)result tpType:(int)tpType
{
    NSMutableDictionary *resultDict = nil;
    if (!result || result.count <= 0 || tpType <= 0)
    {
        return resultDict;
    }
    resultDict = [NSMutableDictionary dictionaryWithDictionary:result];
    [resultDict setObject:[NSNumber numberWithInt:tpType] forKey:kRequestProcessCmdId];
    return resultDict;
}

@end
