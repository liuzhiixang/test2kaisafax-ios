//
//  SocialEntity.h
//  kaisafax
//
//  Created by semny on 16/8/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SocialUrlResourceTypeDefault,             //无
    SocialUrlResourceTypeImage,               //图片
    SocialUrlResourceTypeVideo,               //视频
    SocialUrlResourceTypeMusic,                //音乐
    SocialUrlResourceTypeWeb,                //网页
    SocialUrlResourceTypeCount
}SocialUrlResourceType;

@interface SocialEntity : NSObject

//标识每个不同`SocialEntity`对象的字符串
@property (nonatomic, readonly) NSString *identifier;

//报表title,不同`SocialEntity`实例的title，在报表中可看到对应分享操作的title
@property (nonatomic, copy) NSString *title;

//分享的内嵌文字
@property (nonatomic, copy) NSString * shareText;

//用于用户在评论并分享的时候，该字段内容会自动添加到评论的后面，分享到各个分享平台
@property (nonatomic, copy) NSString * commentText;

//分享的内嵌图片,可以传入`UIImage`或者`NSData`类型
@property (nonatomic, strong) id shareImage;
@property (nonatomic, strong) NSURL *shareImageURL;

//用于用户在评论并分享的时候，该字段内容会自动添加到评论中的图片，分享到各个分享平台
@property (nonatomic, retain) UIImage * commentImage;

//url地址
@property (nonatomic, copy) NSString *url;

//资源类型，图片（SocialUrlResourceTypeImage）、视频（SocialUrlResourceTypeVideo），音乐（SocialUrlResourceTypeMusic）
@property (nonatomic, assign) SocialUrlResourceType resourceType;

/**
 初始化一个`SocialEntity`对象
 
 @param identifier 一个`SocialEntity`对象的标识符，相同标识符的`SocialEntity`拥有相同的属性
 
 @return return 初始化的`SocialEntity`对象
 */
- (id)initWithIdentifier:(NSString *)identifier;

/**
 初始化一个`SocialEntity`对象
 
 @param identifier 一个`SocialEntity`对象的标识符，相同标识符的`SocialEntity`拥有相同的属性
 
 @param title 对每个对象的描述，在报表端显示分享、评论等操作对应的title
 
 @return return 初始化的`SocialEntity`对象
 */
- (id)initWithIdentifier:(NSString *)identifier withTitle:(NSString *)title;
@end
