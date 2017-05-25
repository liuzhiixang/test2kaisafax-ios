//
//  UINavigationBar+Additions.m
//  kaisafax
//
//  Created by Jjyo on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "UINavigationBar+Additions.h"
#import <objc/runtime.h>

static const void *translucentKey = &translucentKey;

@implementation UINavigationBar (Additions)


- (void)hideBottomHairline {
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = YES;
}

- (void)showBottomHairline {
    // Show 1px hairline of translucent nav bar
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = NO;
}


- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)makeTransparent {
    [self setDefaultTranslucent:self.translucent];
    [self setTranslucent:YES];
    [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.backgroundColor = [UIColor clearColor];
    self.shadowImage = [UIImage new];    // Hides the hairline
    [self hideBottomHairline];
}

- (void)makeDefault {
    [self setTranslucent:[self defaultTranslucent]];
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.backgroundColor = nil;
    self.shadowImage = nil;    // Hides the hairline
    [self showBottomHairline];
}



- (BOOL)defaultTranslucent
{
    NSNumber *value = objc_getAssociatedObject(self, translucentKey);
    return value.boolValue;
}

- (void)setDefaultTranslucent:(BOOL)b
{
    objc_setAssociatedObject(self, translucentKey, @(b), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
