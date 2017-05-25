//
//  SocialService.m
//  kaisafax
//
//  Created by semny on 16/8/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SocialService.h"
#import "SGActionView.h"
#import "SocialAPIManager.h"
#import "KSFaceToFaceVC.h"
#import "SQImageUtil.h"
#import "KSCacheMgr.h"

//新浪微博
NSString *const SocialShareToSina = @"SNSShareToSina";
//手机QQ
NSString *const SocialShareToQQ = @"SNSShareToQQ";
//QQ空间
NSString *const SocialShareToQzone = @"SNSShareToQzone";
//微信好友
NSString *const SocialShareToWechatSession = @"SNSShareToWechatSession";
//微信朋友圈
NSString *const SocialShareToWechatTimeline = @"SNSShareToWechatTimeline";
//微信收藏
NSString *const SocialShareToWechatFavorite = @"SNSShareToWechatFavorite";
//面对面
NSString *const SocialShareToFaceToFace = @"SNSShareToFaceToFace";
//Facebook
NSString *const SocialShareToFacebook = @"SNSShareToFacebook";
//Twitter
NSString *const SocialShareToTwitter = @"SNSShareToTwitter";


//分享的平台名称
NSString *const SocialConfigTitleKey = @"title";
//分享的平台图标
NSString *const SocialConfigImageNameKey = @"imageName";
//分享类型
NSString *const SocialConfigSNSTypeKey = @"SNSType";

@interface SocialService()

//配置信息
@property (strong, nonatomic) NSDictionary *socialConfigDict;
//需要使用的平台名称
//@property (strong, nonatomic) NSArray *snsArray;

@end

@implementation SocialService

/**
 *  @author semny
 *
 *  初始化分享工具(弹出菜单)
 *
 *  @return 分享工具单例对象
 */
+ (SocialService *)sharedInstance
{
    static SocialService *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SocialService alloc] init];
    });
    
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SocialConfig" ofType:@"plist"];
        _socialConfigDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return self;
}

/**
 *  @author semny
 *
 *  注册统计平台
 */
- (void)registerPlatforms
{
    [[SocialAPIManager sharedInstance] registerAppWithPlatforms:@[@"WeChat", @"QQ", @"SinaWeibo"]];
}

-(void)presentShareDialogWithDelegate:(nonnull id<SocialDelegate>)delegate
{
    //分享(需要根据delegate返回的数据处理)
    [self inner_presentShareDialogWithTitle:nil text:nil image:nil imageURL:nil URL:nil delegate:delegate];
}

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
-(void)presentShareDialogWithTitle:(NSString *)shareTitle
                              text:(NSString *)shareText
                             image:(id)shareImage
                          imageURL:(NSString *)shareImageURL
                               URL:(NSString *)shareURL
                          delegate:(id <SocialDelegate>)delegate
{
    //判断数据是否同时为空
    if (!shareText && !shareImage)
    {
        return;
    }
    //分享
    [self inner_presentShareDialogWithTitle:shareTitle text:shareText image:shareImage imageURL:shareImageURL URL:shareURL delegate:delegate];
}

-(void)inner_presentShareDialogWithTitle:(NSString *)shareTitle
                                    text:(NSString *)shareText
                                   image:(id)shareImage
                                imageURL:(NSString *)shareImageURL
                                     URL:(NSString *)shareURL
                                delegate:(id <SocialDelegate>)delegate
{
    //判断平台数据
    NSInteger snsCount = _platformArray.count;
    if (!_platformArray || snsCount <= 0)
    {
        _platformArray = [NSArray arrayWithObjects:SocialShareToWechatSession,SocialShareToWechatTimeline,SocialShareToQQ,SocialShareToQzone,SocialShareToSina, nil];
        snsCount = _platformArray.count;
    }
    //标题
    NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:snsCount];
    //图标
    NSMutableArray *itemImgs = [NSMutableArray arrayWithCapacity:snsCount];
    //获取弹出菜单数据
    for (int index = 0; index < snsCount; index++)
    {
        //单个平台的样式信息
        NSString *snsName = [_platformArray objectAtIndex:index];
        NSDictionary *dict = [_socialConfigDict objectForKey:snsName];
        //分享类型名称
        NSString *title = [dict objectForKey:SocialConfigTitleKey];
        if(!title)
        {
            title = @"";
        }
        [itemTitles addObject:title];
        //图标
        NSString *imageName = [dict objectForKey:SocialConfigImageNameKey];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image)
        {
            [itemImgs addObject:image];
        }
    }
    
    //将要显示
    if (delegate && [delegate respondsToSelector:@selector(willShowSocialDialog)])
    {
        [delegate willShowSocialDialog];
    }
    
    NSLog(@"%s", __FUNCTION__);
    //显示分享菜单
    __weak typeof(self) weakSelf = self;
    [SGActionView showGridMenuWithTitle:@"分享到" itemTitles:itemTitles images:itemImgs selectedHandle:^(NSInteger index) {
        NSLog(@"%s", __FUNCTION__);
        //取消按钮
        if (index == -1)
        {
            //取消了
            if (delegate && [delegate respondsToSelector:@selector(didCancleSocialDialog)])
            {
                [delegate didCancleSocialDialog];
            }
        }
        else
        {
            //是否需要图片数据的标志
            BOOL needImageData = NO;
            //判断越界
            if (index >= 0 && index < weakSelf.platformArray.count)
            {
                NSString *snsName = [weakSelf.platformArray objectAtIndex:index];
                NSDictionary *dict = [weakSelf.socialConfigDict objectForKey:snsName];
                NSNumber *snsTypeNum = [dict objectForKey:SocialConfigSNSTypeKey];
                int snsType = [snsTypeNum intValue];
                
                //分享数据
                SocialEntity *shareContent = nil;
                NSString *shareId = nil;
                //判断是不是面对面
                if(snsType == SocialAPISNSTypeFaceToFace)
                {
                    //分享数据内容
                    shareContent = [[SocialEntity alloc] initWithIdentifier:shareId withTitle:shareTitle];
                    shareContent.shareText = shareText;
                    if (!shareImage)
                    {
                        shareContent.shareImage = shareImage;
                    }
                    NSURL *shareImageURLT = nil;
                    if (shareImageURL && shareImageURL.length > 0)
                    {
                        shareImageURLT = [NSURL URLWithString:shareImageURL];
                        shareContent.shareImageURL = shareImageURLT;
                    }
                    shareContent.url = shareURL;
                    
                    //面对面
                    if (delegate && [delegate respondsToSelector:@selector(didSelectedSocialPlatform:withSocialData:)])
                    {
                        [delegate didSelectedSocialPlatform:snsName withSocialData:shareContent];
                    }
                    //面对面页面
                    [weakSelf showFaceToFacePage:shareURL];
                }
                else
                {
                    
                    //判断分享平台类型
                    switch (snsType)
                    {
                        case SocialAPISNSTypeWeChat:
                            //微信好友
                        case SocialAPISNSTypeWeChatMoments:
                            //微信朋友圈
                        {
                            if (![[SocialAPIManager sharedInstance] isSSOClientInstalled:SocialAPISSOTypeWeChat]) {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KShareShowErrorTitle message:KShareUnInstallWechatAPPShowErrorInfo delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alertView show];
                                return;
                            }
                            shareId = @"WeChatShare";
                            needImageData = YES;
                        }
                            break;
                        case SocialAPISNSTypeQQ:
                            //QQ好友
                        case SocialAPISNSTypeQQZone:
                            //QQ空间
                        {
                            if (![[SocialAPIManager sharedInstance] isSSOClientInstalled:SocialAPISSOTypeQQ])
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KShareShowErrorTitle message:KShareUnInstallQQAPPShowErrorInfo delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alertView show];
                                return;
                            }
                            shareId = @"QQShare";
                            needImageData = NO;
                        }
                            break;
                        case SocialAPISNSTypeSinaWeibo:
                            //新浪微博
                        {
                            if (![[SocialAPIManager sharedInstance] isSSOClientInstalled:SocialAPISSOTypeSinaWeibo])
                            {
                            }
                            
                            shareId = @"SinaWeiboShare";
                            needImageData = NO;
                        }
                            break;
                        default:
                            break;
                    }
                    
                    //判断是否为正常的分享平台
                    if (shareId && shareId.length > 0)
                    {
                        //分享数据内容
                        shareContent = [[SocialEntity alloc] initWithIdentifier:shareId withTitle:shareTitle];
                        shareContent.shareText = shareText;
                        
                        NSURL *shareImageURLT = nil;
                        if (shareImageURL && shareImageURL.length > 0)
                        {
                            shareImageURLT = [NSURL URLWithString:shareImageURL];
                            shareContent.shareImageURL = shareImageURLT;
                        }
                        shareContent.url = shareURL;
                        
                        //图片数据
                        id imageData = nil;
                        if (!shareImage)
                        {
                            imageData = shareImage;
                        }
                        else if (needImageData && shareImageURLT)
                        {
                            UIImage *image = [KSCacheMgr getCacheImageByURL:shareImageURLT];
                            if (!image || CGSizeEqualToSize(CGSizeZero, image.size))
                            {
                                //下载缓存数据
                                imageData = [NSData dataWithContentsOfURL:shareImageURLT];
                                image = [UIImage imageWithData:imageData];
                                [KSCacheMgr storeImage:image forURL:shareImageURLT];
                            }
                            //压缩
                            imageData = [SQImageUtil compress:image maxSize:CGSizeMake(512.0f, 512.0f) compression:0.5f];
                        }
                        shareContent.shareImage = imageData;
                    }
                    
                    //平台选中
                    if (delegate && [delegate respondsToSelector:@selector(didSelectedSocialPlatform:withSocialData:)])
                    {
                        [delegate didSelectedSocialPlatform:snsName withSocialData:shareContent];
                    }
                    
                    if (shareContent)
                    {
                        //分享操作
                        [[SocialAPIManager sharedInstance] shareContent:shareContent toPlatform:snsType];
                    }
                }
            }
        }
    }];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[SocialAPIManager sharedInstance] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark -
- (void)showFaceToFacePage:(NSString *)linkURL
{
    KSFaceToFaceVC *ftfVC = [[KSFaceToFaceVC alloc] initWithLinkURL:linkURL];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ftfVC];
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}
@end
