//
//  KSLoginBL.m
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLoginBL.h"
#import "KSUserInfoEntity.h"
#import "KSUserMgr.h"
#import "KSAssetsBL.h"

@interface KSLoginBL()

//@property (nonatomic, strong) KSUserInfoBL *userInfoBL;
@property (nonatomic, strong) KSAssetsBL *assetsBL;

//@property (nonatomic, copy) NSString *tempMobile;
@property (nonatomic, copy) NSString *tempPW;

@end

@implementation KSLoginBL

/**
 * 通过手机账号登录
 * @param mobileNo   手机号
 * @param password   密码
 */
- (long)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password
{
    long long seqNo = [self doLoginByMobile:mobileNo andPassaword:password loginPathType:LoginPathInProcess];
    return seqNo;
}

////TODO: imei没啥作用，后续的接口重构建议去掉
//- (NSInteger)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password
//{
//    NSString *imeiStr = imei;
//    long long seqNo = [self doLoginByMobile:mobileNo andPassaword:password loginPathType:LoginPathInProcess];
//    return seqNo;
//}

- (long)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password loginPathType:(int)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (mobileNo)
    {
//        _tempMobile = mobileNo;
        [params setObject:mobileNo forKey:kMobileKey];
        [dict setObject:mobileNo forKey:KUserAccountInAction];
    }
    if (password)
    {
        _tempPW = password;
        [params setObject:password forKey:kPasswordKey];
    }
    
    NSString *tradeId = KLoginTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params updateSession:YES];
    
    [dict setObject:[NSNumber numberWithLong:seqNo] forKey:kRequestProcessSeqNo];
    [dict setObject:[NSNumber numberWithInt:type] forKey:KLoginPathInAction];
    if (KLoginMobileProcessTradeId)
    {
        [dict setObject:KLoginMobileProcessTradeId forKey:kRequestProcessCmdId];
    }
    
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:dict];
    return seqNo;
}

/**
 *  当前用户登录态注销
 *
 *  @return 请求序列号
 */
- (long)doLogout
{
    long seqNo = [self doLogoutByPathType:LoginPathInProcess];
    return seqNo;
}

- (long)doLogoutByPathType:(int)type
{
    if (type > LoginPathInProcess || type < LoginPathInStart)
    {
        type = LoginPathInProcess;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KLogoutTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params];
    NSDictionary *dict = @{KLoginPathInAction:[NSNumber numberWithInt:type]};
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:dict];
    return seqNo;
}

/**
 *  token登录
 *
 *  @return 登录请求的序列号
 */
//- (long)doLoginByAccessToken
//{
//    //每次请求都需要重置
//    //_loginTokenReCount = 0;
//    BOOL isNeedRefresh = YES;
//    long seqno = [self loginByAccessToken:isNeedRefresh];
//    return seqno;
//}

/**
 *  token登录
 *
 *  @param needRefresh 是否需要刷新登录态
 *
 *  @return 登录请求的序列号
 */
//- (long)doLoginByAccessToken:(BOOL)isNeedRefresh
//{
//    //每次请求都需要重置
//    //_loginTokenReCount = 0;
//    long seqno = [self loginByAccessToken:isNeedRefresh];
//    return seqno;
//}

//- (long)loginByAccessToken:(BOOL)isNeedRefresh
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    NSString *tradeId = KLoginTokenTradeId;
//    long long seqNo = [self requestWithTradeId:tradeId data:params];
//    int type = LoginPathInStart;
//    NSDictionary *dict = @{KLoginPathInAction:[NSNumber numberWithLong:type], KLoginNeedRefreshKey:[NSNumber numberWithBool:isNeedRefresh]};
//
//    [self updateRecordStackBySeqno:seqNo data:dict];
//    return seqNo;
//}

//- (NSInteger)doRefreshSessionId
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    
//    NSString *tradeId = KRefreshSessionIdTradeId;
//    long long seqNo = [self requestWithTradeId:tradeId data:params];
//    int type = LoginPathInStart;
//    NSDictionary *dict = @{KLoginPathInAction:[NSNumber numberWithLong:type]};
//    [self updateRecordStackBySeqno:seqNo data:dict];
//    return seqNo;
//}

/**
 *  @author semny
 *
 *  获取当前用户的个人账户财富信息(登录过程)
 *
 *  @param userId        用户id（暂时没用）
 *  @param pCmdId        主流程请求cmdId
 *  @param pSeqNo        主流程序列号
 *  @param loginPathType 登录的路径
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserAssetsInLogin:(long long)userId account:(NSString *)account processCmdId:(NSString *)pCmdId processSeqNo:(NSInteger)pSeqNo loginPathType:(NSInteger)loginPathType
{
    //获取账户财富信息
    if (!_assetsBL)
    {
        _assetsBL = [[KSAssetsBL alloc] init];
    }
    NSNumber *pSeqNoNum = [NSNumber numberWithInteger:pSeqNo];
    NSString *pCmdIdStr = pCmdId;
    long long seqNo = [_assetsBL doGetUserNewAssetsByDelegate:self];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:pSeqNoNum forKey:kRequestProcessSeqNo];
    [dict setObject:[NSNumber numberWithInteger:loginPathType] forKey:KLoginPathInAction];
    [dict setObject:[NSNumber numberWithLongLong:userId] forKey:KUserIdInAction];
    if (pCmdIdStr)
    {
        [dict setObject:pCmdIdStr forKey:kRequestProcessCmdId];
    }
    if (account)
    {
        [dict setObject:account forKey:KUserAccountInAction];
    }
    [self updateRecordStackBySeqno:seqNo data:dict];
    return seqNo;
}

#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
- (void)succeedCallbackWithResponse:(KSResponseEntity *)resp
{
    NSString *tempCmdId = resp.tradeId;
    long long seqNo = resp.sid;
//    NSNumber *seqNoNum = [NSNumber numberWithInteger:seqNo];
    
    //包体数据
    //id bodyObj = nil;
    KSResponseEntity *resultResp = resp;
    id respData = resp.body;
    //判断几种登录
    if ([KLoginTradeId isEqualToString:tempCmdId])
    {
        KSUserInfoEntity *userInfo = nil;
        if (respData && [respData isKindOfClass:[KSUserInfoEntity class]])
        {
            userInfo = (KSUserInfoEntity*)respData;
        }
        //bodyObj = userInfo;
        //判断登录用户信息是否有效
        long long userId = userInfo.user.userId;
        NSString *sessionId = userInfo.sessionId;
        KSUserMgr *userMgr = USER_MGR;
        if (userInfo && userId > 0 && sessionId && sessionId.length > 0)
        {
            [userMgr setNewUser:userInfo];
//            [userMgr syncUserInfo];
            
            //后续登录使用到的token数据
//            [USER_MGR  setSessionIdForCurrentUserWith:sessionId];
        }
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        DEBUGG(@"%@ seqDict: %@",tempCmdId, seqDict);
        NSNumber *loginPathTypeNum = [seqDict objectForKey:KLoginPathInAction];
        int loginPathType = LoginPathInProcess;
        if (loginPathTypeNum)
        {
            loginPathType = loginPathTypeNum.intValue;
        }
        //[USER_MGR handleLoginStateValid:loginPathType];
        
        //获取用户账户信息
        //父流程的序列号
        NSNumber *pSeqNoNum = [seqDict objectForKey:kRequestProcessSeqNo];
        NSInteger pSeqNo = -1;
        if (pSeqNoNum)
        {
            pSeqNo = pSeqNoNum.integerValue;
        }
        NSString *pCmdIdStr = [seqDict objectForKey:kRequestProcessCmdId];
        
        //获取用户信息
        [USER_MGR doGetUserInfo];
        //记录登录账号
        NSString *account = [seqDict objectForKey:KUserAccountInAction];
        //手机号登录需要获取账户信息
        [self doGetUserAssetsInLogin:userId account:account processCmdId:pCmdIdStr processSeqNo:pSeqNo loginPathType:loginPathType];
        return;
    }
//    else if([KLoginTokenTradeId isEqualToString:tempCmdId])
//    {
//        //后续静默登录需要获取用户账户信息，同上
//        return;
//    }
    else if ([KLogoutTradeId isEqualToString:tempCmdId])
    {
        // 清理登录用户信息
        [USER_MGR clearOwner];
        
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        //DEBUGG(@"%d seqDict: %@",tempCmdId, seqDict);
        NSNumber *loginPathTypeNum = [seqDict objectForKey:KLoginPathInAction];
        int loginPathType = LoginPathInProcess;
        if (loginPathTypeNum)
        {
            loginPathType = loginPathTypeNum.intValue;
        }
        DEBUGG(@"%@ before handleLoginStateInvalid(SSO_CMD_LogOut) in succeedCallbackWithDictionary", self);
        //处理注销登录后的操作
        [USER_MGR handleLoginStateInvalid:loginPathType loginType:LoginTypeByLogin];
        return;
    }
    else if ([KUserNewAssetsTradeId isEqualToString:tempCmdId])
    {
        //NSNumber *getUserTypeNum = [self.seqNumDic objectForKey:seqNoNum];
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        
        DEBUGG(@"%@ seqDict: %@",tempCmdId, seqDict);
        //主流程序列号
        NSString *pCmdIdStr = [seqDict objectForKey:kRequestProcessCmdId];
        
        NSNumber *pSeqNoNum = [seqDict objectForKey:kRequestProcessSeqNo];
        NSInteger pSeqNo = -1;
        if (pSeqNoNum)
        {
            pSeqNo = pSeqNoNum.integerValue;
        }
        
        NSNumber *loginPathTypeNum = [seqDict objectForKey:KLoginPathInAction];
        NSInteger loginPathType = LoginPathInProcess;
        if (loginPathTypeNum)
        {
            loginPathType = loginPathTypeNum.integerValue;
        }
        
        //解析用户数据
        KSNewAssetsEntity *userAssets = nil;
        if ([respData isKindOfClass:[KSNewAssetsEntity class]])
        {
            userAssets = respData;
        }
        //判断是不是在登录流程中
        if ([pCmdIdStr isEqualToString:KLoginMobileProcessTradeId])
        {
            //账户信息
            USER_MGR.assets = userAssets;
            [USER_MGR syncCacheUserInfo];
            [USER_MGR syncCacheAssets];
            
            //登录态通知
            [USER_MGR handleLoginStateValid:loginPathType loginType:LoginTypeByLogin];
            //设置主流程标志
            resultResp.processSeqNo = pSeqNo;
            resultResp.processTradeId = pCmdIdStr;
            
            //TODO: Test data login in background
            
            //保存登录数据
//            NSString *userName = _tempMobile;
            NSString *pw = _tempPW;
            //记录登录账号
            NSString *account = [seqDict objectForKey:KUserAccountInAction];
            if (account)
            {
                //保存密码，用户记录
                [USER_MGR setPasswordForCurrentUserWith:pw account:account];
            }
        }
    }
    
    //调用父类的回调
    [super succeedCallbackWithResponse:resultResp];
}

- (void)failedCallbackWithResponse:(KSResponseEntity *)resp
{
    NSString *tempCmdId = resp.tradeId;
    long long seqNo = resp.sid;
//    NSNumber *seqNoNum = [NSNumber numberWithInteger:seqNo];
//    NSInteger resultCode = resp.errorCode;
//    NSDictionary *bodyObj = nil;
    KSResponseEntity *resultResp = resp;
    
    //判断几种登录
    if ([KLoginTradeId isEqualToString:tempCmdId])
    {
        // 清理登录用户信息
        [USER_MGR clearOwner];
        
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        //父流程的序列号
        NSNumber *pSeqNoNum = [seqDict objectForKey:kRequestProcessSeqNo];
        NSInteger pSeqNo = -1;
        if (pSeqNoNum)
        {
            pSeqNo = pSeqNoNum.integerValue;
        }
        NSString *pCmdIdStr = [seqDict objectForKey:kRequestProcessCmdId];
        
        //父流程标志
        resultResp.processTradeId = pCmdIdStr;
        resultResp.processSeqNo = pSeqNo;
    }
//    else if([KLoginTokenTradeId isEqualToString:tempCmdId])
//    {
//    }
    else if ([KLogoutTradeId isEqualToString:tempCmdId])
    {
        // 清理登录用户信息
        [USER_MGR clearOwner];
        //路径
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        NSNumber *loginPathTypeNum = [seqDict objectForKey:KLoginPathInAction];
        int loginPathType = LoginPathInProcess;
        if (loginPathTypeNum)
        {
            loginPathType = loginPathTypeNum.intValue;
        }
        //处理注销登录后的操作
        [USER_MGR handleLoginStateInvalid:loginPathType loginType:LoginTypeByLogin];
    }
    else if ([KUserNewAssetsTradeId isEqualToString:tempCmdId])
    {
        //NSNumber *getUserTypeNum = [self.seqNumDic objectForKey:seqNoNum];
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        
        DEBUGG(@"%@ seqDict: %@",tempCmdId, seqDict);
        //主流程序列号
        NSString *pCmdIdStr = [seqDict objectForKey:kRequestProcessCmdId];
        
        NSNumber *pSeqNoNum = [seqDict objectForKey:kRequestProcessSeqNo];
        NSInteger pSeqNo = -1;
        if (pSeqNoNum)
        {
            pSeqNo = pSeqNoNum.integerValue;
        }
        //判断是不是在登录流程中
        if ([pCmdIdStr isEqualToString:KLoginMobileProcessTradeId])
        {
            //设置主流程标志
            resultResp.processSeqNo = pSeqNo;
            resultResp.processTradeId = pCmdIdStr;
            
            //清理登录态
            // 清理登录用户信息
            [USER_MGR clearOwner];
        }
    }
    
    //处理错误回调
    [super failedCallbackWithResponse:resultResp];
}

- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)resp
{
    NSString *tempCmdId = resp.tradeId;
    long long seqNo = resp.sid;
    //NSInteger resultCode = resp.errorCode;
//    NSNumber *seqNoNum = [NSNumber numberWithInteger:seqNo];
    NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
    NSNumber *loginPathTypeNum = [seqDict objectForKey:KLoginPathInAction];
    int loginPathType = LoginPathInProcess;
    if (loginPathTypeNum)
    {
        loginPathType = loginPathTypeNum.intValue;
    }
    
    //判断几种登录
    if ([KLogoutTradeId isEqualToString:tempCmdId])
    {
        // 清理登录用户信息
        [USER_MGR handleLoginStateInvalid:loginPathType loginType:LoginTypeByLogin];
    }
//    else if([KLoginTokenTradeId isEqualToString:tempCmdId])
//    {
//    }
    else if ([KUserNewAssetsTradeId isEqualToString:tempCmdId])
    {
        //NSNumber *getUserTypeNum = [self.seqNumDic objectForKey:seqNoNum];
        NSDictionary *seqDict = [self objectInRecordStackForSeqno:seqNo];
        
        DEBUGG(@"%@ seqDict: %@",tempCmdId, seqDict);
        //主流程序列号
        NSString *pCmdIdStr = [seqDict objectForKey:kRequestProcessCmdId];
        
        NSNumber *pSeqNoNum = [seqDict objectForKey:kRequestProcessSeqNo];
        NSInteger pSeqNo = -1;
        if (pSeqNoNum)
        {
            pSeqNo = pSeqNoNum.integerValue;
        }
        //判断是不是在登录流程中
        if ([pCmdIdStr isEqualToString:KLoginMobileProcessTradeId])
        {
            //清理登录态
            // 清理登录用户信息
            [USER_MGR clearOwner];
        }
    }
    
    [super sysErrorCallbackWithResponse:resp];
}

@end
