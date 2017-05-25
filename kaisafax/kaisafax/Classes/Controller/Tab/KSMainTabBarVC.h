//
//  KSMainTabBarVC.h
//  kaisafax
//
//  Created by Semny on 16-02-21.
//
//

#import <UIKit/UIKit.h>

#define KTabBarVCShowNotifyKey    @"KSMainTabBarVCShowNotify"

@interface KSMainTabBarVC : UITabBarController
{
    BOOL              shouldSwithTabBarHidden;
}

@property (nonatomic, assign) BOOL isTabBarHidden;

/**
 *  当前Tabbar VC是否显示
 */
@property (nonatomic, assign, readonly) BOOL isSelfAppear;

@end