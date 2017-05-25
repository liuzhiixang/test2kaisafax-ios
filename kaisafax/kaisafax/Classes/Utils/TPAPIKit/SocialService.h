//
//  SocialService.h
//  kaisafax
//
//  Created by semny on 16/8/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialEntity.h"

//新浪微博
extern NSString *const SocialShareToSina;
//手机QQ
extern NSString *const SocialShareToQQ;
//QQ空间
extern NSString *const SocialShareToQzone;

//微信好友
extern NSString *const SocialShareToWechatSession;

//微信朋友圈
extern NSString *const SocialShareToWechatTimeline;

//微信收藏
extern NSString *const SocialShareToWechatFavorite;

//面对面
extern NSString *const SocialShareToFaceToFace;

//Facebook
extern NSString *const SocialShareToFacebook;

//Twitter
extern NSString *const SocialShareToTwitter;

@protocol SocialDelegate;

@interface SocialService : NSObject

//平台参数(分享框弹出之前有效)
@property (nonatomic, strong) NSArray *platformArray;

/**
 *  @author semny
 *
 *  初始化分享工具(弹出菜单)
 *
 *  @return 分享工具单例对象
 */
+ (SocialService *)sharedInstance;

/**
 *  @author semny
 *
 *  注册统计平台
 */
- (void)registerPlatforms;

/**
 *  @author semny
 *
 *  弹出一个分享列表的类似iOS6的UIActivityViewController控件(但是根据选择的平台分享不同的数据，具体数据由delegate中didSelectedSocialPlatform:withSocialData:返回的数据返回)
 *
 *  @param delegate 代理
 */
-(void)presentShareDialogWithDelegate:(nonnull id<SocialDelegate>)delegate;

/**
 *  @author semny
 *
 *  弹出一个分享列表的类似iOS6的UIActivityViewController控件
 *
 *  @param shareTitle 分享标题
 *  @param shareText  分享编辑页面的内嵌文字
 *  @param shareImage 分享内嵌图片,用户可以在编辑页面删除
 *  @param shareURL   分享的点击链接URL
 *  @param delegate   操作delegate
 */
-(void)presentShareDialogWithTitle:(nullable NSString *)shareTitle
                              text:(nullable NSString *)shareText
                             image:(nullable id)shareImage
                          imageURL:(nullable NSString *)shareImageURL
                               URL:(nullable NSString *)shareURL
                          delegate:(nullable id <SocialDelegate>)delegate;

/**
 *  处理第三方登录或者分享后返回当前APP的情况
 *
 *  @param url               需要处理的第三方跳转的URL
 *  @param sourceApplication 第三方来源标志
 *  @param annotation        描述注解
 *
 *  @return 是否跳转成功
 */
- (BOOL)handleOpenURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation;

@end


@protocol SocialDelegate <NSObject>

@optional

//将要显示
- (void)willShowSocialDialog;
/**
关闭当前页面之后
 @param fromViewControllerType 关闭的页面类型
 */
//-(void)didCloseUIViewController:(ViewControllerType)fromViewControllerType;

/**
各个页面执行授权完成、分享完成、或者评论完成时的回调函数
 
 @param response 返回`SocialResponseEntity`对象，`SocialResponseEntity`里面的viewControllerType属性可以获得页面类型
 */
//-(void)didFinishGetSocialEntityInViewController:(SocialResponseEntity *)response;

/**
点击分享列表页面，之后的回调方法，你可以通过判断不同的分享平台，来设置分享内容。
 例如：
 
 -(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(SocialEntity *)socialData
 {
 if (platformName == SocialShareToSina) {
 socialData.shareText = @"分享到新浪微博的文字内容";
 }
 else{
 socialData.shareText = @"分享到其他平台的文字内容";
 }
 }
 
 @param platformName 点击分享平台
 
 @prarm socialData   分享内容
 */
-(void)didSelectedSocialPlatform:(nonnull NSString *)platformName withSocialData:(nullable SocialEntity *)socialData;

/**
*  @author semny
 *
 *  取消
 */
- (void)didCancleSocialDialog;

/**
 *  @author semny
 *
 *  分享失败
 *
 *  @param platformName 平台名称
 */
-(void)didFailedSocialPlatform:(nonnull NSString *)platformName;

@end

