//
//  UIView+Round.h
//  kaisafax
//
//  Created by Jjyo on 16/7/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Round)

- (void)makeCorners:(UIRectCorner)corners radius:(CGFloat)radius;
- (void)makeRoundCorner;
@end
