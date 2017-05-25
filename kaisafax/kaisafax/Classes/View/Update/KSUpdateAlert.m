//
//  KSUpdateAlertView.m
//  kaisafax
//
//  Created by semny on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUpdateAlert.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Masonry/Masonry.h>

@interface KSUpdateAlert()<MBProgressHUDDelegate>

@property (nonatomic, weak) MBProgressHUD *updateAlert;
@property (nonatomic, assign) BOOL isShowHUD;

@end

@implementation KSUpdateAlert

+ (KSUpdateAlert *)sharedInstance
{
    static KSUpdateAlert * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KSUpdateAlert alloc]init];
    });
    return instance;
}

- (void)showUpdatePopupWindowWithVersion:(NSString*)version title:(NSString *)title description:(NSString *)description actionTitle:(NSString *)actionTitle close:(BOOL)showClose delegate:(id<UpdateViewDelegate>)delegate
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
    UIView *mainSubView = window.rootViewController.view;
    UIView *rootView = mainSubView;
    if (!rootView)
    {
        rootView = window;
    }
    //弹出框
    MBProgressHUD *alertView = [MBProgressHUD showHUDAddedTo:rootView animated:YES];
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
    KSUpdateView *updateView = ViewFromNib(NSStringFromClass(KSUpdateView.class), 0);
    updateView.maxHeight = maxHeight;
    updateView.delegate = delegate;
    
    //title信息
    updateView.titleLabel.text = title;
    
    //描述信息
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 2;//增加行高
    style.firstLineHeadIndent = 15;//首行头缩进
    style.headIndent = 15;//非换行的首行 头部缩进，相当于左padding
    style.tailIndent = -15;//相当于右padding
    style.alignment = NSTextAlignmentLeft;//对齐方式
    NSMutableAttributedString *descStr = nil;
    if(description)
    {
        descStr = [[NSMutableAttributedString alloc] initWithString:description];
    }
    [descStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, descStr.length)];
    [descStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, descStr.length)];
    [descStr addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0xA0A0A0) range:NSMakeRange(0, descStr.length)];
    DEBUGG(@"descStr: %@", descStr);
    [updateView.descriptionView setAttributedText:descStr];
    
    //判断版本
    if (!version || version.length <= 0)
    {
        updateView.versionLabel.hidden = YES;
    }
    else
    {
        updateView.versionLabel.hidden = NO;
        updateView.versionLabel.text = version;
    }
    
    //是否需要关闭
    updateView.needClose = showClose;
    //判断是否显示关闭按钮
    if (showClose)
    {
        updateView.closeBtn.hidden = NO;
        updateView.topLineView.hidden = NO;
    }
    else
    {
        updateView.closeBtn.hidden = YES;
        updateView.topLineView.hidden = YES;
    }
    
    //操作按钮
    [updateView.otherBtn setTitle:actionTitle forState:UIControlStateNormal];
    [updateView.otherBtn setTitle:actionTitle forState:UIControlStateSelected];
    //自定义更新view赋值给alert内容视图
    alertView.customView = updateView;
    _isShowHUD = YES;
}

- (void)hiddenUpdatePopupWindow
{
    if (!_updateAlert || _updateAlert.isHidden || !_isShowHUD)
    {
        return;
    }
    [_updateAlert hide:YES];
    _isShowHUD = NO;
}

#pragma mark - update delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    _isShowHUD = NO;
}

@end
