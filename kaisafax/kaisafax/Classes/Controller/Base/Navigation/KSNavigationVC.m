//
//  KSNavigationVC.m
//  kaisafaxPlayer
//
//  Created by RonanSmith on 10/21/15.
//  Copyright © 2015 kaisafax. All rights reserved.
//

#import "KSNavigationVC.h"

@interface KSNavigationVC ()

@end

@implementation KSNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [super setNavigationBarHidden:navigationBarHidden];
}

/**
 *  状态栏的样式结合nav的子视图的该方法使用
 *
 *  @return 视图的状态栏样式
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController* topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.viewControllers.count > 2) {
        self.viewControllers = @[self.viewControllers.firstObject, self.viewControllers.lastObject];
    }
    return [super popToRootViewControllerAnimated:animated];
}
@end
