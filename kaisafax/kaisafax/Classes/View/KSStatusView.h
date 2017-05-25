//
//  KSStatusView.h
//  kaisafax
//
//  Created by Jjyo on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KSStatusStyle) {
    KSStatusStyleNormal,//默认
    KSStatusStyleProgress, //投标中
    KSStatusStyleStatus, //状态
};


@interface KSStatusView : UIView

@property (nonatomic, assign) KSStatusStyle statusStyle;

@property (nonatomic, assign) CGFloat progressLineWidth;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) NSUInteger statusArcAngle;

@property(nonatomic, copy) NSString *statusText;
@property(nonatomic, copy) NSString *progressText;
@property(nonatomic, strong) UIColor *progressTintColor;
@property(nonatomic, strong) UIColor *trackTintColor;
@property(nonatomic, strong) UIColor *disableColor;

@property (nonatomic, assign) NSUInteger textSize;
@property (nonatomic, strong) UIColor *textColor;


@property (nonatomic, assign, getter=isDisable) BOOL disable;

@end
