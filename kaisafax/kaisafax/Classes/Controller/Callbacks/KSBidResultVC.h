//
//  KSBidResultVC.h
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"

@interface KSBidResultVC : KSNVBackVC
@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *result;
@property (nonatomic,copy) NSString *respDesc;
@property (nonatomic,copy) NSString *respCode;
@property (nonatomic,assign) NSInteger type;
@end
