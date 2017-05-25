//
//  KSRegisterBL.m
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRegisterBL.h"
#import "KSUserMgr.h"
#import "KSAssetsBL.h"

@interface KSRegisterBL()

@property (nonatomic, strong) KSAssetsBL *assetsBL;

//@property (nonatomic, copy) NSString *tempMobile;
@property (nonatomic, copy) NSString *tempPW;

@end

@implementation KSRegisterBL

/**
 *  @author semny
 *  注册用户
 *
 *  @param mobile   手机号码
 *  @param password 密码
 *  @param referee  推荐人
 *
 *  @return 序列号
 */
- (NSInteger)doRegisterWith:(NSString *)mobile withPassword:(NSString *)password verifyCode:(NSString*)verifyCode referee:(NSString *)referee
{
    long long seqNo = [self doRegisterWith:mobile withPassword:password verifyCode:verifyCode referee:referee loginPathType:LoginPathInProcess];
    return seqNo;
}

/**
 *  @author semny
 *  注册用户
 *
 *  @param mobile   手机号码
 *  @param password 密码
 *  @param referee  推荐人
 *
 *  @return 序列号
 */
- (NSInteger)doRegisterWith:(NSString *)mobile withPassword:(NSString *)password verifyCode:(NSString*)verifyCode referee:(NSString *)referee loginPathType:(int)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (mobile)
    {
//        _tempMobile = mobile;
        [params setObject:mobile forKey:kMobileKey];
        [dict setObject:mobile forKey:KUserAccountInAction];
    }
    if (password)
    {
        _tempPW = password;
        [params setObject:password forKey:kPasswordKey];
    }
    if (verifyCode)
    {
        [params setObject:verifyCode forKey:kVerifyCodeKey];
    }
    if (referee)
    {
        [params setObject:referee forKey:kRefereeKey];
    }
    
    NSString *tradeId = KRegisterTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params updateSession:YES];
//    NSDictionary *dict = @{kRequestProcessSeqNo:[NSNumber numberWithLong:seqNo],kRequestProcessCmdId:KRegisterProcessTradeId, KLoginPathInAction:[NSNumber numberWithInt:type]};
    [dict setObject:[NSNumber numberWithLong:seqNo] forKey:kRequestProcessSeqNo];
    [dict setObject:[NSNumber numberWithInt:type] forKey:KLoginPathInAction];
    if (KRegisterProcessTradeId)
    {
        [dict setObject:KRegisterProcessTradeId forKey:kRequestProcessCmdId];
    }
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:dict];
    return seqNo;
}

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
- (NSInteger)doGetUserAssetsInRegister:(long long)userId account:(NSString*)account processCmdId:(NSString *)pCmdId processSeqNo:(NSInteger)pSeqNo loginPathType:(NSInteger)loginPathType
{
    //获取账户财富信息
    if (!_assetsBL)
    {
        _assetsBL = [[KSAssetsBL alloc] init];
    }
    NSNumber *pSeqNoNum = [NSNumber numberWithInteger:pSeqNo];
    NSString *pCmdIdStr = pCmdId;
    long long seqNo = [_assetsBL doGetUserNewAssetsByDelegate:self];
//    NSDictionary *dict = @{kRequestProcessSeqNo:pSeqNoNum, kRequestProcessCmdId:pCmdIdStr,KLoginPathInAction:[NSNumber numberWithInteger:loginPathType]};
    
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
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:dict];
    return seqNo;
}

#pragma mark -结果回调
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    NSString *tempCmdId = responseEntity.tradeId;
    long long seqNo = responseEntity.sid;
//    NSNumber *seqNoNum = [NSNumber numberWithInteger:seqNo];
    
    //包体数据
    //id bodyObj = nil;
    KSResponseEntity *resultResp = responseEntity;
    id respData = resultResp.body;
    //判断几种登录
    if ([KRegisterTradeId isEqualToString:tempCmdId])
    {
        KSUserInfoEntity *userInfo = nil;
        if (respData && [respData isKindOfClass:[KSUserInfoEntity class]])
        {
            userInfo = (KSUserInfoEntity*)respData;
        }
        //bodyObj = userInfo;
        //判断登录用户信息是否有效
        long long userId = userInfo.user.userId;
        NSString *imeiStr = userInfo.sessionId;
        KSUserMgr *userMgr = USER_MGR;
        if (userInfo && userId > 0 && imeiStr && imeiStr.length > 0)
        {
            [userMgr setNewUser:userInfo];
//            [userMgr syncUserInfo];
            
            //后续登录使用到的token数据
//            [USER_MGR setSessionIdForCurrentUserWith:imeiStr];
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
        [self doGetUserAssetsInRegister:userId account:account processCmdId:pCmdIdStr processSeqNo:pSeqNo loginPathType:loginPathType];
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
        if ([pCmdIdStr isEqualToString:KRegisterProcessTradeId])
        {
            //账户信息
            USER_MGR.assets = userAssets;
            [USER_MGR syncCacheUserInfo];
            [USER_MGR syncCacheAssets];
            
            //设置主流程标志
            resultResp.processSeqNo = pSeqNo;
            resultResp.processTradeId = pCmdIdStr;
            
//            //TODO: Test data login in background
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
            //登录态通知
            [USER_MGR handleLoginStateValid:loginPathType loginType:LoginTypeByRegister];
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
    if ([KRegisterTradeId isEqualToString:tempCmdId])
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
        if ([pCmdIdStr isEqualToString:KRegisterProcessTradeId])
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

    //判断几种登录
    if ([KUserNewAssetsTradeId isEqualToString:tempCmdId])
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
        if ([pCmdIdStr isEqualToString:KRegisterProcessTradeId])
        {
            //清理登录态
            // 清理登录用户信息
            [USER_MGR clearOwner];
        }
    }
    
    [super sysErrorCallbackWithResponse:resp];
}
@end
