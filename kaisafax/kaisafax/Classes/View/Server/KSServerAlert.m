//
//  KSServerAlert.m
//  kaisafax
//
//  Created by semny on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSServerAlert.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Masonry/Masonry.h>

@interface KSServerAlert()<MBProgressHUDDelegate>

@property (nonatomic, weak) MBProgressHUD *updateAlert;
@property (nonatomic, assign) BOOL isShowHUD;

@end

@implementation KSServerAlert

+ (KSServerAlert *)sharedInstance
{
    static KSServerAlert * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KSServerAlert alloc]init];
    });
    return instance;
}

- (void)showServerPopupWindowWith:(NSString*)comment1 comment2:(NSString *)comment2 comment3:(NSString *)comment3 actionTitle:(NSString *)actionTitle delegate:(id<ServerStatusViewDelegate>)delegate
{
    if (_updateAlert && !_updateAlert.isHidden && _isShowHUD)
    {
        [_updateAlert hide:NO];
        _updateAlert = nil;
        _isShowHUD = NO;
    }
    
    //主window
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = application.keyWindow;
    //弹出框
    MBProgressHUD *alertView = [MBProgressHUD showHUDAddedTo:window animated:YES];
    alertView.delegate = self;
    _updateAlert = alertView;
    //外框背景颜色(默认丑死)
    alertView.color = [UIColor clearColor];
    //alertView.bezelView.color = [UIColor clearColor];;
    alertView.mode = MBProgressHUDModeCustomView;
    //蒙层
    alertView.dimBackground = YES;
    //alertView.backgroundView.color = UIColorFromHexA(0x000000, 0.8f);
    //最大高度
    CGFloat maxHeight = window.frame.size.height*3/5;
    
    //自定义更新视图
    KSServerStatusView *updateView = ViewFromNib(NSStringFromClass(KSServerStatusView.class), 0);
    updateView.maxHeight = maxHeight;
    updateView.delegate = delegate;

//    updateView.commentLabel1.text = comment1;
    updateView.commentLabel2.text = comment1;
    NSAttributedString *comment = [self createTurn2Phone:comment2 phone:comment3];
    updateView.commentLabel3.attributedText = comment;
    
    //操作按钮
    [updateView.actionBtn setTitle:actionTitle forState:UIControlStateNormal];
    [updateView.actionBtn setTitle:actionTitle forState:UIControlStateSelected];
    
    //自定义更新view赋值给alert内容视图
    alertView.customView = updateView;
    _isShowHUD = YES;
}

- (void)hiddenServerPopupWindow
{
    if (!_updateAlert || _updateAlert.isHidden || !_isShowHUD)
    {
        return;
    }
    [_updateAlert hide:YES];
    _isShowHUD = NO;
}

- (NSAttributedString *)createTurn2Phone:(NSString *)text phone:(NSString *)phone
{
    DEBUGG(@"%s", __FUNCTION__);
    //文字
    NSString *text1 = text;
    NSString *text2 = phone;
    NSString *allStr = [NSString stringWithFormat:@"%@%@",text1, text2];
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:allStr];
    
    //灰色文字
    NSInteger length1 = text1.length;
    NSDictionary *text1Dict = @{NSForegroundColorAttributeName:UIColorFromHex(0X929292), NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range1 = NSMakeRange(0, length1);
    [textString addAttributes:text1Dict range:range1];
    
    //橙色文字
    NSInteger length2 = text2.length;
    UIColor *orangeColor = UIColorFromHex(0Xee7700);
    NSDictionary *text2Dict = @{NSLinkAttributeName:@"Turn2RegisterString", NSForegroundColorAttributeName:orangeColor, NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range2 = NSMakeRange(length1, length2);
    [textString addAttributes:text2Dict range:range2];
    
    //第一行向右缩进
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 10;//增加行高
    style.headIndent = 20;//头部缩进，相当于左padding
    style.tailIndent = -20;//相当于右padding
    style.alignment = NSTextAlignmentLeft;//对齐方式
    style.firstLineHeadIndent = 40;//首行头缩进
    [textString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, allStr.length)];
    
    // 1. 创建一个"高亮"属性，当用户点击了高亮区域的文本时，"高亮"属性会替换掉原本的属性
    YYTextBorder *highlightBorder = [YYTextBorder borderWithFillColor:orangeColor cornerRadius:3];
    YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
    [highlight setColor:[UIColor whiteColor]];
    [highlight setBackgroundBorder:highlightBorder];
    @WeakObj(self);
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect)
    {
        NSString *phone = [text.string substringWithRange:range];
        //跳转注册页面
        [weakself callPhone: phone];
    };
    [textString yy_setTextHighlight:highlight range:range2];
    
    return textString;
}

- (void)callPhone:(NSString *)phone
{
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark - update delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    _isShowHUD = NO;
}

#pragma mark - 计算尺寸
- (CGSize)calculateDescriptionSizeWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    if (!font)
    {
        font = [UIFont systemFontOfSize:14.0f];
    }
    NSDictionary *dic = @{NSFontAttributeName: font};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, 1000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:dic
                                       context:nil].size;
    size.height += 5.0f;
    
    return size;
}

@end
