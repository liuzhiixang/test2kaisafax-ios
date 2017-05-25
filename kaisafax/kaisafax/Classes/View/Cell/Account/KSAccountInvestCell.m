//
//  KSAccountInvestCell.m
//  kaisafax
//
//  Created by BeiYu on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInvestCell.h"
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

@interface KSAccountInvestCell()
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratetipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *daytipLabel;

@property (weak, nonatomic) IBOutlet UILabel *amoutLabel;

@property (weak, nonatomic) IBOutlet UILabel *amouttipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *datetipLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodtipLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitLabel;
@property (weak, nonatomic) IBOutlet UILabel *profittipLabel;
- (IBAction)jumpToPlan:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *planBtn;
@property (strong, nonatomic) KSUIItemEntity *entity;
@end

@implementation KSAccountInvestCell

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
    self.daytipLabel.text =KDueTimeTitle;
    self.amouttipLabel.text= KInvestmentTitle;
    self.datetipLabel.text = KInvestTimeTitle;
    self.methodtipLabel.text =  KRepayMethodTitle;
    self.profittipLabel.text =  KCollectInterestTitle;
    
    NSInteger status = entity.invest.status;
    if (status == KSDoInvestStatusLoaned/*[statusStr isEqualToString:@"LOANED"]*/)
    {
        self.planBtn.hidden = NO;
    }
    else
    {
        self.planBtn.hidden = YES;
    }
    
    // 标的名称
    self.nameLabel.text = entity.loan.title;
    // 年化收益
    CGFloat rate = entity.loan.rate/100.0;
    self.rateLabel.text = [KSUIItemEntity formatRate:rate];
    
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
    self.amoutLabel.text = [KSBaseEntity formatAmount:(CGFloat)entity.invest.amount withUnit:KUnit];
    
    NSDate *date = entity.invest.investTime;
    if(!date || [date isEqual:NULL] || [date isEqual:[NSNull null]])
    {
        self.dateLabel.text = @"- -";
 
    }
    else
    {
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        format.dateFormat = @"yyyy-MM-dd";
        self.dateLabel.text = [format stringFromDate:date];
    }
    
//    NSDictionary *dict = REPAY_METHOD;
    self.methodLabel.text = entity.loan.getRepayMethodText;
    
    //已还清
    if (status == KSDoInvestStatusCleared /*[statusStr isEqualToString:@"CLEARED"]*/)
    {
        self.profittipLabel.text = KEarnedIncomeTitle;
        self.profitLabel.text = [KSBaseEntity formatAmountString:entity.totalProfit withUnit:KUnit];//[NSString stringWithFormat:@"%.2f元",entity.totalProfit];
    }
    else
    {
        

        //还款中
        if (status == KSDoInvestStatusLoaned /*[statusStr isEqualToString:@"LOANED"]*/)
        {
            self.profittipLabel.text = KCollectInterestTitle;
            self.profitLabel.text =[KSBaseEntity formatAmountString:entity.undueAmount withUnit:KUnit];// [NSString stringWithFormat:@"%.2f元",(CGFloat)entity.undueAmount];
        }
        else
        {
            //投标中
            self.profitLabel.hidden = YES;
            self.profittipLabel.hidden = YES;

        }
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
@end
