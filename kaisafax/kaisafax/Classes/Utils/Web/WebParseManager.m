//
//  WebParseManagerUtil.m
//  kaisafax
//
//  Created by philipyu on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "WebParseManager.h"
#import "KSConst.h"

#define kIOSLength      ((kLength(@"ios:")+2))
#define kLength(str)   (str.length)
#define kAmountLength (kLength(@"amount:"))
#define kActionLength (kLength(@"action:"))

@implementation WebParseManager

//创建单例
+ (instancetype)sharedInstance
{
    static WebParseManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[WebParseManager alloc] init];
    });
    
    return obj;
}

-(instancetype)init
{
    if (self = [super init])
    {
        NSString *path = PathForPlist(@"ControllerMapConfig");
        _parseDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

-(NSDictionary *)parse:(NSString*)jsonStr
{
//     NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutableDict = nil;
    
    NSString *jsonString = [[self class] changeJsonStringToTrueJsonString:jsonStr];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    
    if (dict && dict.count > 0)
    {
        mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mutableDict[kResult] = [dict objectForKey:kiOS];
        
        /**
         *  @author semny
         *
         *  将内层解析出来
         */
        NSDictionary *dataDict = dict[kData];
        if (dataDict && dataDict.count > 0)
        {
            //删除冗余的data
            [mutableDict removeObjectForKey:kData];
            //将data内层的数据解析出来
            [mutableDict addEntriesFromDictionary:dataDict];
        }
    }
    
    return mutableDict;
}

//把没有双引号和用了单引号的json字符串转化为标准格式字符串;
+ (NSString *)changeJsonStringToTrueJsonString:(NSString *)json
{
    if(!json || json.length <= 0)
    {
        return nil;
    }
    json = [json stringByReplacingOccurrencesOfString:@" " withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //json = [json stringByReplacingOccurrencesOfString:@"'" withString:@""];
    
    NSLog(@"111: %@", json);
    // 将没有双引号的替换成有双引号的
    NSString *validString = [json stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^A-Za-z0-9_])"
                                                            withString:@"\"$1\":$2"
                                                               options:NSRegularExpressionSearch
                                                                 range:NSMakeRange(0, [json length])];
    
    NSLog(@"222: %@", validString);
    
    //把'单引号改为双引号"
    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])'"
                                                         withString:@"$1\""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    NSLog(@"333: %@", validString);
    validString = [validString stringByReplacingOccurrencesOfString:@"'([:\\],\\}])"
                                                         withString:@"\"$1"
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    
    NSLog(@"444: %@", validString);
    //再重复一次 将没有双引号的替换成有双引号的
    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:"
                                                         withString:@"$1\"$2\":"
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    //    validString = [validString stringByReplacingOccurrencesOfString:@":\\s*(\\w+)([\\],\\}])"
    //                                                         withString:@":\"$1\"$2"
    //                                                            options:NSRegularExpressionSearch
    //                                                              range:NSMakeRange(0, [validString length])];
    validString = [validString stringByReplacingOccurrencesOfString:@":\\s*([\\w+]*)([,，。.]*)([\\w+]*)([,，。.]*)([0-9]*)([\\],\\}])" withString:@":\"$1$2$3$4$5\"$6" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
    //    [a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+
    NSLog(@"555: %@", validString);
    return validString;
}

@end
