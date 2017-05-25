//
//  KSJDCardProduceVC.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/19.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardProduceVC.h"

@interface KSJDCardProduceVC ()
@property (strong, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIView *cutdownView;
@property (weak, nonatomic) IBOutlet UILabel *cutdownLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (assign, nonatomic) BOOL cancel;

@end

@implementation KSJDCardProduceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    @WeakObj(self);
    [[_smsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakself countDownAction];
    }];
}

- (BOOL)transparentNavigationBar
{
    return YES;
}


//倒计时
- (void)countDownAction
{
    @WeakObj(self);
    _cutdownView.hidden = NO;
    _cancel = NO;
    
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0 || _cancel){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakself.cutdownView.hidden =  YES;
            });
        }else{
            //倒计时中....
            NSString *strTime = [NSString stringWithFormat:@"%ds", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakself.cutdownLabel.text = strTime;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}


- (IBAction)touchAction:(id)sender {
    @WeakObj(self);
    _cutdownView.hidden = YES;
    CGFloat fitHeight  = [_verifyView systemLayoutSizeFittingSize:CGSizeMake(280, 200)].height;
    _verifyView.frame = CGRectMake(0, 0, 280, fitHeight);
    [_verifyView layoutIfNeeded];
    
    LGAlertView *alertView =  [self showLGAlertTitle:@"安全验证"
                   message:@"为了您京东卡安全, 请您验证手机:"
                      view:_verifyView
         otherButtonTitles:nil
         cancelButtonTitle:@"取消"
             okButtonTitle:@"确定"
          otherButtonBlock:nil
               cancelBlock:^(id alert) {
                   [weakself dismissAlertView:alert];
                } okBlock:^(id alert) {
                    [weakself dismissAlertView:alert];
                } completionBlock:nil];
    alertView.cancelOnTouch = NO;
    alertView.dismissOnAction = NO;
}

- (void)dismissAlertView:(LGAlertView *)alertView
{
    _cancel = YES;
    
    [_codeTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [alertView dismissAnimated:YES completionHandler:nil];
    
}

@end
