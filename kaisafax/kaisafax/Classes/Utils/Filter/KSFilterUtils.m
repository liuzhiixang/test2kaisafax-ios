//
//  KSFilterUtils.m
//  kaisafax
//
//  Created by philipyu on 16/9/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSFilterUtils.h"
#import "KSVersionMgr.h"

#define kFilterFalse   @"false"
#define kFilterUsed    @"used"



@implementation KSFilterUtils
//创建单例
+ (instancetype)sharedInstance
{
    static KSFilterUtils *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[KSFilterUtils alloc] init];
    });
    
    return obj;
}

-(instancetype)init
{
    if (self = [super init])
    {

    }
    return self;
}

-(id)pickupValidBanner:(id)item Platform:(NSArray*)platformTypes Versions:(NSArray*)appVersions Channels:(NSArray*)appChannels Status:(NSString*)status
{
    if (!item ||
        !platformTypes ||
        !appChannels ||
        !appVersions) return nil;
    
    NSString *platform = @"";//[kPlatformTypeValue lowercaseString];
    NSString *localVer = [[KSVersionMgr sharedInstance] getVersionName];
    NSString *channelID = [kChannelVID lowercaseString];
    
    BOOL isChannelRight = FALSE;
    BOOL isVersionRight = FALSE;
    BOOL isPlatformRight = FALSE;
    
    {
        if (status && [status isEqualToString:kFilterFalse])
        {
            return nil;
        }
        
        {
            
            for (NSString *str in appChannels)
            {
                NSString *lowerchar = [str lowercaseString];
                if ([lowerchar isEqualToString:channelID] ||
                    [lowerchar isEqualToString:@"all"])
                {
                    isChannelRight = TRUE;
                }
            }
            
            for (NSString *str in appVersions)
            {
                NSString *lowerchar = [str lowercaseString];
                if ([lowerchar isEqualToString:localVer] ||
                    [lowerchar isEqualToString:@"all"])
                {
                    isVersionRight = TRUE;
                }
            }
            
            for (NSString *str in platformTypes)
            {
                NSString *lowerchar = [str lowercaseString];
                if ([lowerchar isEqualToString:platform] ||
                    [lowerchar isEqualToString:@"all"])
                {
                    isPlatformRight = TRUE;
                }
            }
            
            if (isChannelRight &&
                isVersionRight &&
                isPlatformRight)
            {
                // 适用于banner
                if (!status)
                {
                    return item;
                }
                else
                {
                    //适用于notice
                    status = [status lowercaseString];
                    if ([status isEqualToString:kFilterUsed])
                    {
                        return item;
                    }
                    else
                    {
                        return nil;
                    }
                }
                return nil;
                
            }
            else
            {
                return nil;
            }

        }
    }

}
@end
