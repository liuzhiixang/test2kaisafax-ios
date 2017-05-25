//
//  KSAccountInvestClearCell.m
//  kaisafax
//
//  Created by BeiYu on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInvestClearCell.h"
#import "KSUIItemEntity.h"
#import "KSLoanItemEntity.h"
#import "KSInvestItemEntity.h"
#import "NSDate+Utilities.h"
#import "NSString+Format.h"
#import "KSBaseEntity.h"


//#define REPAY_METHOD @{ @"INTEREST" :           @"先息后本", \
//@"EQUAL_INSTALLMENT" :  @"等额本息", \
//@"EQUAL_PRINCIPAL" :    @"等额本金", \
//@"BULLET_REPAYMENT" :   @"一次性还款"  \
//}

@interface KSAccountInvestClearCell()
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratetipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *daytipLabel;

@property (weak, nonatomic) IBOutlet UILabel *amoutLabel;
//还清日期
@property (weak, nonatomic) IBOutlet UILabel *clearDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearTipLabel;

@property (weak, nonatomic) IBOutlet UILabel *amouttipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *datetipLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodtipLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitLabel;
@property (weak, nonatomic) IBOutlet UILabel *profittipLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) KSUIItemEntity *entity;

@end

@implementation KSAccountInvestClearCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)updateItem:(KSUIItemEntity*)entity
{
    _entity = entity;
    self.ratetipLabel.text = KAnnualInterestRateTitle;
    self.daytipLabel.text = KDueTimeTitle;
    self.amouttipLabel.text= KInvestmentTitle;
    self.datetipLabel.text = KInvestTimeTitle;
    self.methodtipLabel.text =  KRepayMethodTitle;
    self.profittipLabel.text =  KCollectInterestTitle;
    self.clearTipLabel.text = KPayOffTimeTitle;
    


    // 标的名称
    self.nameLabel.text = entity.loan.title;
    // 年化收益
    CGFloat rate = entity.loan.rate/100.0;
    self.rateLabel.text = [KSUIItemEntity formatRate:rate];
//    KSUnitType type = entity.loan.duration.unitType;
//    if (type == KSUnitMonth)
//        self.dayLabel.text = [NSString stringWithFormat:@"%ld 个月",entity.loan.duration.value];
//    else if (type == KSUnitDay)
//        self.dayLabel.text = [NSString stringWithFormat:@"%ld 天",entity.loan.duration.value];
    KSUnitType type = entity.invest.duration.unitType;
    NSInteger value = entity.invest.duration.value;
    if (type == KSUnitMonth)
    {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld 个月",(long)value];
    }
    else if (type == KSUnitDay)
    {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld 天",(long)value];
    }
    else
    {
        self.dayLabel.text = nil;
    }
//    self.amoutLabel.text = [NSString stringWithFormat:@"%.2f 元",(CGFloat)entity.invest.amount];
    self.amoutLabel.text = [KSBaseEntity formatAmount:(CGFloat)entity.invest.amount withUnit:@"元"];
    
    NSDate *date = entity.invest.investTime;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    
    if(!date || [date isEqual:NULL] || [date isEqual:[NSNull null]])
    {
        self.dateLabel.text = @"- -";
    }
    else
    {
        self.dateLabel.text = [format stringFromDate:date];
    }
    
    
    NSDate *clearDate = entity.loan.clearTime;
    if(!clearDate || [clearDate isEqual:NULL] || [clearDate isEqual:[NSNull null]])
    {
        self.clearDateLabel.text = @"- -";
    }
    else
    {
        self.clearDateLabel.text = [format stringFromDate:clearDate];
    }
    
//    NSDictionary *dict = REPAY_METHOD;
    self.methodLabel.text =  entity.loan.getRepayMethodText;//[dict objectForKey:entity.invest.repayMethod];
    
    
    NSInteger status = entity.invest.status;
    
    //已还清
    if (status == KSDoInvestStatusCleared /*[statusStr isEqualToString:@"CLEARED"]*/)
    {
        self.profittipLabel.text = KEarnedIncomeTitle;
        self.profitLabel.text = [KSBaseEntity formatAmountString: entity.totalProfit withUnit:KUnit];//[NSString stringWithFormat:@"%.2f元",entity.totalProfit];
    }

    
//    添加了利息桔色字体
    if(!self.profitLabel.hidden)
    {
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:self.profitLabel.text];
    
    UIColor *orangeColor = NUI_HELPER.appOrangeColor;
    NSDictionary *attr2Dict = @{NSForegroundColorAttributeName:orangeColor} ;
    NSRange range = NSMakeRange(0, self.profitLabel.text.length-1);
    [attributeStr addAttributes:attr2Dict range:range];
    self.profitLabel.attributedText = attributeStr;
    }
    
//    self.profitLabel.text = [NSString stringWithFormat:@"%.2f 元",(CGFloat)entity.undueAmount];
    

   
}

- (IBAction)jumpToPlan:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(accountInvestCellWithLoanID:)]) {
        [self.delegate accountInvestCellWithLoanID:_entity];
    }
}
- (IBAction)showContract:(id)sender {
    if ([_delegate respondsToSelector:@selector(showContractFromEntity:)]) {
        [_delegate showContractFromEntity:_entity];
    }
}


@end
