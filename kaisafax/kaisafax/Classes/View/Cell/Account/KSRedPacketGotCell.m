//
//  KSRedPacketGotCell.m
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSRedPacketGotCell.h"
#import "KSRewardItemEntity.h"
#import "KSRedPackageEntity.h"
#import "KSConst.h"
#import "NSDate+Utilities.h"

#define  kRatio   0.85
@interface KSRedPacketGotCell()

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *getDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *getNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@end

@implementation KSRedPacketGotCell



-(void)updateItem:(KSRewardItemEntity*)entity
{

        //NSString *typeStr = entity.pack.type;
       NSInteger packType = entity.pack.type;
    
        if (packType == CASH)
        {
            self.typeLabel.text = @"现金券";
        }
        else if(packType == REDBAG)
        {
            self.typeLabel.text = @"投资返现";
        }

        self.quantityLabel.text = [NSString stringWithFormat:@"￥ %.2f", entity.originalBonus];
    //
        if (isIPhone5x)
        {
            self.quantityLabel.font = [UIFont systemFontOfSize:20.0];
        }
        else
        {
            self.quantityLabel.font = [UIFont systemFontOfSize:25.0];
        }
    //
        NSMutableAttributedString *rateStr = [[NSMutableAttributedString alloc]initWithString:self.quantityLabel.text];
        [rateStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0]
                        range:NSMakeRange(0, 1)];
        self.quantityLabel.attributedText = rateStr;
    self.quantityLabel.textColor = NUI_HELPER.appOrangeColor;

        self.getNameLabel.text = entity.pack.name;
    //

    
    self.getDateLabel.text =[NSDate stringFromDate:entity.withdrawTime];





    //
    //    if (kScreenHeight == 568)
    //    {
    //        self.imgWidthConstraint.constant = 355 * kRatio;
    //        self.imgHeightConstraint.constant  = 100 * kRatio;
    //        self.quaTopConstraint.constant = 16.0;
    //        self.getDateViewBotConstraint.constant = 16.0;
    //        self.quaWidthConstraint.constant = 81*kRatio;
    //        self.nameViewLeftConstraint.constant = 96 * kRatio;
    //        if([statusStr isEqualToString:@"EXPIRED"])
    //            self.nameViewTopConstraint.constant = 23.0;
    //        else
    //            self.nameViewTopConstraint.constant = 6.0;
    //    }
    //    else
    //    {
    //        self.imgWidthConstraint.constant = 355;
    //        self.imgHeightConstraint.constant  = 100;
    //        self.quaTopConstraint.constant = 26.0;
    //        self.getDateViewBotConstraint.constant = 31.0;
    //        self.quaWidthConstraint.constant = 81;
    //        self.nameViewLeftConstraint.constant = 96 ;
    //        if([statusStr isEqualToString:@"EXPIRED"])
    //           self.nameViewTopConstraint.constant = 34.0;
    //        else
    //           self.nameViewTopConstraint.constant = 19.0;
    //    }
}


@end
