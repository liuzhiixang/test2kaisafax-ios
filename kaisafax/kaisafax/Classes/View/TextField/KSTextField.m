//
//  KSTextField.m
//  kaisafax
//
//  Created by Jjyo on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSTextField.h"

// placeholder textcolor不可变的全局变量;
static NSString * const KPlaceholderColorKey = @"placeholderLabel.textColor";
static NSString * const KPlaceholderKey = @"placeholderLabel.hidden";

@interface KSTextField ()
{
    BOOL _isHaveDian;
    BOOL _isFirstZero;
}

//是否隐藏placeholder
@property (nonatomic, assign) BOOL placeholderHidden;
//placeholder的文字颜色
@property (nonatomic, strong) UIColor *placeholderTextColor;
//placeholder的文字字体
@property (nonatomic, strong) UIFont *placeholderTextFont;

@end

@implementation KSTextField


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}

- (void)setPlaceholderTextColor:(UIColor *)textColor
{
    _placeholderTextColor = textColor;
    [self setNeedsLayout];
}

- (void)setPlaceholderTextFont:(UIFont *)textFont
{
    _placeholderTextFont = textFont;
    [self setNeedsLayout];
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    _isHaveDian = [text rangeOfString:@"."].location!=NSNotFound;
    _isFirstZero = [text hasPrefix:@"0"];
}

/**
 *  @author semny
 *
 *  设置placeholder是否隐藏
 *
 *  @param hidden YES:隐藏，NO:显示
 */
- (void)setPlaceholderHidden:(BOOL)hidden
{
    _placeholderHidden = hidden;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //placeholder hidden
    [self setValue:[NSNumber numberWithBool:_placeholderHidden] forKeyPath:KPlaceholderKey];
    
    UIColor *textColor = _placeholderTextColor;
    if (textColor)
    {
        //[self setValue:textColor forKeyPath:KPlaceholderColorKey];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = textColor;
        if (self.placeholder)
        {
            NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:self.placeholder attributes:dict];
            
            [self setAttributedPlaceholder:attribute];
        }
    }
    
    UIFont *textFont = _placeholderTextFont;
    if (textFont)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSFontAttributeName] = textFont;
        if (self.placeholder)
        {
            NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:self.placeholder attributes:dict];
            [self setAttributedPlaceholder:attribute];
        }
    }
}

//处理快捷操作
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))//禁止粘贴
        return NO;
    if (action == @selector(select:))// 禁止选择
        return NO;
    if (action == @selector(selectAll:))// 禁止全选
        return NO;
    return [super canPerformAction:action withSender:sender];
}

#pragma mark -------- <UITextFieldDelegate>---------
//只能输入数字和小数点，保留两位小数点且0放在首位
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *oldText = textField.text;
    //限制输入最大长度
    if (_maxLength > 0 && range.location >= _maxLength)
    {
        return NO; // return NO to not change text
    }
    if (_maxValue > 0)
    {
        NSString *realValue = [NSString stringWithFormat:@"%@%@", oldText, string];
        if (realValue.floatValue > _maxValue) {
            return NO;
        }
    }
    
    if ([oldText rangeOfString:@"."].location==NSNotFound) {
        _isHaveDian = NO;
    }
    
    if ([oldText rangeOfString:@"0"].location==NSNotFound) {
        _isFirstZero = NO;
    }
    
    if ([string length]>0)
    {
        unichar single=[string characterAtIndex:0];//当前输入的字符
        if ((single >='0' && single<='9') || single=='.')//数据格式正确
        {
            if([oldText length]==0){
                if(single == '.'){
                    //首字母不能为小数点
                    return NO;
                }
                if (single == '0') {
                    _isFirstZero = YES;
                    return YES;
                }
            }
            
            if (single=='.'){
                if(!_isHaveDian)//text中还没有小数点
                {
                    _isHaveDian=YES;
                    return YES;
                }else{
                    return NO;
                }
            }else if(single=='0'){
                if ((_isFirstZero&&_isHaveDian)||(!_isFirstZero&&_isHaveDian)) {
                    //首位有0有.（0.01）或首位没0有.（10200.00）可输入两位数的0
                    if([oldText isEqualToString:@"0.0"]){
                        return NO;
                    }
                    NSRange ran=[oldText rangeOfString:@"."];
                    int tt=(int)(range.location-ran.location);
                    if (tt <= 2){
                        return YES;
                    }else{
                        return NO;
                    }
                }else if (_isFirstZero&&!_isHaveDian){
                    //首位有0没.不能再输入0
                    return NO;
                }else{
                    return YES;
                }
            }else{
                if (_isHaveDian){
                    //存在小数点，保留两位小数
                    NSRange ran=[oldText rangeOfString:@"."];
                    int tt= (int)(range.location-ran.location);
                    if (tt <= 2){
                        return YES;
                    }else{
                        return NO;
                    }
                }else if(_isFirstZero&&!_isHaveDian){
                    //首位有0没点
                    return NO;
                }else{
                    return YES;
                }
            }
        }else{
            //输入的数据格式不正确
            return NO;
        }
    }else{
        return YES;
    }
}

@end
