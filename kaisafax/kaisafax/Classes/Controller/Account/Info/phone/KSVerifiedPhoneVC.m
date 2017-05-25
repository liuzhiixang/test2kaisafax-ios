//
//  KSVerifiedPhoneVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSVerifiedPhoneVC.h"
#import "KSYYLabel.h"
#import "JXMCSUserManager.h"

@interface KSVerifiedPhoneVC ()
@property (weak, nonatomic) IBOutlet KSYYLabel *tipsLabel;

- (IBAction)connectCustomerService:(UIButton *)sender;

@end

@implementation KSVerifiedPhoneVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = KPhoneVerifyTitle;

    [self configTipsLabel];
}

-(void)configTipsLabel
{
    NSString *richText = @"认证手机号将用于接收账户变动信息、验证码和资金变动短信等。如需修改手机认证,请联系客服或拨打客服电话400-889-6099";
    self.tipsLabel.numberOfLines = 0;
//    self.tipsLabel.attributedText = [self getAttributedStringWithString:richText lineSpace:15.0];
    [self.tipsLabel customerServiceRichText:richText];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;

}

- (IBAction)connectCustomerService:(UIButton *)sender
{
    //去佳信客服
    [self pushCustomerCenter];
}


-(void)pushCustomerCenter
{
    JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
    
    if ([mgr isLogin])
    {
        [self jumpToCustomerCenter];
    }
    else
    {
        [self loginJXCustomer];
    }
    
}

#pragma mark - 佳信客服
#pragma mark - 调用客服API

-(void)jumpToCustomerCenter
{
    [[JXMCSUserManager sharedInstance] requestCSForUI:self.navigationController indexPath:1];
}

-(void)loginJXCustomer
{
    JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
    @WeakObj(self);
    [mgr
     loginWithAppKey:KJXAppkey
     responseObject:^(BOOL success, id responseObject) {
         if (success) {
             [weakself loginJXSuccessed];
         } else {
             dispatch_after(
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.f * NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^{
                                JXError *error = responseObject;
//                                [sJXHUD showMessage:[error getLocalDescription] duration:1.f];
                                if(error)
                                {
                                    [sJXHUD showMessage:@"佳信客服登录失败" duration:1.f];
                                }

                            });
         }
     }];
}

-(void)loginJXSuccessed
{
    [self jumpToCustomerCenter];
}



@end
