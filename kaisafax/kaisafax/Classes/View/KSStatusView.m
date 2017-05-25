//
//  KSStatusView.m
//  kaisafax
//
//  Created by Jjyo on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSStatusView.h"

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees) / 180)
#define   VIEW_ROTATION_ANGLE -15

#define DEFAULT_PROGRESS_LINE_WIDTH 1
#define DEFAULT_STATUS_ARC_ANGLE 100
#define DEFAULT_PROGRESS_TINT_COLOR [UIColor orangeColor]
#define DEFAULT_TRACK_TINT_COLOR [UIColor lightGrayColor]
#define DEFAULT_DISABLE_COLOR [UIColor lightGrayColor]

#define DEFAULT_TEXT_SIZE 10
#define DEFAULT_TEXT_COLOR [UIColor orangeColor]


@interface KSStatusView ()

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) CAShapeLayer *arcLayer;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@end



@implementation KSStatusView

@synthesize progress = _progress;



- (void)applyNUI
{
    NSString *nuiClass = self.nuiClass;
    if (nuiClass) {
        [NUIRenderer renderView:self];
        if([NUISettings hasProperty:@"disable-color" withClass:nuiClass])
        {
            self.disableColor = [NUISettings getColor:@"disable-color" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"progress-tint-color" withClass:nuiClass])
        {
            self.progressTintColor = [NUISettings getColor:@"progress-tint-color" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"track-tint-color" withClass:nuiClass])
        {
            self.trackTintColor = [NUISettings getColor:@"track-tint-color" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"progress-line-width" withClass:nuiClass])
        {
            self.progressLineWidth = [NUISettings getFloat:@"progress-line-width" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"font-size" withClass:nuiClass])
        {
            self.textSize = [NUISettings getFloat:@"font-size" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"font-color" withClass:nuiClass])
        {
            self.textColor = [NUISettings getColor:@"font-color" withClass:nuiClass];
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
    
    
    //status label
    _statusLabel = [UILabel new];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.minimumScaleFactor = 0.5;
    _statusLabel.adjustsFontSizeToFitWidth = YES;
    _statusLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(VIEW_ROTATION_ANGLE));
    [self addSubview:_statusLabel];
    
    //progress label
    _progressLabel = [UILabel new];
    _progressLabel.minimumScaleFactor = 0.5;
    _progressLabel.adjustsFontSizeToFitWidth = YES;
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_progressLabel];
    
    self.statusStyle = KSStatusStyleNormal;
    
    [self setupDefault];
    [self applyNUI];
    [self initLayer];
    
}

/**
 *  初始化图层
 */
- (void)initLayer
{
    //arc layer
    [_arcLayer removeFromSuperlayer];
    _arcLayer = [CAShapeLayer layer];
    _arcLayer.lineCap = kCALineCapButt;
    _arcLayer.lineJoin = kCALineJoinMiter;
    _arcLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.layer addSublayer:_arcLayer];
    
    //progress layer
    [_progressLayer removeFromSuperlayer];
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.lineJoin = kCALineJoinMiter;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.layer addSublayer:_progressLayer];
}

/**
 *  默认值
 */
- (void)setupDefault
{
    if (_progressLineWidth == 0) {
        _progressLineWidth = DEFAULT_PROGRESS_LINE_WIDTH;
    }
    if (_statusArcAngle == 0) {
        _statusArcAngle = DEFAULT_STATUS_ARC_ANGLE;
    }
    if (!_progressTintColor) {
        _progressTintColor = DEFAULT_PROGRESS_TINT_COLOR;
    }
    if (!_trackTintColor) {
        _trackTintColor = DEFAULT_TRACK_TINT_COLOR;
    }
    if (!_disableColor) {
        _disableColor = DEFAULT_DISABLE_COLOR;
    }
    if (_textSize == 0) {
        _textSize = DEFAULT_TEXT_SIZE;
    }
    if (!_textColor) {
        _textColor = DEFAULT_TEXT_COLOR;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat padding = 6;
    _statusLabel.frame = self.bounds;
    _progressLabel.frame = CGRectMake(padding, 0, CGRectGetWidth(self.bounds) - padding * 2, CGRectGetHeight(self.bounds));
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    _progressLabel.textColor = self.textColor;
    _progressLabel.font = [UIFont systemFontOfSize:_textSize];
    
    _statusLabel.textColor = self.textColor;
    _statusLabel.font = [UIFont systemFontOfSize:_textSize];

    _arcLayer.path = !_arcLayer.hidden ? [self createArcPathAtRect:rect].CGPath : nil;
    _progressLayer.path = [self createProgressPathAtRect:rect progress:self.progress].CGPath;
}


/**
 *  绘制status label下的扇形不闭合圈
 *
 *  @param rect 绘制区域
 *
 *  @return 返回绘制对象
 */
- (UIBezierPath *)createArcPathAtRect:(CGRect)rect
{
    CGPoint point = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = (rect.size.width / 2 - 10);
    
    CGFloat lineWidth = 0.5;
    NSInteger rotationAngle = VIEW_ROTATION_ANGLE;
    NSInteger lineAngle = _statusArcAngle;
    NSInteger spanAngle = (360 - lineAngle * 2) / 4;
    UIBezierPath *path = [UIBezierPath bezierPath];

    //bottom arc line
    NSInteger bottomStartAngle = spanAngle + rotationAngle;
    NSInteger bottomEndAngle = bottomStartAngle + lineAngle;
    
    UIBezierPath *bottomPath =[UIBezierPath bezierPathWithArcCenter:point
                                                           radius:radius
                                                       startAngle:DEGREES_TO_RADIANS(bottomStartAngle)
                                                         endAngle:DEGREES_TO_RADIANS(bottomEndAngle)
                                                        clockwise:YES];
    bottomPath.lineWidth = lineWidth;
    [self.progressTintColor set];
    [bottomPath stroke];
    [path appendPath:bottomPath];
    
    // top arc line
    
    NSInteger topStartAngle = 180 + spanAngle + rotationAngle;
    NSInteger topEndAngle = topStartAngle + lineAngle;
    UIBezierPath *topPath =[UIBezierPath bezierPathWithArcCenter:point
                                                           radius:radius
                                                       startAngle:DEGREES_TO_RADIANS(topStartAngle)
                                                         endAngle:DEGREES_TO_RADIANS(topEndAngle)
                                                        clockwise:YES];
    topPath.lineWidth = lineWidth;
    [self.progressTintColor set];

    [topPath stroke];
    [path appendPath:topPath];
    return path;
}


/**
 *  绘制进度条
 *
 *  @param rect     绘制区域
 *  @param progress 进条值
 *
 *  @return 返回绘制对象
 */
- (UIBezierPath *)createProgressPathAtRect:(CGRect)rect progress:(CGFloat)progress
{
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2 - 2;
    
    CGFloat lineWidth = _progressLineWidth;
    NSInteger progressAngle = 360 * progress;
    NSInteger startAngle = -90;
    NSInteger endAngle = startAngle + progressAngle;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //progressTintColor
    UIBezierPath *progressPath = nil;
    if (progress >= 1) {
        CGRect r = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
        progressPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:radius];
        
    }else{
        if (progress > 0) {
            progressPath =[UIBezierPath bezierPathWithArcCenter:center
                                                         radius:radius
                                                     startAngle:DEGREES_TO_RADIANS(startAngle)
                                                       endAngle:DEGREES_TO_RADIANS(endAngle)
                                                      clockwise:YES];
        }
        //trackTintColor
        UIBezierPath *trackPath = nil;
        if (progress == 0) {
            CGRect r = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
            trackPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:radius];
        }else{
            trackPath =[UIBezierPath bezierPathWithArcCenter:center
                                                      radius:radius
                                                  startAngle:DEGREES_TO_RADIANS(endAngle)
                                                    endAngle:DEGREES_TO_RADIANS(startAngle)
                                                   clockwise:YES];
        }
        trackPath.lineWidth = lineWidth;
        
        [_trackTintColor set];
        [trackPath stroke];
        [path appendPath:trackPath];
        
        
        //inner circle
        CGFloat innerSpan = 1;
        CGFloat innerReaius = radius - lineWidth - innerSpan;
        CGRect innerRect = CGRectMake(center.x - innerReaius, center.y - innerReaius, innerReaius * 2, innerReaius * 2);
        UIBezierPath *innerPath  = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:innerReaius];
        innerPath.lineWidth = 0.5;
        [innerPath stroke];
        [path appendPath:innerPath];
    }
    
    if (progressPath) {
        progressPath.lineWidth = lineWidth;
        [self.progressTintColor set];
        [progressPath stroke];
        [path appendPath:progressPath];
    }
    
    return path;
}

#pragma mrak - getter setter

- (void)setStatusStyle:(KSStatusStyle)statusStyle
{
    _statusStyle = statusStyle;
    if (statusStyle == KSStatusStyleProgress)
    {
        _statusLabel.hidden = YES;
        _progressLabel.hidden = NO;
        _arcLayer.hidden = YES;
    }
    else if (statusStyle == KSStatusStyleStatus){
        _statusLabel.hidden = NO;
        _progressLabel.hidden = YES;
        _arcLayer.hidden = NO;
    }
    //normal
    else{
        _statusLabel.hidden = YES;
        _progressLabel.hidden = YES;
        _arcLayer.hidden = YES;
    }
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = MIN(1, progress);
    _progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress * 100)];
    [self setNeedsDisplay];
}


- (void)setProgressText:(NSString *)progressText
{
    _progressText = progressText;
    _progressLabel.text = progressText;
    [self setNeedsDisplay];
}


- (void)setStatusText:(NSString *)statusText
{
    _statusText = statusText;
    _statusLabel.text = statusText;
}


- (UIColor *)progressTintColor
{
    if (_disable) {
        return _disableColor;
    }
    return _progressTintColor;
}

- (UIColor *)trackTintColor
{
    if (_disable) {
        return _disableColor;
    }
    return _trackTintColor;
}


- (UIColor *)textColor
{
    if (_disable) {
        return _disableColor;
    }
    return _textColor;
}

- (CGFloat)progress
{
    if (_statusStyle == KSStatusStyleStatus){
        return 1.0;
    }
    if (_statusStyle == KSStatusStyleNormal) {
        return 0;
    }
    return _progress;
}


@end
