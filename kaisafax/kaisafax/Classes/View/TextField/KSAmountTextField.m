//
//  KSAmountTextField.m
//  kaisafax
//
//  Created by Jjyo on 2016/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAmountTextField.h"
#import "KSBaseEntity.h"
#import <objc/runtime.h>
@interface KSAmountTextField()<UITextFieldDelegate>


@end

@implementation KSAmountTextField


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}



- (NSInteger)getAmount
{
    NSString *text = [self.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    return text.integerValue;
}

- (void)setText:(NSString *)text
{
    NSString *formatText = [KSBaseEntity formatAmountNotFloat:[text stringByReplacingOccurrencesOfString:@"," withString:@""].integerValue];
    [super setText:formatText];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = text;
    return NO;
}


@end
