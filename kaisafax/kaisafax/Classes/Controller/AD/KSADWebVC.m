//
//  KSADWebVC.m
//  kaisafax
//
//  Created by semny on 16/10/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADWebVC.h"
#import "AppDelegate.h"

@interface KSADWebVC ()

@end

@implementation KSADWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 返回时一级级返回
-(void)leftButtonAction:(id)sender
{
    if (self.type == KSWebSourceTypeADAfterCheck)
    {
        //启动主界面
        [self dismissViewControllerAnimated:YES completion:^{
            [NOTIFY_CENTER postNotificationName:KAfterPageCloseAnimationNotificationKey object:nil userInfo:nil];
        }];
    }
    else
    {
        AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
        //启动主界面
        [appDelegate startMainPage];
    }
}
@end
