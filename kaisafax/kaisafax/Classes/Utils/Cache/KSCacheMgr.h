//
//  KSCacheMgr.h
//
//
//  Created by Semny on 14-5-4.
//
//

#import <Foundation/Foundation.h>

//图片缓存时间
static const NSInteger KSCacheMaxCacheAge = 60*60*24*7;
static const NSInteger KSCacheMaxCacheSize = 20*1024*1024;
static const NSInteger KSCacheMaxCacheCount = 50;

#define KSCacheFullNamespace    @"com.sq.cache."
#define KSCacheQuenueName       "com.sq.cache"

//清理缓存完成的通知名称
#define KCleanCompletedNotificationName   @"KSCleanCompletedNotificationName"

@interface KSCacheMgr : NSObject

#pragma mark - 版本升级后的临时处理方案，将老数据迁移
+ (BOOL)moveOldData;

#pragma mark -共享文件路径相关方法
/**
 *  获取系统的共享文件夹的路径
 *
 *  @return 分享的路径
 */
+ (NSString *)getSysSharedPath;

+ (NSString *)getSysSharedPathBy:(NSString *)pathKey __deprecated_msg("Method deprecated. 只是用来处理老数据迁移");

/**
 *  获取基本的分享路径
 *
 *  @return 分享的路径
 */
+ (NSString *)getBaseSharedPath;

#pragma mark - 数据库缓存路径
+ (NSString *)getDBFilePath;

#pragma mark - 缓存相关的方法
/**
 *  获取最基本的缓存路径，所有的缓存数据存储在这
 *
 *  @return 缓存路径url字符串
 */
+ (NSString *)getSysCachePath;

#pragma mark ----新的缓存路径相关方法---------
/**
 *  获取最基本的缓存路径，所有的缓存数据存储在这
 *
 *  @return 缓存路径url字符串
 */
+ (NSString *)getBaseCachePath;

/**
 *  判断是否为文件夹
 *
 *  @param path 文件路径
 *
 *  @return YES：文件夹，NO：文件/不存在
 */
+ (BOOL)isDirectoryForPath:(NSString *)path;

#pragma mark ------清理APP的缓存数据-----
/**
 *  清理固定路径下的数据
 *
 *  @param basePath 制定要清理数据的路径
 *
 *  @return 是否操作成
 */
+ (BOOL) clearAllDataInPath:(NSString *)basePath;

/**
 *  清除APP使用时所留下的缓存，主要包含三部分内存，数据库缓存，图片缓存，其他文件缓存，共享文件夹缓存
 *
 *  @return 清除成功与否
 */
+ (BOOL) clearAllData;

/**
 *  获取app缓存的大小
 *
 *  @return 缓存大小，以M为单位
 */
+ (double) getAppCacheSize;

#pragma mark -----图片缓存------
/**
 *  获取图片的缓存目录
 *
 *  @return 缓存图片路径
 */
+ (NSString *)getImagesCachePath;

/**
 *  根据资源名称获取资源路径
 *
 *  @param fileName 资源名称
 *
 *  @return 资源路径
 */
+ (NSString *)getImagesCachePathBy:(NSString *)fileName;

//#pragma mark -----AD图片缓存------
///**
// *  获取AD图片的缓存目录
// *
// *  @return 缓存AD图片路径
// */
//+ (NSString *)getADImagesCachePath;
//
///**
// *  根据资源名称获取资源路径
// *
// *  @param fileName 资源名称
// *
// *  @return 资源路径
// */
//+ (NSString *)getADImagesCachePathBy:(NSString *)fileName;

#pragma mark -----视频缓存------
/**
 *  获取视频的缓存目录
 *
 *  @return 缓存视频路径
 */
//+ (NSString *)getVideosCachePath;

/**
 *  根据资源名称获取视频的缓存目录
 *
 *  @param fileName 资源名称
 *
 *  @return 缓存视频路径
 */
//+ (NSString *)getVideosCachePathBy:(NSString *)fileName;

#pragma mark - SDWebImage默认缓存
///**
// *  根据文件的url获取缓存的文件key
// *
// *  @param url 文件url
// *
// *  @return 缓存的文件key
// */
//+ (NSString *)cacheKeyForURL:(NSURL *)url
//{
//    return [[SQImageCacheManager sharedManager] cacheKeyForURL:url];
//}
/**
 *  存储图片数据
 *
 *  @param image 图片资源
 *  @param url   图片URL
 */
+ (void)storeImage:(UIImage *)image forURL:(NSURL *)url;

/**
 *  获取缓存的图片
 *
 *  @param url 图片URL
 *
 *  @return 缓存的图片对象
 */
+ (UIImage *)getCacheImageByURL:(NSURL *)url;

/**
 *  根据key存储图片
 *
 *  @param image 图片资源
 *  @param key   key
 */
+ (void)storeImage:(UIImage *)image forKey:(NSString *)key;

/**
 *  获取缓存的图片
 *
 *  @param key 图片key
 *
 *  @return 缓存的图片对象
 */
+ (UIImage *)getCacheImageByKey:(NSString *)key;

/**
 *  清理缓存的图片数据(包括内存和disk里面的数据)
 *
 *  @param url 图片URL
 */
+ (void)clearImageForURL:(NSURL *)url;

/**
 *  清理缓存的图片数据(只包括内存)
 *
 *  @param url 图片URL
 */
+ (void)clearMemoryImageForURL:(NSURL *)url;

@end
