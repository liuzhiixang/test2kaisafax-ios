//
//  KSFileUtil.h
//  kaisafax
//
//  Created by Jjyo on 16/8/17.
//  Copyright © 2016年 深圳深信金融服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSFileUtil : NSObject

+ (void)saveFile:(NSString *)filename data:(NSDictionary *)json;
+ (NSDictionary *)openFile:(NSString *)filename;
+ (NSData *)openResouceFile:(NSString *)filename ofType:(NSString *)ext;
+ (void)removeFile:(NSString *)filename;

@end
