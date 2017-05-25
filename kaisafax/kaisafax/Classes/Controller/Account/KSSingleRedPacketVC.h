//
//  KSSingleRedPacketVC.h
//  sxfax
//
//  Created by philipyu on 16/2/24.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"


@interface KSSingleRedPacketVC :KSNVBackVC
@property (nonatomic,copy) NSString *status;
@property (nonatomic,assign) KSWebSourceType type;
@end
