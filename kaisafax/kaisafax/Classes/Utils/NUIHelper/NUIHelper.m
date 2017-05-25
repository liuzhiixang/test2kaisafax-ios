//
//  NUIHelper.m
//  kaisafax
//
//  Created by Jjyo on 16/9/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "NUIHelper.h"



#define APP_COLORS @{  \
                @"_appOrangeColor": @"orange-color", \
                @"_appDarkGrayColor": @"dark-color", \
                @"_appBorderColor": @"border-color",\
                @"_appBackgroundColor": @"background-color",\
                @"_appLightGrayColor": @"light-gray-color",\
                @"_appNavigationBarTintColor": @"navigation-bar-tint-color",\
                @"_appDisableColor" : @"disable-color", \
                @"END": @"END"\
                    }

#define APP_DIMENS @{ \
                @"_appXXSmallFontSize": @"xx-small-font-size", \
                @"_appXSmallFontSize": @"x-small-font-size", \
                @"_appSmallFontSize": @"small-font-size", \
                @"_appNormalFontSize": @"normal-font-size", \
                @"_appLargeFontSize": @"large-font-size", \
                @"_appXLargerFontSize": @"x-larger-font-size", \
                @"_appXXLargerFontSize": @"xx-larger-font-size", \
                @"_appCornerRadius": @"corner-radius", \
                @"": @"", \
                @"END": @"END" \
            }


@implementation NUIHelper



+ (instancetype)shareInstance
{
    static NUIHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUIHelper alloc]init];
    });
    return  instance;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *nuiClass = @"AppGlobal";
        //colors
        for (NSString *key in APP_COLORS.allKeys) {
            NSString *nuiProerty = APP_COLORS[key];
            if ([NUISettings hasProperty:nuiProerty withClass:nuiClass]) {
                UIColor *color = [NUISettings getColor:nuiProerty withClass:nuiClass];
                [self setValue:color forKey:key];
            }
        }
        //dimens
        for (NSString *key in APP_DIMENS.allKeys) {
            NSString *nuiProerty = APP_DIMENS[key];
            if ([NUISettings hasProperty:nuiProerty withClass:nuiClass]) {
                CGFloat value = [NUISettings getFloat:nuiProerty withClass:nuiClass];
                [self setValue:@(value) forKey:key];
            }
        }
    }
    return self;
}


@end
