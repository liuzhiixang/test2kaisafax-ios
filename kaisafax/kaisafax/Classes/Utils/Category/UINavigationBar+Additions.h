//
//  UINavigationBar+Additions.h
//  kaisafax
//
//  Created by Jjyo on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Additions)
/**
 * Hide 1px hairline of the nav bar
 */
- (void)hideBottomHairline;

/**
 * Show 1px hairline of the nav bar
 */
- (void)showBottomHairline;

/**
 * Makes the navigation bar background transparent.
 */
- (void)makeTransparent;

/**
 * Restores the default navigation bar appeareance
 **/
- (void)makeDefault;
@end
