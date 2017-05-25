//
//  KSAccountInvestView.h
//  kaisafax
//
//  Created by okline.kwan on 16/12/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultAccountInvestViewHeight 118
#define kAccountInvestView @"KSAccountInvestView"
@class KSAccountInvestView;
@class KSLoanItemEntity;
@protocol KSAccountInvestViewDelegate <NSObject>

- (void)investView:(KSAccountInvestView *)investView updateHeight:(CGFloat)height;
- (void)investView:(KSAccountInvestView *)investView didSelectEntity:(KSLoanItemEntity *)entity;

@end


@interface KSAccountInvestView : UICollectionReusableView
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) id<KSAccountInvestViewDelegate> delegate;

@property (nonatomic, copy) NSArray *loanItemList;

@end
