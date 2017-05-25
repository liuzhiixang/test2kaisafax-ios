//
//  KSNewbeeCell.h
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseCell.h"

#define kNewbeeCell @"KSNewbeeCell"

#import "KSNewbeeEntity.h"

@interface KSNewbeeCell : KSBaseCell

- (void)updateItem:(KSNewbeeEntity *)entity;
@property (weak, nonatomic) IBOutlet UIButton *investButton;

@end
