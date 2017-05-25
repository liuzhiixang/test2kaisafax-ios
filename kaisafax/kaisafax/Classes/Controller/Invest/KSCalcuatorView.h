//
//  KSCalcuatorView.h
//  kaisafax
//
//  Created by BeiYu on 2016/12/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,KSCalcuatorIndex)
{
    KSCalcuatorDay = 1,          //天
    KSCalcuatorMonth,            //月
    KSCalcuatorEqualBX,           //等额本息
    KSCalcuatorEqualBJ,           //等额本金
    KSCalcuatorFirX,              //先息后本
    KSCalcuatorOnce,              //一次性还款
    KSCalcuatorMax,               //最大枚举值;
};

typedef NS_ENUM(NSInteger,KSPeriodType)
{
    KSPeriodTypeDay = 1,          //天
    KSPeriodTypeMonth,            //月
    
    KSPeriodTypeMax,               //最大枚举值;
};

typedef NS_ENUM(NSInteger,KSMethodType)
{
    KSMethodTypeBX = 1,           //等额本息
    KSMethodTypeBJ,           //等额本金
    KSMethodTypeFirX,              //先息后本
    KSMethodTypeOnce,              //一次性还款
    KSMethodTypeMax,               //最大枚举值;
};

@interface KSCalcuatorView : UIView
@property (weak, nonatomic) IBOutlet UITextField *investTF;
@property (weak, nonatomic) IBOutlet UITextField *periodTF;
@property (weak, nonatomic) IBOutlet UITextField *rateTF;


@property (nonatomic,assign) NSInteger periodType;
@property (nonatomic,assign) NSInteger methodType;

@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;

- (IBAction)daySelAction:(id)sender;

- (IBAction)equBXSelAction:(id)sender;

-(void)inteType;

@end
