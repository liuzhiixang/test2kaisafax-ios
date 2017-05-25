//
//  KSMailVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSMailVC.h"
#import "MBProgressHUD.h"
#import "KSEmailBL.h"
#import "KSAccountInfoVC.h"

#define  kMailMaxLength      40

@interface KSMailVC ()<KSBLDelegate>

@property (strong, nonatomic) KSEmailBL *emailBL;
@property (weak, nonatomic) IBOutlet UITextField *mailTF;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (assign, nonatomic) BOOL isFirst;
@property (weak, nonatomic) IBOutlet UIView *errorView;
- (IBAction)saveAction:(UIButton *)sender;

@end

@implementation KSMailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = KEmailTitle;
    _isFirst = YES;
    
    if(!_emailBL)
    {
        _emailBL = [[KSEmailBL alloc]init];
        _emailBL.delegate = self;
    }
    
    [self.saveBtn setEnabled:NO];
//    [self.saveBtn setBackgroundColor:NUI_HELPER.appDisableColor];

    //test
//    [self showModifySucHUD];
    [self addObeserve];

    if (_isFirst)
    {
        if (self.mailStr)
        {
            self.mailTF.text = self.mailStr;
            [self.saveBtn setEnabled:YES];
//            [self.saveBtn setBackgroundColor:NUI_HELPER.appOrangeColor];

        }
        _isFirst = NO;
    }
    
}

#pragma mark - 添加监听

-(void)addObeserve
{
    //增加校验事件
    @WeakObj(self);
    //用户名或手机号
    RAC(self.mailTF, text) = [self.mailTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        INFO(@"%@",value);
        if (value.length>kMailMaxLength)
        {
            newValue = [newValue substringToIndex:kMailMaxLength];
            weakself.mailTF.text = newValue;
            [weakself showToastWithTitle:KMailNameMaxLengthTitle];
            return newValue;
        }
        
        if ([value isEmail])
        {
//            [self.saveBtn setBackgroundColor:NUI_HELPER.appOrangeColor];
            [self.saveBtn setEnabled:YES];
        }
        else
        {
//            [self.saveBtn setBackgroundColor:NUI_HELPER.appDisableColor];
            [self.saveBtn setEnabled:NO];
        }
        weakself.mailTF.text = newValue;
        return newValue;
    }];
}




#pragma mark - 保存行为
- (IBAction)saveAction:(UIButton *)sender
{
    NSString *mailStr = self.mailTF.text;
    
    [self.view endEditing:YES];
    
    if (![mailStr isEmail]) {
        self.errorView.hidden = NO;
        return;
    }
    
    if(_emailBL && mailStr)
    {
        [_emailBL doSetEmailWithStr:self.mailTF.text];
    }
}

#pragma mark - 
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@ %@",blEntity,result);
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
    });
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@",blEntity);
    
//    if (!result) return;
    
    @WeakObj(self);
    
    dispatch_async(dispatch_get_main_queue(), ^{
            if (result.errorCode == 0 && [result.tradeId isEqualToString:KBindEmail])
            {
//                [weakself showOperationHUDWithStr:@"修改成功"];
//                
//                [NOTIFY_CENTER postNotificationName:KAccountInfoChangeNotificationKey object:nil userInfo:nil];

                void (^comp)() = ^{
                    //跳转到个人中心
                    NSArray *childArray = weakself.navigationController.childViewControllers;
                    int i;
                    for (i=0; i<childArray.count; i++)
                    {
                        if([childArray[i] isKindOfClass:[KSAccountInfoVC class]])
                            break;
                    }
                    if (i!=childArray.count) {
                        [weakself.navigationController popToViewController:childArray[i] animated:YES];
                    }
                    
                };
                [weakself showOperationHUDToJumpWithStr:@"修改成功" completion:comp];                //通知去更新个人中心
                [NOTIFY_CENTER postNotificationName:KAccountInfoChangeNotificationKey object:nil userInfo:nil];

            }
        });
    
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}
@end
