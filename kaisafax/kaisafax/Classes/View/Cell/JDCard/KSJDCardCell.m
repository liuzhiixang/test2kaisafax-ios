//
//  KSJDCardCell.m
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardCell.h"

#import "KSJDExtractItemEntity.h"

#import "NSDate+Utilities.h"

@implementation KSJDCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    font-size: 48;
//    font-color: @appLightRedColor;
   // @appLightRedColor:#cb1426 /*深红色京东金额颜色*/
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateItem:(KSJDExtractItemEntity*)entity
{
 
    _moneyCardLabel.text = [NSString stringWithFormat:@"¥ %.0f",entity.amount.doubleValue];
    
    UIImage * cardImage;
    
    switch (entity.status) {
            
        case 0:
            cardImage = LoadImage(@"account_jingdong_in_card");
            break;
        case 1:
            cardImage = LoadImage(@"account_jingdong_card_suceess");
            break;
            
        case 2:
            cardImage = LoadImage(@"account_jingdong_card_fail");
            _moneyCardLabel.nuiClass = NUIAppCellLargeLightGrayLabel;
            break;
        
            
        default:
            cardImage = LoadImage(@"account_jingdong_card_suceess");
            
            break;
    }
    
    self.cardStatusImageView.image = cardImage;
    
   

    
     _receiveTimeLabel.text =[NSString stringWithFormat:@"领取时间: %@",[entity.createTime dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss"]] ;
   
}
//-(void)updateItem:(KSUIItemEntity *)entity index:(NSInteger)index
//{
//     _entity = entity;
//    UIImage * cardImage;
//    
//    switch (index) {
//        case 1:
//            cardImage = LoadImage(@"account_jingdong_card_suceess");
//            break;
//            
//        case 2:
//            cardImage = LoadImage(@"account_jingdong_card_fail");
//            _moneyCardLabel.nuiClass = NUIAppCellLargeLightGrayLabel;
//            break;
//        case 3:
//            cardImage = LoadImage(@"account_jingdong_in_card");
//            break;
//            
//        default:
//            cardImage = LoadImage(@"account_jingdong_card_suceess");
//            
//            break;
//    }
//    
//    self.cardStatusImageView.image = cardImage;
//    
//   }
@end
