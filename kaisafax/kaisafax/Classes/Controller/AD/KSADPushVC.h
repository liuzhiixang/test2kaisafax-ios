//
//  KSADPushVC.h
//  kaisafax
//
//  Created by semny on 16/10/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBussinessItemEntity.h"
#import "KSBusinessEntity.h"

/**
 *  @author semny
 *
 *  服务端推送的广告启动页
 */
@interface KSADPushVC : UIViewController

@property (nonatomic, strong) KSBussinessItemEntity *bitemData;

@end
