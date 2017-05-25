//
//  KSRedPacketInactiveCell.m
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSRedPacketInactiveCell.h"
#import "KSRewardItemEntity.h"
#import "KSRedPackageEntity.h"
#import "KSConst.h"

#define  kRatio   0.85
@interface KSRedPacketInactiveCell()
//
@property (weak, nonatomic) IBOutlet UILabel *amoutLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *conditionalLabel;

@end

@implementation KSRedPacketInactiveCell


-(void)updateItem:(KSRewardItemEntity*)entity
{
    if (!entity) return;
    
     NSInteger packType = entity.pack.type;
    
    if (packType == CASH)
    {
        self.typeLabel.text = @"现金券";
    }
    else if(packType == REDBAG)
    {
        self.typeLabel.text = @"投资返现";
    }
    self.amoutLabel.text = [NSString stringWithFormat:@"￥ %.2f", entity.originalBonus ];
    self.amoutLabel.textColor = NUI_HELPER.appOrangeColor;

    if (isIPhone5x)
    {
        self.amoutLabel.font = [UIFont systemFontOfSize:20.0];
    }
    else
    {
        self.amoutLabel.font = [UIFont systemFontOfSize:25.0];
    }
    
    NSMutableAttributedString *rateStr = [[NSMutableAttributedString alloc]initWithString:self.amoutLabel.text];
    [rateStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0]
                        range:NSMakeRange(0, 1)];
    self.amoutLabel.attributedText = rateStr;
    self.nameLabel.text = entity.pack.name;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";

    self.dateLabel.text =[format stringFromDate:entity.expiredTime];


    if([self.nameLabel.text isEqualToString:@"首投红包"])
    {
        self.conditionalLabel.text = @"一投即送";
    }else{
        //actualBonus
    self.conditionalLabel.text =  [NSString stringWithFormat:@"单笔投资满%.2f元",[entity.actualBonus floatValue]*200];
        
    }
}

@end
