//
//  KSProgressBar.m
//  kaisafax
//
//  Created by Jjyo on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSProgressBar.h"

@interface KSProgressBar()

#define DEFAULT_TEXT_SIZE 10
#define DEFAULT_TEXT_COLOR [UIColor whiteColor]
#define DEFAULT_GRADIENT_START_COLOR [UIColor lightGrayColor]
#define DEFAULT_GRADIENT_END_COLOR [UIColor darkGrayColor]


@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) UILabel *popLabel;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end


@implementation KSProgressBar

- (void)applyNUI
{
    if (self.nuiClass) {
        NSString *nuiClass = self.nuiClass;
        [NUIRenderer renderView:self];
        if([NUISettings hasProperty:@"font-color" withClass:nuiClass])
        {
            _textColor = [NUISettings getColor:@"font-color" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"gradient-start-color" withClass:nuiClass])
        {
            _gradientStartColor = [NUISettings getColor:@"gradient-start-color" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"gradient-end-color" withClass:nuiClass])
        {
            _gradientEndColor = [NUISettings getColor:@"gradient-end-color" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"font-size" withClass:nuiClass]) {
            _textSize = [NUISettings getFloat:@"font-size" withClass:nuiClass];
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self viewInit];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self viewInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self viewInit];
    }
    return self;
}


- (void)viewInit
{
    [self applyNUI];
    _barView = [UIView new];
    [self addSubview:_barView];
    _popLabel = [UILabel new];
    _popLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_popLabel];
    [self setupDefault];
    
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(0, 0);
    _gradientLayer.endPoint = CGPointMake(1, 0);
    [_barView.layer addSublayer:_gradientLayer];
    
    _barView.clipsToBounds = YES;
    
}





- (void)setupDefault
{
    if (_textSize == 0) {
        _textSize = DEFAULT_TEXT_SIZE;
    }
    if (!_textColor) {
        _textColor = DEFAULT_TEXT_COLOR;
    }
//    if (!_gradientStartColor) {
//        _gradientStartColor = DEFAULT_GRADIENT_START_COLOR;
//    }
//    if (!_gradientEndColor) {
//        _gradientEndColor = DEFAULT_GRADIENT_END_COLOR;
//    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize textSize = [KSProgressBar sizeOfString:@"100%" withWidth:320 font:_popLabel.font];
    textSize.width += 6;
    textSize.height += 2;
    _popLabel.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - textSize.height) / 2, textSize.width, textSize.height);
    _popLabel.layer.masksToBounds = YES;
    _popLabel.layer.cornerRadius = textSize.height/2;
    
    [self updateUI];
}


- (void)setProgress:(CGFloat)progress
{
    _progress = MIN(progress, 1.0) ;
    [self updateUI];
}



- (void)updateUI
{
    
    
    _popLabel.backgroundColor = _gradientEndColor;
    _popLabel.textColor = _textColor;
    _popLabel.font = [UIFont systemFontOfSize:_textSize];
    
    
    CGFloat barWidth = CGRectGetWidth(self.frame) - CGRectGetWidth(_popLabel.frame);
    CGFloat offsetX = barWidth * _progress;
    
    CGRect popFrame = _popLabel.frame;
    popFrame.origin.x = offsetX;
    _popLabel.frame = popFrame;
    _popLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_progress * 100)];
    
    _barView.frame = CGRectMake(0, 0, offsetX + 3, CGRectGetHeight(self.frame));
    _gradientLayer.frame =  _barView.bounds;
    
    //设置颜色数组
    if (_gradientStartColor && _gradientEndColor) {
        _gradientLayer.colors = @[(__bridge id)_gradientStartColor.CGColor,
                                  (__bridge id)_gradientEndColor.CGColor];
    }
}



+ (CGSize)sizeOfString:(NSString *)text withWidth:(float)width font:(UIFont *)font {
    CGSize size = CGSizeMake(width, MAXFLOAT);
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        size = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:tdic
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }
    
    return size;
}

@end
