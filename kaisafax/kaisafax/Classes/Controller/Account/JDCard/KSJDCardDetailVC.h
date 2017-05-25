//
//  KSJingDongCardDetailVC.h
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HYScratchCardView.h"
#import "KSNVBackVC.h"
#import "KSJDExtractItemEntity.h"
#import "PCBClickLabel.h"





@interface KSJDCardDetailVC : KSNVBackVC < KSBLDelegate >
{
    LGAlertView *_alertView;
    UILabel *pwdLabel;
    PCBClickLabel *eableClicklab;
}
@property(nonatomic,strong)KSJDExtractItemEntity  *entity;
@property(nonatomic,assign)int Section;

@end
