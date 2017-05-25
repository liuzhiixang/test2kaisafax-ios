//
//  KSCalcuatorView.m
//  kaisafax
//
//  Created by BeiYu on 2016/12/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSCalcuatorView.h"
#import "UIView+Toast.h"
#import "KSButton.h"



#define kCannotSelectError     @"只有一次性还款才能选择天数"

@interface KSCalcuatorView()
- (IBAction)confirmBuyAction:(id)sender;
@property (weak, nonatomic) IBOutlet KSButton *dayBtn;
@property (weak, nonatomic) IBOutlet KSButton *monBtn;

@property (weak, nonatomic) IBOutlet KSButton *equBXbtn;
@property (weak, nonatomic) IBOutlet KSButton *equBJbtn;
@property (weak, nonatomic) IBOutlet KSButton *firstXBbtn;
@property (weak, nonatomic) IBOutlet KSButton *oncebtn;

@end

@implementation KSCalcuatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)confirmBuyAction:(id)sender
{
    KSButton *btn = sender;
    btn.selected = !btn.selected;
}

- (IBAction)daySelAction:(id)sender {
    KSButton *selBtn = sender;
    
    if (self.methodType != KSMethodTypeOnce && selBtn.tag == KSPeriodTypeDay && self.methodType != KSMethodTypeMax)
    {
        [self makeToast:kCannotSelectError duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    selBtn.selected = !selBtn.selected;
    
    if(selBtn.tag == KSCalcuatorDay)
    {
        if(self.monBtn.selected)
            self.monBtn.selected = NO;
        if(selBtn.selected)
            self.periodType = KSPeriodTypeDay;
    }
    else if (selBtn.tag == KSCalcuatorMonth)
    {
        if(self.dayBtn.selected)
            self.dayBtn.selected = NO;
        if(selBtn.selected)
            self.periodType = KSPeriodTypeMonth;
    }
    
    
    //一个都没有选中
    if(!self.dayBtn.selected && !self.monBtn.selected)
        self.periodType = KSPeriodTypeMax;

    
//    for (id subview in self.subviews)
//    {
//        if ([subview isKindOfClass:[KSButton class]]) {
//            KSButton *btn = subview;
//            if (btn.tag <= KSCalcuatorMonth && btn.tag >= KSCalcuatorDay && btn.tag != selBtn.tag && btn.selected )
//            {
//                btn.selected = NO;
//            }
//        }
//
//    }
}



- (IBAction)equBXSelAction:(id)sender
{
    KSButton *selBtn = sender;
    selBtn.selected = !selBtn.selected;
    
    
    switch(selBtn.tag)
    {
        case KSCalcuatorEqualBX:
            self.equBJbtn.selected = NO;
            self.firstXBbtn.selected = NO;
            self.oncebtn.selected = NO;
            if (selBtn.selected)
            {
                self.methodType = KSMethodTypeBX;

            }
            break;
        case KSCalcuatorEqualBJ:
            self.equBXbtn.selected = NO;
            self.firstXBbtn.selected = NO;
            self.oncebtn.selected = NO;
            if (selBtn.selected)
            {
                self.methodType = KSMethodTypeBJ;

            }
            break;
        case KSCalcuatorFirX:
            self.equBJbtn.selected = NO;
            self.equBXbtn.selected = NO;
            self.oncebtn.selected = NO;
            if (selBtn.selected)
            {
                self.methodType = KSMethodTypeFirX;

            }
            break;
        case KSCalcuatorOnce:
            self.equBXbtn.selected = NO;
            self.equBJbtn.selected = NO;
            self.firstXBbtn.selected = NO;
            if (selBtn.selected)
            {
                self.methodType = KSMethodTypeOnce;

            }
            break;
        default:
            break;
    }
    
    if( !self.equBJbtn.selected && !self.equBXbtn.selected && !self.firstXBbtn.selected
       && !self.oncebtn.selected)
        self.methodType = KSMethodTypeMax;
    
//
//    for (KSButton *btn in self.subviews)
//    {
//        if (btn.tag < KSCalcuatorMax && btn.tag >= KSCalcuatorEqualBX && btn.tag != selBtn.tag && btn.selected )
//        {
//            btn.selected = NO;
//        }
//    }
}

-(void)inteType
{
    self.periodType = KSPeriodTypeMax;
    self.methodType = KSMethodTypeMax;
}
@end
