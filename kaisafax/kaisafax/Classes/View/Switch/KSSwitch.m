//
//  KSSwitch.m
//  kaisafax
//
//  Created by semny on 17/1/4.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSSwitch.h"

@implementation KSSwitch

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    DEBUGG(@"%s", __FUNCTION__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [super touchesBegan:touches withEvent:event];
    if (self.touchBlock)
    {
        self.touchBlock(self, TouchActionTypeBegin);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
//    [super touchesMoved:touches withEvent:event];
    if (self.touchBlock)
    {
        self.touchBlock(self, TouchActionTypeMove);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [super touchesEnded:touches withEvent:event];
    if (self.touchBlock)
    {
        self.touchBlock(self, TouchActionTypeEnd);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
//    [super touchesCancelled:touches withEvent:event];
    if (self.touchBlock)
    {
        self.touchBlock(self, TouchActionTypeCanclled);
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DEBUGG(@"%s, %@", __FUNCTION__, event);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DEBUGG(@"%s, %@", __FUNCTION__, event);
    return [super beginTrackingWithTouch:touch withEvent:event];
}
@end
