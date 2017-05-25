//
//  KSButton.m
//  kaisafax2
//
//  Created by Jjyo on 16/6/18.
//  Copyright © 2016年 深圳深信金融服务有限公司. All rights reserved.
//

#import "KSButton.h"
#import "NUIRenderer.h"

@interface KSButton ()

@property (nonatomic, strong) UIColor *borderColor;

@end


@implementation KSButton


- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.nuiClass) {
        [NUIRenderer renderButton:self withClass:self.nuiClass];
        
        if ([NUISettings hasProperty:@"border-color" withClass:self.nuiClass]) {
            _borderColor = [NUISettings getColor:@"border-color" withClass:self.nuiClass];
        }

        if ([NUISettings hasProperty:@"border-color-selected" withClass:self.nuiClass])
        {
            _borderSelectedColor = [NUISettings getColor:@"border-color-selected" withClass:self.nuiClass];
            [self addObserver:self forKeyPath:@"selected" options:0 context:nil];
        }
        
    }
}


- (void)dealloc
{
    if (_borderSelectedColor) {
        [self removeObserver:self forKeyPath:@"selected"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateBorderColor];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"]) {
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"selected"])
    {
        [self updateBorderColor];
    }
}


- (void)updateBorderColor
{
    if (self.selected && _borderSelectedColor) {
        self.layer.borderColor = _borderSelectedColor.CGColor;
    }else{
        self.layer.borderColor = _borderColor.CGColor;
    }
}


@end
