//
//  KSAboutVC.m
//  kaisafax
//
//  Created by Jjyo on 2016/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAboutVC.h"
#import "KSWebVC.h"
#import "KSVersionMgr.h"
@interface KSAboutVC ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionNewLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *updateFlagView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@end

@implementation KSAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = KAboutUsTitle;
    _stackView.spacing = 0;

//    [self updateUI:entity];
    
    @WeakObj(self);
    [RACObserve([KSVersionMgr sharedInstance], versionData) subscribeNext:^(id x) {
        [weakself hideProgressHUD];
        [weakself updateUI:x];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateUI:(KSVersionEntity *)entity
{
    NSLog(@"updateUI");
    _versionLabel.text = [NSString stringWithFormat:@"当前版本 V%@", [[KSVersionMgr sharedInstance] getVersionName]];
    _versionNewLabel.text = @"";
    _versionStatusLabel.text = @"";
    
    _updateFlagView.hidden = YES;
    if (entity) {
        _versionNewLabel.text = [NSString stringWithFormat:@"(%@)",entity.verDes];

        _versionStatusLabel.text = KVerUpgradeTitle;
        _versionStatusLabel.textColor = NUI_HELPER.appOrangeColor;
    }
    else if ([KSVersionMgr sharedInstance].errorDescription)
    {
//        _updateFlagView.hidden = NO;
//        [self showToastWithTitle:[KSVersionMgr sharedInstance].error];
        _versionStatusLabel.text = [KSVersionMgr sharedInstance].errorDescription;
    }
}


- (IBAction)aboutAction:(id)sender {
    
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KAboutUSPage data:nil error:nil];
    
     [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"佳兆业金服" type:KSWebSourceTypeAccount];
}
- (IBAction)safeAction:(id)sender {
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KSafetyPage data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"安全保障" type:KSWebSourceTypeAccount];

}

- (IBAction)qustionAction:(id)sender {
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KQuestionPage data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"常用问题" type:KSWebSourceTypeAccount];
}

- (IBAction)updateAction:(id)sender {
    if ([KSVersionMgr sharedInstance].versionData) {
        NSString *urlStr = [KSVersionMgr sharedInstance].versionData.url;
        if (urlStr && urlStr.length > 0)
        {
            NSURL *updateURL = [NSURL URLWithString:urlStr];
            [[UIApplication sharedApplication] openURL:updateURL];
        }
    }else{
        [self showProgressHUD];
        [[KSVersionMgr sharedInstance] doCheckUpdate];
    }
}
- (IBAction)calloutAction:(id)sender {
    NSString *str= @"telprompt://4008896099";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

@end
