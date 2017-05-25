//
//  KSRedPacketActivedCell.m
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSRedPacketActivedCell.h"
#import "KSRewardItemEntity.h"
#import "KSRedPackageEntity.h"
#import "NSDate+Utilities.h"
#import "KSConst.h"

#define  kRatio   0.85
@interface KSRedPacketActivedCell()
//
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
//
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;

@end

@implementation KSRedPacketActivedCell

-(void)updateItem:(KSRewardItemEntity*)entity
{
    
    INFO(@"%@",NSStringFromCGRect(self.frame));

    NSInteger packType = entity.pack.type;
    if (packType ==CASH)
    {
        self.typeLabel.text = @"现金券";
    }else{
        self.typeLabel.text = @"投资返现";
    }
    
    self.quantityLabel.textColor = NUI_HELPER.appOrangeColor;
    self.quantityLabel.text = [NSString stringWithFormat:@"￥ %.2f", entity.originalBonus ];
//
    if (isIPhone5x)
    {
        self.quantityLabel.font = [UIFont systemFontOfSize:20.0];
    }else{
        self.quantityLabel.font = [UIFont systemFontOfSize:25.0];
    }
//
    NSMutableAttributedString *rateStr = [[NSMutableAttributedString alloc]initWithString:self.quantityLabel.text];
    [rateStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:12.0]
                    range:NSMakeRange(0, 1)];
    self.quantityLabel.attributedText = rateStr;
    self.nameLabel.text = entity.pack.name;
    //self.dueLabel.text = @"激活日期";
    
    if (packType == CASH)
    {
        self.dateLabel.text = [NSDate stringFromDate:entity.allocatedTime];
        self.conditionLabel.hidden = YES;
        self.dueLabel.hidden = YES;
    }else{
//            NSDateFormatter *format = [[NSDateFormatter alloc]init];
//            format.dateFormat = @"yyyy-MM-dd";
            self.dateLabel.text = [NSDate stringFromDate:entity.invokedTime];//[entity.invokedTime shortDateString]/*[format stringFromDate:entity.invokedTime]*/;

            self.dueLabel.text = @"激活项目";
            //重构我的红包-红包列表接口删除掉的数据
        
            if (entity.target && entity.target.objectId)
            {
                self.conditionLabel.text = [NSString stringWithFormat:@"%@",entity.target.objectId];
                self.conditionLabel.hidden = NO;
                self.dueLabel.hidden = NO;
            }
            else
            {
                self.dueLabel.hidden = YES;
                self.conditionLabel.hidden = YES;
            }
        
    }


//    if( [self.nameLabel.text isEqualToString:@"首投红包"])
//    {
//        self.conditionLabel.text = @"一投即送";
//    }
    
    //self.conditionLabel.text = entity.target.objectId;

}

@end
