//
//  KSRedPacketOverdueCell.m
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSRedPacketOverdueCell.h"
#import "KSRewardItemEntity.h"
#import "KSRedPackageEntity.h"
#import "KSConst.h"

#define  kRatio   0.85
@interface KSRedPacketOverdueCell()

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation KSRedPacketOverdueCell



-(void)updateItem:(KSRewardItemEntity*)entity
{
    if (!entity) return;

       // NSString *typeStr = entity.pack.type;
       NSInteger packType = entity.pack.type;
    
        if (packType == CASH)
        {
            self.typeLabel.text = KCashTitle;
        }
        else if(packType == REDBAG)
        {
            self.typeLabel.text = KInvestmentReturnTitle;
        }
    //
    //    // 测试的字段跟app API不一致
    ////    self.quantityLabel.text = [NSString stringWithFormat:@"%.2f元", [rewardModel.pack.bonus doubleValue]];
        self.quantityLabel.text = [NSString stringWithFormat:@"￥ %.2f",entity.originalBonus ];
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
    

            self.nameLabel.text = entity.pack.name;
    

    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    
    self.dateLabel.text =[format stringFromDate:entity.expiredTime ];
    //        self.dateLabel.text =[NSDate dateWithIntervalTime:[rewardModel.expiredTime longLongValue] type:0];
    //        //设置为灰色图片
            self.quantityLabel.textColor = UIColorFrom255RGB(200, 200, 200);
            self.typeLabel.textColor = UIColorFrom255RGB(200, 200, 200);
            self.dateLabel.textColor = UIColorFrom255RGB(200, 200, 200);
    //
    //    }
    //    else if ([statusStr isEqualToString:@"INVOKED"])
    //    {
    //        //审核中的奖励
    //        self.nameView.hidden = YES;
    //        self.dateView.hidden = NO;
    //        self.conditionView.hidden = YES;
    //        self.getDateModelLabel.hidden = YES;
    //        self.getDateLabel.hidden = YES;
    //        self.getNameLabel.hidden = YES;
    //        self.dateLabel.hidden = YES;
    //        self.daoQiRiLabel.text = @"审核中";
    //    }
    //
    //    if([self.getNameLabel.text isEqualToString:@"首投红包"] ||
    //       [self.nameLabel.text isEqualToString:@"首投红包"])
    //    {
    ////        self.conditionView.hidden = YES;
    //        self.conditionLabel.text = @"一投即送";
    //    }
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
