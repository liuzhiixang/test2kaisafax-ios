//
//  KSNBankCardCell.h
//  kaisafax
//
//  Created by semny on 16/12/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBaseCell.h"

#define KNBankCardsCell  @"KSNBankCardCell"
@class KSCardItemEntity;

@protocol KSNBankCardCellDelegate<NSObject>

@optional
-(void)unbindBankCard:(KSCardItemEntity*)card;
@end

@interface KSNBankCardCell : KSBaseCell
@property (nonatomic,weak) id<KSNBankCardCellDelegate> delegate;
-(void)updateItem:(KSCardItemEntity*)entity;

@end
