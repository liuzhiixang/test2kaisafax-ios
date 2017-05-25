//
//  KSLoginBL.h
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//是否需要刷新登录态
#define KLoginNeedRefreshKey     @"LoginNeedRefreshKey"

/**
 *  @author semny
 *
 *  登录相关BL
 */
@interface KSLoginBL : KSRequestBL

/**
 * 通过手机账号登录
 * @param mobileNo   手机号
 * @param password   密码
 */
- (long)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password;
////TODO: imei没啥作用，后续的接口重构建议去掉
//- (NSInteger)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password imei:(NSString *)imei;

/**
 *  当前用户登录态注销
 *
 *  @return 请求序列号
 */
- (long)doLogout;

////TODO:注销登录，imei没啥作用，后续的接口重构建议去掉
//- (NSInteger)doLogoutByIMEI:(NSString *)imei;

/**
 *  token登录,静默登录用的(暂未实现)
 *
 *  @return 登录请求的序列号
 */
//- (long)doLoginByAccessToken;
//
///**
// *  token登录,静默登录用的(暂未实现)
// *
// *  @param isNeedRefresh 是否需要刷新登录态
// *
// *  @return 登录请求的序列号
// */
//- (long)doLoginByAccessToken:(BOOL)isNeedRefresh;

//刷新session
//- (NSInteger)doRefreshSessionId;

@end
