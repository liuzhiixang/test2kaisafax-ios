//
//  KSNBankCardCell.m
//  kaisafax
//
//  Created by semny on 16/12/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNBankCardCell.h"
#import "KSCardItemEntity.h"
#import "UIImageView+WebCache.h"

@interface KSNBankCardCell()
@property (nonatomic,strong) KSCardItemEntity *entity;
@property (weak, nonatomic) IBOutlet UIImageView *bankImg;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UIImageView *payTypeImg;

@property (weak, nonatomic) IBOutlet UIButton *unbindBtn;
//- (IBAction)unbindBtnClick:(UIButton *)sender;

@end

@implementation KSNBankCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.unbindBtn setTitle:KUnbindBankCardTitle forState:UIControlStateNormal];
    [self.unbindBtn setTitle:KUnbindBankCardTitle forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)updateItem:(KSCardItemEntity*)entity
{
    if (!entity)
    {
        return;
    }
    
    //实体数据
    _entity = entity;
    
    //银行icon
    [self.bankImg sd_setImageWithURL:[NSURL URLWithString: entity.bankIconUrl] placeholderImage:nil options:0];
    
    //银行卡
    NSString *bankName = entity.bankName;
    if (!bankName || bankName.length <= 0)
    {
        self.bankNameLabel.hidden = YES;
    }
    //银行名称 & 用户名
    self.bankNameLabel.text = bankName;
    
    //储蓄卡
    NSString *bankCardTypeName = KBankDebitCardTitle;
    //用户名
    NSString *bankUserName = entity.name;
    if (bankUserName)
    {
        NSMutableString *bankUserNameMS = [bankUserName mutableCopy];
        [bankUserNameMS replaceCharactersInRange:NSMakeRange(0, 1) withString:@"*"];
        [bankUserNameMS insertString:@" " atIndex:0];
        [bankUserNameMS insertString:bankCardTypeName atIndex:0];
        bankCardTypeName = bankUserNameMS;
    }
    self.typeLabel.text = bankCardTypeName;
    
    //判断是否为快捷卡
    if (entity.express)
    {
        //快捷支付
        self.payTypeImg.image = LoadImage(@"ic_bank_type_express");
        self.payTypeImg.hidden = NO;
        //隐藏解绑按钮
        self.unbindBtn.hidden = YES;
    }
    else if (entity.defaultAccount)
    {
        //默认卡
        self.payTypeImg.image = LoadImage(@"ic_bank_type_normal");
        self.payTypeImg.hidden = NO;
        //隐藏解绑按钮
        self.unbindBtn.hidden = YES;
    }
    else
    {
        //显示解绑按钮
        self.unbindBtn.hidden = NO;
        //隐藏标志
        self.payTypeImg.hidden = YES;
    }
    //卡号格式化
    //防止因为传过来的account为空，导致崩溃
    if([entity.account isEqualToString:@""] ||
       entity.account == nil ||
       entity.account.length < 4 ||
       [entity.account isKindOfClass:[NSNull class]])

    {
        self.cardNumLabel.text = @"";
    }
    else
    {
        NSString *first4Str = [entity.account substringToIndex:4];
        NSString *last4Str = [entity.account substringFromIndex:entity.account.length-4];
        self.cardNumLabel.text = [NSString stringWithFormat:@"%@  ****  ****  %@",first4Str,last4Str];
    }

}

- (IBAction)unbindBtnClick:(UIButton *)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(unbindBankCard:)])
    {
        [self.delegate unbindBankCard:self.entity];
    }
}

@end
