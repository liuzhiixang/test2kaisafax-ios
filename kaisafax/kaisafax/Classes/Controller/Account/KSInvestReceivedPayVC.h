//
//  KSInvestReceivedPayVC.h
//  KSfax
//
//  Created by philipyu on 16/3/10.
//  Copyright © 2016年 com.KSfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"

@interface KSInvestReceivedPayVC : KSNVBackVC
@property (nonatomic,assign) long long loanID;
@property (nonatomic,copy) NSString *loanTitle;
@end
