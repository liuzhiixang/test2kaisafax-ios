//
//  KSLineChartView.m
//  kaisafax
//
//  Created by Jjyo on 16/7/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLineChartView.h"


#define DEFAULT_PADDING UIEdgeInsetsMake(16, 8, 8, 16)
#define DEFAULT_TEXT_SIZE 10
#define DEFAULT_TEXT_COLOR [UIColor lightGrayColor]
#define DEFAULT_Y_GRID_COLOR [UIColor lightGrayColor]
#define DEFAULT_LINE_COLOR  [UIColor redColor]
#define DEAFULT_Y_LABEL_AXIS_SPAN 8
#define DEAFULT_X_LABEL_AXIS_SPAN 8
#define DEFAULT_LINE_WIDTH 1

@interface KSLineChartView ()

@property (copy, nonatomic) NSArray *xLabelArray;
@property (copy, nonatomic) NSArray *yLabelArray;

@property (assign, nonatomic) NSInteger yLabelMaxWidth;
@property (assign, nonatomic) NSInteger fontHeight;

@property (assign, nonatomic) CGRect canvasFrame;
@property (assign, nonatomic) CGSize gridSize;

@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (strong, nonatomic) CABasicAnimation *pathAnimation; // will be set to nil if _displayAnimation is NO
@end


@implementation KSLineChartView

- (void)applyNUI
{
    NSString *nuiClass = self.nuiClass;
    if (nuiClass) {
        [NUIRenderer renderView:self];
        if ([NUISettings hasProperty:@"padding" withClass:nuiClass]) {
            _padding = [NUISettings getEdgeInsets:@"padding" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"font-size" withClass:nuiClass])
        {
            _textSize = [NUISettings getFloat:@"font-size" withClass:nuiClass];
        }
        if([NUISettings hasProperty:@"font-color" withClass:nuiClass])
        {
            _textColor = [NUISettings getColor:@"font-color" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"y-grid-color" withClass:nuiClass]) {
            _yGridColor = [NUISettings getColor:@"y-grid-color" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"y-label-axis-span" withClass:nuiClass]) {
            _yLabelAxisSpan = [NUISettings getFloat:@"y-label-axis-span" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"x-label-axis-span" withClass:nuiClass]) {
            _xLabelAxisSpan = [NUISettings getFloat:@"x-label-axis-span" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"line-color" withClass:nuiClass]) {
            _lineColor = [NUISettings getColor:@"line-color" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"line-width" withClass:nuiClass]) {
            _lineWidth = [NUISettings getFloat:@"line-width" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"show-smooth-lines" withClass:nuiClass]) {
            _showSmoothLines = [NUISettings getBoolean:@"show-smooth-lines" withClass:nuiClass];
        }
        if ([NUISettings hasProperty:@"display-animated" withClass:nuiClass]) {
            _displayAnimated = [NUISettings getBoolean:@"display-animated" withClass:nuiClass];
        }
        
    }
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDefault];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefault];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefault];
    }
    return self;
}


- (void)setupDefault
{
    if (UIEdgeInsetsEqualToEdgeInsets(_padding, UIEdgeInsetsZero)) {
        _padding = DEFAULT_PADDING;
    }
    if (_textSize == 0) {
        _textSize = DEFAULT_TEXT_SIZE;
    }
    if (!_textColor) {
        _textColor = DEFAULT_TEXT_COLOR;
    }
    if (!_yGridColor) {
        _yGridColor = DEFAULT_Y_GRID_COLOR;
    }
    if (!_lineColor) {
        _lineColor = DEFAULT_LINE_COLOR;
    }
    if (_yLabelAxisSpan == 0) {
        _yLabelAxisSpan = DEAFULT_Y_LABEL_AXIS_SPAN;
    }
    if (_xLabelAxisSpan == 0) {
        _xLabelAxisSpan = DEAFULT_X_LABEL_AXIS_SPAN;
    }
    if (_lineWidth == 0) {
        _lineWidth = DEFAULT_LINE_WIDTH;
    }
    [self applyNUI];
}

- (UILabel *)labelWithText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = _textColor;
    label.font = [UIFont systemFontOfSize:_textSize];
    return label;
}


- (void)setXLabels:(NSArray *)xLabels
{
    
    _xLabels = xLabels;
    [_xLabelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *text in xLabels) {
        UILabel *label = [self labelWithText:text];
        [array addObject:label];
        [self addSubview:label];
    }
    self.xLabelArray = array;
}

- (void)setYLabels:(NSArray *)yLabels
{
    _yLabels = yLabels;
    [_yLabelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger maxWidth = 0;
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *text in yLabels) {
        UILabel *label = [self labelWithText:text];
        label.textAlignment = NSTextAlignmentRight;
        CGSize size =  [KSLineChartView sizeOfString:text withWidth:CGRectGetWidth(self.frame) font:label.font];
        maxWidth = MAX(maxWidth, size.width);
        [array insertObject:label atIndex:0];
        [self addSubview:label];
    }
    _yLabelMaxWidth = maxWidth + 4;
    self.yLabelArray = array;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _fontHeight = _textSize;
    
    
    
    _canvasFrame = CGRectMake(_padding.left +  _yLabelMaxWidth + _yLabelAxisSpan,
                              _padding.top,
                              CGRectGetWidth(self.frame) - _padding.left - _padding.right - _yLabelMaxWidth - _yLabelAxisSpan,
                              CGRectGetHeight(self.frame) - _padding.top - _padding.bottom - _fontHeight - _xLabelAxisSpan);
    
    CGFloat lastXLabelWidth = 0;
    UILabel *lastXLabel = [_xLabelArray lastObject];
    if (lastXLabel) {
         CGSize size =  [KSLineChartView sizeOfString:lastXLabel.text withWidth:CGRectGetWidth(self.frame) font:lastXLabel.font];
        lastXLabelWidth = size.width + 4;
    }
    
    _gridSize = CGSizeMake((CGRectGetWidth(_canvasFrame) - lastXLabelWidth) / (_xLabelArray.count - 1), CGRectGetHeight(_canvasFrame) / (_yLabelArray.count - 1));
    
    //y轴标签
    [_yLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.frame = CGRectMake(CGRectGetMinX(_canvasFrame) - _yLabelAxisSpan - _yLabelMaxWidth, CGRectGetMinY(_canvasFrame) + idx * _gridSize.height - _fontHeight / 2,  _yLabelMaxWidth, _fontHeight);
    }];
    
    //x 轴标签
    [_xLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.frame = CGRectMake(CGRectGetMinX(_canvasFrame) + _gridSize.width * idx , CGRectGetMaxY(_canvasFrame) + _xLabelAxisSpan, _gridSize.width, _fontHeight);
    }];
    
}


- (void)initLineLayer
{
    [_lineLayer removeFromSuperlayer];
    CAShapeLayer *chartLine = [CAShapeLayer layer];
    chartLine.lineCap = kCALineCapButt;
    chartLine.lineJoin = kCALineJoinMiter;
    chartLine.fillColor = [[UIColor clearColor] CGColor];
    chartLine.lineWidth = _lineWidth;
    chartLine.strokeEnd = 0.0;
    _lineLayer = chartLine;
    [self.layer addSublayer:chartLine];
}


#pragma mark - draw something

- (void)strokeChart:(CGRect)rect
{
    if (_lineDatas.count == 0) {
        return;
    }
    
    UIBezierPath *progressline = [UIBezierPath bezierPath];
    
    NSMutableArray<NSDictionary<NSString *, NSValue *> *> *progrssLinePaths = [NSMutableArray new];
    NSMutableArray *linePointsArray = [[NSMutableArray alloc] init];
    NSMutableArray *lineStartEndPointsArray = [[NSMutableArray alloc] init];
    
    int last_x = 0;
    int last_y = 0;
    for (int i = 0; i < _lineDatas.count; i++) {
        CGFloat yValue = [_lineDatas[i] floatValue];
        
        CGFloat innerGrade;
        if (!(_yMaxValue - _yMinValue)) {
            innerGrade = 0.5;
        } else {
            innerGrade = (yValue - _yMinValue) / (_yMaxValue - _yMinValue);
        }
        
        int x = CGRectGetMinX(rect) + _gridSize.width * i;
        
        int y = CGRectGetMaxY(rect) - (innerGrade * CGRectGetHeight(rect));
        
        if (i > 0) {
            [progrssLinePaths addObject:@{@"from" : [NSValue valueWithCGPoint:CGPointMake(last_x, last_y)],
                                          @"to" : [NSValue valueWithCGPoint:CGPointMake(x, y)]}];
        }
        [linePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        last_x = x;
        last_y = y;
    }
    
    if (self.showSmoothLines && _lineDatas.count >= 4) {
        [progressline moveToPoint:[progrssLinePaths[0][@"from"] CGPointValue]];
        for (NSDictionary<NSString *, NSValue *> *item in progrssLinePaths) {
            CGPoint p1 = [item[@"from"] CGPointValue];
            CGPoint p2 = [item[@"to"] CGPointValue];
            [progressline moveToPoint:p1];
            CGPoint midPoint = [KSLineChartView midPointBetweenPoint1:p1 andPoint2:p2];
            [progressline addQuadCurveToPoint:midPoint
                                 controlPoint:[KSLineChartView controlPointBetweenPoint1:midPoint andPoint2:p1]];
            [progressline addQuadCurveToPoint:p2
                                 controlPoint:[KSLineChartView controlPointBetweenPoint1:midPoint andPoint2:p2]];
        }
    } else {
        for (NSDictionary<NSString *, NSValue *> *item in progrssLinePaths) {
            if (item[@"from"]) {
                [progressline moveToPoint:[item[@"from"] CGPointValue]];
                [lineStartEndPointsArray addObject:item[@"from"]];
            }
            if (item[@"to"]) {
                [progressline addLineToPoint:[item[@"to"] CGPointValue]];
                [lineStartEndPointsArray addObject:item[@"to"]];
            }
        }
    }
    
    
    //draw layer
    [self initLineLayer];
    
    CAShapeLayer *chartLine = _lineLayer;
    UIGraphicsBeginImageContext(rect.size);
    // setup the color of the chart line
    chartLine.strokeColor = [_lineColor CGColor];
    chartLine.path = progressline.CGPath;
    
    [CATransaction begin];
    
    [chartLine addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
    chartLine.strokeEnd = 1.0;
    
    [CATransaction commit];
    
    UIGraphicsEndImageContext();
}

- (void)drawYGridLines:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx,NO);//关闭抗锯齿即可, 才能画出1px 的线
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    for (NSUInteger i = 0; i < _yLabelArray.count; i++) {
        CGPoint point = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + i * _gridSize.height);
        CGContextMoveToPoint(ctx, point.x, point.y);
        CGContextSetLineWidth(ctx, 0.5);
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), point.y);
        CGContextStrokePath(ctx);
    }
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawYGridLines:_canvasFrame];
    [self strokeChart: _canvasFrame];
}



#pragma mark - Tools

- (CABasicAnimation *)pathAnimation {
    if (self.displayAnimated && !_pathAnimation) {
        _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathAnimation.duration = 1.0;
        _pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pathAnimation.fromValue = @0.0f;
        _pathAnimation.toValue = @1.0f;
    }
    return _pathAnimation;
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

+ (CGPoint)midPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
}

+ (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    CGPoint controlPoint = [self midPointBetweenPoint1:point1 andPoint2:point2];
    CGFloat diffY = abs((int) (point2.y - controlPoint.y));
    if (point1.y < point2.y)
        controlPoint.y += diffY;
    else if (point1.y > point2.y)
        controlPoint.y -= diffY;
    return controlPoint;
}

@end
