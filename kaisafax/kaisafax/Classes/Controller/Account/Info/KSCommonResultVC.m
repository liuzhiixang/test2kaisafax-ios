//
//  KSCommonResultVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/12/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSCommonResultVC.h"

@interface KSCommonResultVC ()
@property (weak, nonatomic) IBOutlet UILabel *ownerInfoLabel;

@end

@implementation KSCommonResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"业主认证";
    if (self.ownerInfo)
    {
        self.ownerInfoLabel.text = self.ownerInfo;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
