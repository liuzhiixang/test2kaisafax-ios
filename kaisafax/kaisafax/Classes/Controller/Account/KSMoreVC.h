//
//  KSMoreVC.h
//  kaisafax
//
//  Created by semny on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
//更多里面的条目
typedef NS_ENUM(NSInteger,KSMoreID)
{
    KSMoreIDNone = 0,
    KSMoreIDAboutUS,   //关于我们
    KSMoreIDSafety,    //安全保障
    KSMoreIDQuestion,  //疑问
    KSMoreIDHotline,   //客服热线
    KSMoreIDMax,
};

@interface KSMoreVC : KSNVBackVC

@end
