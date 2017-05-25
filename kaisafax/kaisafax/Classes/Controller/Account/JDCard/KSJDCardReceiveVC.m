//
//  KSJDCardReceiveVC.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/19.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardReceiveVC.h"
#import "KSBaseEntity.h"
#import "KSJDCardExtractBL.h"
#import "KSJDExtractBalancesEntity.h"
#import "KSJDCardPayrollRecordVC.h"
#import "KSTextField.h"

typedef NS_ENUM(NSUInteger, SelectAmount) {
    SelectAmountAll,
    SelectAmount50,
    SelectAmount100,
    SelectAmount500,
    SelectAmount1000,
};


#define MAX_AMOUNT 1000

#define BT_ARRAY @[_sel50Button, _sel100Button, _sel200Button, _sel500Button, _selAllButton]
#define BT_AMOUNT @[@"50", @"100", @"200", @"500", @"1000"]

@interface KSJDCardReceiveVC ()<KSBLDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sel50Button;
@property (weak, nonatomic) IBOutlet UIButton *sel100Button;
@property (weak, nonatomic) IBOutlet UIButton *sel500Button;
@property (weak, nonatomic) IBOutlet UIButton *sel200Button;
@property (weak, nonatomic) IBOutlet UIButton *selAllButton;

@property (weak, nonatomic) IBOutlet UIButton *takeButton;

@property (weak, nonatomic) IBOutlet KSTextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


@property (strong, nonatomic) KSJDCardExtractBL *extractBL;


@property (assign, nonatomic) BOOL taking;

@end

@implementation KSJDCardReceiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"领取京东卡";
    
    //[self setNavRightButtonByText:@"发放记录" titleColor:[UIColor whiteColor] imageName:nil selectedImageName:nil navBtnAction:@selector(rightButtonAction:)];
    

    _amountLabel.text = [NSString stringWithFormat:@"%@元", [KSBaseEntity formatAmountNotFloat:_jdAmount]];
    _inputTextField.maxLength = 9;
    @WeakObj(self);
    [[_inputTextField rac_textSignal] subscribeNext:^(id x) {
        
        [weakself updateAmount:x];
    }];
    
    
    [RACObserve(_inputTextField, text) subscribeNext:^(id x) {
        [weakself updateAmount:x];
    }];
    

    [self defaultSelectedAmount];
    
    _extractBL = [[KSJDCardExtractBL alloc]init];
    _extractBL.delegate = self;
    
}

    //默认选中最大
- (void)defaultSelectedAmount
{
    BOOL hasSelected = NO;
    for (NSInteger i = BT_AMOUNT.count - 1; i >=0; i--) {
        if (_jdAmount == [BT_AMOUNT[i] integerValue]) {
            [BT_ARRAY[i] setSelected:YES];
            _inputTextField.text = BT_AMOUNT[i];
            hasSelected = YES;
            break;
        }
    }
    
    if (!hasSelected) {
        _inputTextField.text = [NSString stringWithFormat:@"%ld", MIN(MAX_AMOUNT, _jdAmount)];
        _selAllButton.selected = YES;
    }
}


- (void)updateAmount:(NSString *)amountText
{
    
    NSInteger amount = [amountText integerValue];
    if (amount > MAX_AMOUNT) {
        _inputTextField.text = [NSString stringWithFormat:@"%d", MAX_AMOUNT];
        return;
    }
    
    _takeButton.enabled = amount > 0;
    _errorLabel.hidden = NO;
    if (amount > MAX_AMOUNT || amount <= 0) {
        _errorLabel.text = @"请输入正确提取金额";
    }
    else if (amount > _jdAmount) {
        _errorLabel.text = @"提取金额不能大于可领取金额";
    }else {
        _errorLabel.hidden = YES;
    }
    if (amountText.length == 0) {
        _errorLabel.hidden = YES;
    }
    
    BOOL hasSelected = NO;
    //选中金额相等的
    for (NSInteger i = BT_AMOUNT.count - 1; i >= 0; i--) {
        BOOL sel = [BT_AMOUNT[i] intValue] == amount;
        hasSelected |= sel;
        [BT_ARRAY[i] setSelected:sel];
    }
    if (!hasSelected && _jdAmount == amount) {
        _selAllButton.selected = YES;
    }
}

- (void)dealloc
{
    if (_taking) {
        [NOTIFY_CENTER postNotificationName:KAccountJDCardChangeNotificationKey object:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightButtonAction:(id)sender
{
    KSJDCardPayrollRecordVC *vc = [[KSJDCardPayrollRecordVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)takeNowAction:(id)sender
{
    
    NSInteger amount = _inputTextField.text.integerValue;
    
    if (amount > MAX_AMOUNT || amount > _jdAmount || amount <= 0) {
        return ;
    }
    
    [self showProgressHUD];
    [_extractBL doGetCardWithAmount:amount];
}

- (IBAction)selectAction:(id)sender
{
   
    for (int i = 0; i < BT_ARRAY.count; i++) {
        UIButton *bt = BT_ARRAY[i];
        bt.selected = bt == sender;
        
        if (bt.selected) {
            if (sender == _selAllButton) {
                _inputTextField.text = [@(MIN(_jdAmount, MAX_AMOUNT)) stringValue];
            }else{
                _inputTextField.text = BT_AMOUNT[i];
            }
            
        }
    }
}


#pragma mark -  KSBLDelegate

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self hideProgressHUD];
    if ([result.body isKindOfClass:[KSJDExtractBalancesEntity class]]) {
        KSJDExtractBalancesEntity *entity = (KSJDExtractBalancesEntity *)result.body;
        _jdAmount = (int)entity.jdAmount.floatValue;
        _amountLabel.text = [NSString stringWithFormat:@"%@元", [KSBaseEntity formatAmountNotFloat:_jdAmount]];
        [self showOperationHUDWithStr:@"领取成功"];
        [self defaultSelectedAmount];
        _taking = YES;
    }
}

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self hideProgressHUD];
    if (result.errorDescription) {
        [self showSimpleAlert:result.errorDescription];
    }
}

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    [self showToastWithTitle:@"服务器连接失败!"];
     [self hideProgressHUD];
}

@end
