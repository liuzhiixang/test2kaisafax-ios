//
//  KSBindBankCardVC.m
//  kaisafax
//
//  Created by philipyu on 16/9/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBindBankCardVC.h"

@interface KSBindBankCardVC ()

@end

@implementation KSBindBankCardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)leftButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
