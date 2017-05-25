//
//  KSCacheMgr.m
//  semny
//
//  Created by Semny on 14-5-4.
//
//

#import "KSCacheMgr.h"
#import "NSData+Additions.h"
#ifdef KSDBHELPER_H
#import "KSDBHelper.h"
#endif
#import "SDWebImageManager.h"

@implementation KSCacheMgr

#pragma mark - 版本升级后的临时处理方案，将老数据迁移
+ (BOOL)moveOldData
{
    BOOL flag = YES;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //老图片缓存
    NSString *imagesPath = [self getOldImagesCachePath];
    if ([fileMgr fileExistsAtPath:imagesPath])
    {
        NSString *newImagesPath = [self getImagesCachePath];
        flag = flag&[fileMgr copyItemAtPath:imagesPath toPath:newImagesPath error:nil];
        [fileMgr removeItemAtPath:imagesPath error:nil];
    }
    
    //老视频缓存
    NSString *videosPath = [self getOldVideosCachePath];
    if ([fileMgr fileExistsAtPath:videosPath])
    {
//        NSString *newVideosPath = [self getVideosCachePath];
//        flag = flag&[fileMgr copyItemAtPath:videosPath toPath:newVideosPath error:nil];
//        [fileMgr removeItemAtPath:videosPath error:nil];
    }
    
    //老DB缓存
    NSString *DBPath = [self getOldDBCachePath];
    if ([fileMgr fileExistsAtPath:DBPath])
    {
        NSString *newDBPath = [self getDBCachePath];
        flag = flag&[fileMgr copyItemAtPath:DBPath toPath:newDBPath error:nil];
        [fileMgr removeItemAtPath:DBPath error:nil];
    }
    
    return flag;
}

+ (NSString *)getOldImagesCachePath  __deprecated_msg("Method deprecated. 只是用来处理老数据迁移")
{
    // Init the disk cache
    NSString *diskCachePath = [[self class] getSysCachePathBy:@"Images"];
    return diskCachePath;
}

+ (NSString *)getOldVideosCachePath __deprecated_msg("Method deprecated. 只是用来处理老数据迁移")
{
    // Init the disk cache
    NSString *diskCachePath = [[self class] getSysCachePathBy:@"Videos"];
    return diskCachePath;
}

+ (NSString *)getOldDBCachePath __deprecated_msg("Method deprecated. 只是用来处理老数据迁移")
{
    // Init the disk cache
    NSString *diskCachePath = [[self class] getSysCachePathBy:@"DB"];
    return diskCachePath;
}

#pragma mark -共享文件路径相关方法
+ (NSString *)getSysSharedPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diskSharedPath = [paths objectAtIndex:0];
    return diskSharedPath;
}

+ (NSString *)getSysSharedPathBy:(NSString *)pathKey __deprecated_msg("Method deprecated. 只是用来处理老数据迁移")
{
    NSString *diskCachePath = [[self class] getSysSharedPath];
    if (!pathKey || pathKey.length <= 0)
    {
        return diskCachePath;
    }
    diskCachePath = [diskCachePath stringByAppendingPathComponent:pathKey];
    return diskCachePath;
}

+ (NSString *)getBaseSharedPath
{
    NSString *diskSharedPath = [[self class] getSysSharedPath];
    diskSharedPath = [diskSharedPath stringByAppendingPathComponent:@"SharedVideo"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskSharedPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskSharedPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return diskSharedPath;
}

/**
 *  清理共享文件夹下的数据
 *
 *  @return 是否清理成功
 */
+ (BOOL)clearSharedData
{
    BOOL resultVal = YES;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *diskSharedPath = [[self class] getSysSharedPath];
    if (![fileMgr removeItemAtPath:diskSharedPath error:NULL])
    {
        //清空共享文件夹操作失败
        if ([fileMgr fileExistsAtPath:diskSharedPath]  && resultVal)
        {
            resultVal = NO;
        }
    }
    INFO(@"%s <<>> resultVal: %d", __FUNCTION__ , resultVal);
    return resultVal;
}

#pragma mark - 数据库缓存路径
+ (NSString *)getDBCachePath
{
    NSString *databasePath = [self  getBaseCachePathBy:@"DB"];
    return databasePath;
}

+ (NSString *)getDBFilePath
{
    NSString *dbCachePathBy = [self  getBaseCachePathBy:@"DB"];
    //获取项目名称
    NSString *executableFile = [self getExecutableFile];
    NSString *dbFileMD5String = [[executableFile dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
#if DEBUG
    NSString *databasePath = [NSString stringWithFormat:@"%@",[dbCachePathBy stringByAppendingFormat:@"/%@.db",dbFileMD5String]];
#else
    NSString *databasePath = [NSString stringWithFormat:@"%@",[dbCachePathBy stringByAppendingFormat:@"/%@",dbFileMD5String]];
#endif
    return databasePath;
}

/**
 *  获取项目名称
 *
 *  @return 项目名称
 */
+ (NSString *)getExecutableFile
{
    //获取项目名称
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    return executableFile;
}

#pragma mark - 缓存相关的方法
/**
 *  获取最基本的缓存路径，所有的缓存数据存储在这
 *
 *  @return 缓存路径url字符串
 */
+ (NSString *)getSysCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [paths objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return diskCachePath;
}

+ (NSString *)getSysCachePathBy:(NSString *)pathKey __deprecated_msg("Method deprecated. 只是用来处理老数据迁移")
{
    NSString *diskCachePath = [[self class] getSysCachePath];
    if (!pathKey || pathKey.length <= 0)
    {
        return diskCachePath;
    }
    diskCachePath = [diskCachePath stringByAppendingPathComponent:pathKey];
    return diskCachePath;
}

#pragma mark ----新的缓存路径相关方法---------
/**
 *  获取APP的缓存路径
 *
 *  @return 缓存路径
 */
+ (NSString *)getBaseCachePath
{
    NSString *pathKey = @"Private";
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *diskCachePath = [paths objectAtIndex:0];
//    diskCachePath = [diskCachePath stringByAppendingPathComponent:pathKey];
    
    NSString *diskCachePath = [self getSysSharedPathBy:pathKey];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return diskCachePath;
}

/**
 *  根据基础路径创建获取子路径
 *
 *  @param pathKey 子路径名称
 *
 *  @return 创建获取子路径
 */
+ (NSString *)getBaseCachePathBy:(NSString *)pathKey
{
    // Init the disk cache
    NSString *diskCachePath = [[self class] getBaseCachePath];
    if (!pathKey || pathKey.length <= 0)
    {
        return diskCachePath;
    }
    diskCachePath = [diskCachePath stringByAppendingPathComponent:pathKey];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return diskCachePath;
}

/**
 *  清理缓存路径的数据
 *
 *  @return 是否操作成功
 */
+ (BOOL)clearCachedData
{
    BOOL resultVal = YES;
    
    NSString *baseCachePath = [[self class] getSysCachePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    resultVal = [self clearAllData:fileMgr inPath:baseCachePath];
    INFO(@"%s <<>> resultVal: %d", __FUNCTION__ , resultVal);
    return resultVal;
}

/**
 *  如果该路径为文件夹，则清理指定路径下的文件,如果为文件，直接删除
 *
 *  @param fileMgr  文件管理
 *  @param path     路径
 *
 *  @return 是否操作成功
 */
+ (BOOL)clearAllData:(NSFileManager *)fileMgr inPath:(NSString*)path
{
    INFO(@"%s, basePath: %@", __FUNCTION__, path);
    BOOL clearFlag = YES;
    if (!fileMgr)
    {
        return clearFlag;
    }
    
    //判断文件路径
    if (path && [fileMgr fileExistsAtPath:path])
    {
        BOOL isDirectory = [[self class] isDirectoryForPath:path];
        if(isDirectory)
        {
            NSError *error = nil;
            NSArray *contents = [fileMgr contentsOfDirectoryAtPath:path error:&error];
            NSEnumerator *enumerator = [contents objectEnumerator];
            NSString *filename = nil;
            INFO(@"%s, path111: %@ <<>> contents: %@ <<>> error: %@", __FUNCTION__, path, contents, error);
            while ((filename = [enumerator nextObject]))
            {
                //遍历清理子路径和文件
                INFO(@"%s, path222: %@ <<>> filename: %@", __FUNCTION__, path, filename);
                NSString *currentPath = [path stringByAppendingPathComponent:filename];
                //删除当前路径文件
                BOOL flag = [fileMgr removeItemAtPath:currentPath error:NULL];
                //clearFlag = clearFlag&[fileMgr removeItemAtPath:currentPath error:NULL];
                INFO(@"%s, isDirectory clearFlag: %d <<>> path: %@", __FUNCTION__, clearFlag, currentPath);
                if (!flag)
                {
                    //清理不成功，判断是不是文件夹，如果是则删除子文件
                    BOOL isDirectory2 = [[self class] isDirectoryForPath:currentPath];
                    INFO(@"%s, isDirectory2 : %d <<>> path: %@", __FUNCTION__, isDirectory2, currentPath);
                    if (isDirectory2)
                    {
                        INFO(@"%s, isDirectory5 clearFlag: %d <<>> path: %@", __FUNCTION__, clearFlag, currentPath);
                        clearFlag = [[self class] clearAllData:fileMgr inPath:currentPath];
                        INFO(@"%s, isDirectory2 clearFlag: %d <<>> path: %@", __FUNCTION__, clearFlag, currentPath);
                    }
                    else
                    {
                        INFO(@"%s, isDirectory4 clearFlag: %d <<>> path: %@", __FUNCTION__, clearFlag, currentPath);
                        clearFlag &= flag;
                        break;
                    }
                }
            }
        }
        else
        {
            //遍历清理子路径和文件
            clearFlag = clearFlag&[fileMgr removeItemAtPath:path error:NULL];
            INFO(@"%s, isDirectory3 clearFlag: %d <<>> path: %@", __FUNCTION__, clearFlag, path);
        }
    }
    
    return clearFlag;
}

/**
 *  判断是否为文件夹
 *
 *  @param path 文件路径
 *
 *  @return YES：文件夹，NO：文件/不存在
 */
+ (BOOL)isDirectoryForPath:(NSString *)path
{
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    INFO(@"%s, isExist: %d <<>> path: %@", __FUNCTION__, isExist, path);
    if(isExist && isDirectory)
    {
        INFO(@"%s, isDirectory333: %d <<>> path: %@", __FUNCTION__, isDirectory, path);
        isDirectory = YES;
    }
    INFO(@"%s, isDirectory222: %d <<>> path: %@", __FUNCTION__, isDirectory, path);
    return isDirectory;
}

#pragma mark ------清理APP的缓存数据-----
+ (BOOL) clearAllDataInPath:(NSString *)basePath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    return [self clearAllData:fileMgr inPath:basePath];
}

+ (BOOL) clearAllData
{
    BOOL resultVal = YES;
    
#ifdef KSDBHelper_H
    INFO(@"%s <<>> cleear db", __FUNCTION__ );
    //业务缓存数据
    [KSDBHelper clearDBCachedData:^(id result, NSError *error) {
        BOOL flag = [result boolValue];
        if (!flag) {
            //清空数据库操作失败
        }
    }];
#endif
    
    //缓存路径的数据清理
    resultVal = resultVal&[[self class] clearCachedData];
    
    //共享路径的数据清理
    resultVal = resultVal&[[self class] clearSharedData];
    
    return resultVal;
}

//获取缓存大小，只包含缓存图片的大小
+ (double) getAppCacheSize
{
    NSString *cachePath = [[self class] getBaseCachePath];
    NSString *sharedPath = [[self class] getSysSharedPath];
    
    double cacheSize = [[self class] folderSizeAtPath:cachePath];
    double sharedSize = [[self class] folderSizeAtPath:sharedPath];
    return cacheSize+sharedSize;
}

//遍历文件夹获得文件夹大小，返回多少M
+ (double) folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
    {
        return 0;
    }
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([manager fileExistsAtPath:fileAbsolutePath]){
            folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
            INFO(@"%s, fileAbsolutePath: %@, folderSize: %lld", __FUNCTION__, fileAbsolutePath, folderSize);
        }
    }
    return folderSize/(1024.0f*1024.0f);
}

#pragma mark -----图片缓存------
//图片缓存目录
+ (NSString *)getImagesCachePath
{
    // Init the disk cache
    NSString *diskCachePath = [[self class]  getBaseCachePathBy:@"Images"];
    return diskCachePath;
}

//图片缓存目录
+ (NSString *)getImagesCachePathBy:(NSString *)fileName
{
    if (!fileName || fileName.length <= 0)
    {
        return nil;
    }
    
    NSString *diskCachePath = [[self class] getImagesCachePath];
    diskCachePath = [diskCachePath stringByAppendingPathComponent:fileName];
    return diskCachePath;
}

//#pragma mark -----AD图片缓存------
///**
// *  获取AD图片的缓存目录
// *
// *  @return 缓存AD图片路径
// */
//+ (NSString *)getADImagesCachePath
//{
//    // Init the disk cache
//    NSString *diskCachePath = [[self class] getBaseCachePathBy:@"ADImages"];
//    return diskCachePath;
//}
//
///**
// *  根据资源名称获取资源路径
// *
// *  @param fileName 资源名称
// *
// *  @return 资源路径
// */
//+ (NSString *)getADImagesCachePathBy:(NSString *)fileName
//{
//    if (!fileName || fileName.length <= 0)
//    {
//        return nil;
//    }
//    
//    NSString *diskCachePath = [[self class] getADImagesCachePath];
//    diskCachePath = [diskCachePath stringByAppendingPathComponent:fileName];
//    return diskCachePath;
//}

#pragma mark - SDWebImage默认缓存
/**
 *  根据文件的url获取缓存的文件key
 *
 *  @param url 文件url
 *
 *  @return 缓存的文件key
 */
+ (NSString *)cacheKeyForURL:(NSURL *)url
{
    return [[SDWebImageManager sharedManager] cacheKeyForURL:url];
}

+ (void)storeImage:(UIImage *)image forURL:(NSURL *)url
{
    if (!url || !image)
    {
        return;
    }
    
    NSString *key = [[self class] cacheKeyForURL:url];
    if (!key || key.length <= 0)
    {
        return;
    }
    
    INFO(@"%s, url: %@", __FUNCTION__, url);
    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:key toDisk:YES];
}

+ (UIImage *)getCacheImageByURL:(NSURL *)url
{
    if (!url)
    {
        return nil;
    }
    
    NSString *key = [[self class] cacheKeyForURL:url];
    if (!key || key.length <= 0)
    {
        return nil;
    }
    
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
    return image;
}

+ (void)storeImage:(UIImage *)image forKey:(NSString *)key
{
    if (!key || key.length <= 0 || !image)
    {
        return;
    }
    
    INFO(@"%s, key: %@", __FUNCTION__, key);
    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:key toDisk:YES];
}

+ (UIImage *)getCacheImageByKey:(NSString *)key
{
    if (!key || key.length <= 0)
    {
        return nil;
    }
    
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
    return image;
}

+ (void)clearImageForURL:(NSURL *)url fromDisk:(BOOL)fromDisk
{
    if (!url)
    {
        return;
    }
    
    NSString *key = [[self class] cacheKeyForURL:url];
    if (!key || key.length <= 0)
    {
        return;
    }
    
    INFO(@"%s, fromDisk: %d", __FUNCTION__, fromDisk);
    if (fromDisk)
    {
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
    }
    else
    {
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:key fromDisk:NO];
    }
}

+ (void)clearMemoryImageForURL:(NSURL *)url
{
    [[self class] clearImageForURL:url fromDisk:NO];
}

+ (void)clearImageForURL:(NSURL *)url
{
    [[self class] clearImageForURL:url fromDisk:YES];
}

@end
