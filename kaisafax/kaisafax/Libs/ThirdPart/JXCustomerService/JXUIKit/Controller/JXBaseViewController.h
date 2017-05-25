//
//  JXBaseViewController.h
//

#import <UIKit/UIKit.h>

#import "JXMacros.h"
#import "UIView+Extends.h"
#import "UIViewController+HUD.h"

@interface JXBaseViewController : UIViewController

@property(nonatomic, assign, getter=isModal, readonly) BOOL modal;

@property(nonatomic, assign) BOOL hideNavBar;

- (void)popSelf;

- (void)popSelfWithoutAnimation;

- (void)popToRoot;

- (void)viewDidPop;

- (void)setupDefaultLeftButtonItem;

- (void)setupDefaultLeftButtonItemWithTitle:(NSString *)title;

- (void)configureCompleteRightBarItemWithActionBlock:(void (^)(id sender))finishBlock;

- (void)setupRightBarButtonItemWithTitle:(NSString *)title andAction:(void (^)(id sender))action;

- (void)setupRightBarButtonItemWithImage:(UIImage *)image andAction:(void (^)(id sender))action;

@end
