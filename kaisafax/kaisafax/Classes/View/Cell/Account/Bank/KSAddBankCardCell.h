//
//  KSAddBankCardCell.h
//  kaisafax
//
//  Created by semny on 16/12/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBaseCell.h"

#define KAddBankCardCell  @"KSAddBankCardCell"

@protocol KSAddBankCardCellDelegate<NSObject>

-(void)toPlusBankCards;

@end

@interface KSAddBankCardCell : KSBaseCell

@property (nonatomic,weak) id<KSAddBankCardCellDelegate> delegate;

@end
