//
//  KNSemiModalViewController.m
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>

@interface UIViewController (KNSemiModalInternal)
-(UIView*)parentTarget;
@end

@implementation UIViewController (KNSemiModalInternal)

-(UIView*)parentTarget {
  // To make it work with UINav & UITabbar as well
  UIViewController * target = self;
  while (target.parentViewController != nil) {
    target = target.parentViewController;
  }
  return target.view;
}
@end

@implementation UIViewController (KNSemiModal)

-(void)presentSemiViewController:(UIViewController*)vc {
  [self presentSemiView:vc.view];
}

-(void)presentSemiView:(UIView*)vc {
  // Determine target
  UIView * target = [self parentTarget];
  
  if (![target.subviews containsObject:vc]) {
    // Calulate all frames
    CGRect sf = vc.frame;
    CGRect vf = target.frame;
    CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
    CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);

    // Add semi overlay
    UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];
    overlay.backgroundColor = UIColorFromHexA(0x000000, 0.3);
    
    // Begin overlay animation
    [UIView animateWithDuration:kSemiModalAnimationDuration - 0.1 animations:^{
          [[[UIApplication sharedApplication].delegate window] addSubview:overlay];
    }];

    // Dismiss button
    // Don't use UITapGestureRecognizer to avoid complex handling
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton addTarget:self action:@selector(dismissSemiModalView) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = of;
    [overlay addSubview:dismissButton];

    // Present view animated
    vc.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
    vc.layer.shadowColor = [[UIColor blackColor] CGColor];
    vc.layer.shadowRadius = 5.0;
    vc.layer.shadowOpacity = 0.5;
    [overlay addSubview:vc];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        vc.frame = f;
    }];
  }
}

-(void)dismissSemiModalView {
    UIView *target = [self parentTarget];
    UIView *overlay = [[[UIApplication sharedApplication].delegate window].subviews lastObject];
    UIView *modal = [overlay.subviews objectAtIndex:1];

    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
        overlay.backgroundColor = UIColorFromHexA(0x000000, 0.0);
    } completion:^(BOOL finished) {
        [modal removeFromSuperview];
        [overlay removeFromSuperview];
    }];}

@end
