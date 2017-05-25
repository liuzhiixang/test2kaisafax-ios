//
//  KSNVBackVC.m
//  kaisafax
//
//  Created by SemnyQu on 14/10/25.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"

@interface KSNVBackVC ()

@end

@implementation KSNVBackVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.shouldShowLeftNavBtn = YES;
    //隐藏tab bar
    //[self.tabBarController.tabBar setHidden:YES];
    
    //[self.navigationController.tabBarController setTabBarHidden:YES];
    
    //设置返回按钮
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left"];

//    UIImage *backImg = [UIImage imageNamed:@"white_left"];
//    self.navigationController.navigationBar.backIndicatorImage = backImg;
//    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backImg;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setNoTabBarFrame];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//-(void)setNavLeftButtonByImage:(NSString *)leftBtnImgName selectedImageName:(NSString *)leftBtnSImageName
//{
//    [self setNavLeftButtonByImage:leftBtnImgName selectedImageName:leftBtnSImageName navBtnAction:@selector(returnBack:)];
//}

//-(void)returnBack:(id)sender
//{
//    if (self.navigationController)
//    {
//        [self.tabBarController.tabBar setHidden:NO];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

@end
