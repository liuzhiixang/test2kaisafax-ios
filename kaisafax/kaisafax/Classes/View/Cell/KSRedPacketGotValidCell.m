//
//  KSRedPacketGotValidCell.m
//  kaisafax
//
//  Created by philipyu on 16/8/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRedPacketGotValidCell.h"
#import "KSValidRedRewardEntity.h"
#import "KSRewardItemEntity.h"
#import "KSUserMgr.h"
#import "KSConst.h"

#define kLimitInvoked   200.0


@interface KSRedPacketGotValidCell()
@property (weak, nonatomic) IBOutlet UILabel *validLabel;
@property (weak, nonatomic) IBOutlet UILabel *checktipLabel;

@property (weak, nonatomic) IBOutlet UILabel *checkingLabel;
@property (weak, nonatomic) IBOutlet UIButton *gotBtn;
- (IBAction)gotAction:(UIButton *)sender;

@end
@implementation KSRedPacketGotValidCell



//-(void)drawRect:(CGRect)rect
//{
//    self.frame = CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, height);
//}

- (void)updateData:(KSValidRedRewardEntity*)entity
{
 
//    self.frame = CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, height);
    INFO(@"%@",NSStringFromCGRect(self.frame));
//   self.validLabel = entity
    if (!entity) return;
    double valid = entity.qualified;
    self.validLabel.text = [NSString stringWithFormat:@"%.2f",valid];
    
    if (valid>0.0)
    {
        self.gotBtn.enabled = YES;
        self.gotBtn.backgroundColor = NUI_HELPER.appOrangeColor;
    }
    else
    {
        self.gotBtn.enabled = NO;
        self.gotBtn.backgroundColor = UIColorFrom255RGB(195, 195, 195);
    }
    
//    double invoke = (double)entity.invoked;
//    if (invoke > kLimitInvoked)
//    {
//        self.checkingLabel.text = [NSString stringWithFormat:@"%.2f",invoke];
//        self.checkingLabel.hidden = NO;
//        self.checktipLabel.hidden = NO;
//    }
//    else
    {
        self.checkingLabel.hidden = YES;
        self.checktipLabel.hidden = YES;
    }
}


- (IBAction)gotAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(redPacketGotCell:)])
    {
        [self.delegate redPacketGotCell:self.validLabel.text];
    }
}

//-(void)layoutSubviews
//{
//    
////    ???为何要调用这个方法才对，有啥不合理的？？？
//    [super layoutSubviews];
//    
//    self.bounds = CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 100.0);
//}
@end
