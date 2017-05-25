//
//  KSUpdateView.h
//  kaisafax
//
//  Created by semny on 16/8/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KSUpdateView;

@protocol UpdateViewDelegate <NSObject>
@optional

- (void)updateViewOther:(KSUpdateView *)updateView;

- (void)updateViewCancel:(KSUpdateView *)updateView;

@end

@interface KSUpdateView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UIButton *otherBtn;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopLayoutConstraint;

//是否需要隐藏标志
@property (assign, nonatomic) BOOL needClose;

//最大高度尺寸(暂时只需要考虑高度)
@property (assign, nonatomic) CGFloat maxHeight;

@property (weak, nonatomic) id<UpdateViewDelegate> delegate;

@end
