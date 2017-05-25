//
//  KSInvestHeaderView.h
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kInvestHeaderView @"KSInvestHeaderView"

@interface KSInvestHeaderView : UITableViewHeaderFooterView


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (copy, nonatomic) NSArray *tags;

- (CGFloat)getPerfectHeightFittingSize:(CGSize)size;

@end
