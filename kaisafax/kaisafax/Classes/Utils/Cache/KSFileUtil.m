//
//  KSFileUtil.m
//  kaisafax
//
//  Created by Jjyo on 16/8/17.
//  Copyright © 2016年 深圳深信金融服务有限公司. All rights reserved.
//

#import "KSFileUtil.h"
#define DOC_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
@implementation KSFileUtil

+ (void)saveFile:(NSString *)filename data:(NSDictionary *)json
{
    NSString *filePath = [DOC_PATH stringByAppendingPathComponent:filename];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:json];
    if (![data writeToFile:filePath atomically:YES]) {
        ERROR(@"%@ save failed", filename);
    }
}
+ (NSDictionary *)openFile:(NSString *)filename
{
    NSString *filePath = [DOC_PATH stringByAppendingPathComponent:filename];
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
+ (NSData *)openResouceFile:(NSString *)filename ofType:(NSString *)ext
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:ext];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (void)removeFile:(NSString *)filename
{
    NSString *filePath = [DOC_PATH stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
