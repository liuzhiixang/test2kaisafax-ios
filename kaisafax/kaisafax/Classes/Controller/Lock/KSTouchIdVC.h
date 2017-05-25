//
//  KSTouchIdVC.h
//  kaisafax
//
//  Created by semny on 16/11/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBaseVC.h"

//指纹解锁
@interface KSTouchIdVC : KSNVBaseVC

//设置结束block
@property (nonatomic, copy) void(^touchIDCheckFinishBlock)(UIViewController *vc, NSInteger actionType, NSError *error);

@end
