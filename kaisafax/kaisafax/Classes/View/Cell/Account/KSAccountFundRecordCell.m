//
//  KSAccountFundRecordCell.m
//  kaisafax
//
//  Created by BeiYu on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountFundRecordCell.h"
#import "KSUserFRItemEntity.h"
#import "KSAccountFundRecordModel.h"
#import "KSBaseEntity.h"
#import "KSConst.h"
#import "NSDate+Utilities.h"
#import "NSMutableString+CommaAdd.h"

#define fundTypeDict  @{@10:@"投资",@20:@"提现",@21:@"提现手续费",@22:@"提现服务费",\
                   @30:@"充值",@31:@"充值手续费",\
                   @40:@"借款",@41:@"借款担保费",@42:@"借款服务费",\
                   @50:@"还款",@53:@"资金管理费",@54:@"逾期罚息",@55:@"违约金",\
@120:@"回款",@121:@"利息管理费",@122:@"逾期罚息",@123:@"提前结清违约金",\
@60:@"垫付",@61:@"还垫付",\
@70:@"债权转让",@71:@"债权转让手续费",\
@80:@"转账",@81:@"平台向用户转账",@82:@"平台子账户转账",@83:@"奖励",\
@100:@"冻结",@110:@"解冻",@201:@"生利宝"\
}


@interface KSAccountFundRecordCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@end
@implementation KSAccountFundRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateItem:(KSAccountFundRecordModel *)item clearSeprator:(BOOL)isClear
{
//    if (!item || !item.data) return;
    NSDate *date = item.data.recordTime;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy.MM.dd HH:mm";
    NSString *dateStr = [format stringFromDate:date];
    
    INFO(@"%@",item.data.recordTime);
    self.dateLabel.text = [dateStr substringWithRange:NSMakeRange(5, 5)];
    self.weekLabel.text = [date toWeekString];
    self.dateLabel.hidden = !item.isShowDate;
    self.weekLabel.hidden = !item.isShowDate;
    
    self.typeLabel.text = [fundTypeDict objectForKey:[NSNumber numberWithInt:(int)item.data.type]];
    self.timeLabel.text = [dateStr substringFromIndex:(dateStr.length-5)];
//
    NSString *operation = item.data.isIn?@"+":@"-";
    
    NSString *formatStr = [KSBaseEntity formatAmount:item.data.amount withUnit:@""];
    //    大于10亿转为万
    if (item.data.amount >= 1000000000.00)
    {
        NSInteger wan = item.data.amount/10000;
        long amount =(long) item.data.amount;
        NSInteger after2b = (NSInteger)amount%10000/100;
//        formatStr = [KSBaseEntity formatAmount:[wanStr floatValue] withUnit:@"万"];
        NSString *wanStr = [NSString stringWithFormat:@"%ld.%02ld",wan ,(long)after2b];
        formatStr = (NSString *)[NSMutableString CommaAddWithStr:wanStr dotStatus:YES];
        formatStr = [NSString stringWithFormat:@"%@万",formatStr];
    }
    self.amountLabel.text= [NSString stringWithFormat:@"%@ %@",operation,formatStr];

    self.amountLabel.textColor = [operation isEqualToString:@"-"]?UIColorFromHex(0x2ccf7c):NUI_HELPER.appOrangeColor;
    
    if (isClear)
    {
        self.sepView.hidden = YES;
    }
    else
    {
        self.sepView.hidden = NO;
    }
    
}

@end
