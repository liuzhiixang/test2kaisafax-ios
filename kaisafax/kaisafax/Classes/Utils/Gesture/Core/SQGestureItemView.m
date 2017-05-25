
#import "SQGestureItemView.h"
#import "SQGestureConfig.h"

@interface SQGestureItemView()

/**
 *  外环颜色
 */
@property (nonatomic, strong) UIColor *outCircleColor;

/**
 *  实心圆颜色
 */
@property (nonatomic, strong) UIColor *inCircleColor;

/**
 *  三角形颜色
 */
@property (nonatomic, strong) UIColor *trangleColor;

@end

@implementation SQGestureItemView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = CircleBackgroundColor;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = CircleBackgroundColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat radio = 0.0f;
    CGRect circleRect = CGRectMake(CircleEdgeWidth, CircleEdgeWidth, rect.size.width - 2 * CircleEdgeWidth, rect.size.height - 2 * CircleEdgeWidth);
    
    //内部实心圆
    if (self.type == GestureItemTypeGesture)
    {
        radio = CircleRadio;
    } else if (self.type == GestureItemTypeInfo) {
        radio = 1;
    }
    
    // 上下文旋转
    [self transFormCtx:ctx rect:rect];
    
    // 画圆环
    [self drawEmptyCircleWithContext:ctx rect:circleRect color:self.outCircleColor];
    
    // 画实心圆
    [self drawSolidCircleWithContext:ctx rect:rect radio:radio color:self.inCircleColor];
 
    //是否需要箭头
    if (self.arrow)
    {
        // 画三角形箭头
        [self drawTrangleWithContext:ctx topPoint:CGPointMake(rect.size.width/2, 10) length:kTrangleLength color:self.trangleColor];
    }
}

#pragma mark - 画外圆环
/**
 *  画外圆环
 *
 *  @param ctx   图形上下文
 *  @param rect  绘画范围
 *  @param color 绘制颜色
 */
- (void)drawEmptyCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect color:(UIColor *)color
{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, rect);
    CGContextAddPath(ctx, circlePath);
    [color set];
    CGContextSetLineWidth(ctx, CircleEdgeWidth);
    CGContextStrokePath(ctx);
    CGPathRelease(circlePath);
}

#pragma mark - 画实心圆
/**
 *  画实心圆
 *
 *  @param ctx   图形上下文
 *  @param rect  绘制范围
 *  @param radio 占大圆比例
 *  @param color 绘制颜色
 */
- (void)drawSolidCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect radio:(CGFloat)radio color:(UIColor *)color
{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(rect.size.width/2 * (1 - radio) + CircleEdgeWidth, rect.size.height/2 * (1 - radio) + CircleEdgeWidth, rect.size.width * radio - CircleEdgeWidth * 2, rect.size.height * radio - CircleEdgeWidth * 2));
    [color set];
    CGContextAddPath(ctx, circlePath);
    CGContextFillPath(ctx);
    CGPathRelease(circlePath);
}

#pragma mark - 画三角形
/**
 *  画三角形
 *
 *  @param ctx    图形上下文
 *  @param point  顶点
 *  @param length 边长
 *  @param color  绘制颜色
 */
- (void)drawTrangleWithContext:(CGContextRef)ctx topPoint:(CGPoint)point length:(CGFloat)length color:(UIColor *)color
{
    CGMutablePathRef trianglePathM = CGPathCreateMutable();
    CGPathMoveToPoint(trianglePathM, NULL, point.x, point.y);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x - length/2, point.y + length/2);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x + length/2, point.y + length/2);
    CGContextAddPath(ctx, trianglePathM);
    [color set];
    CGContextFillPath(ctx);
    CGPathRelease(trianglePathM);
}

/*
 *  上下文旋转
 */
-(void)transFormCtx:(CGContextRef)ctx rect:(CGRect)rect{
//    if(self.angle == 0) return;
    CGFloat translateXY = rect.size.width * .5f;
    //平移
    CGContextTranslateCTM(ctx, translateXY, translateXY);
    CGContextRotateCTM(ctx, self.angle);
    //再平移回来
    CGContextTranslateCTM(ctx, -translateXY, -translateXY);
}

/**
 *  圆环绘制颜色的getter
 */
- (UIColor *)outCircleColor
{
    UIColor *color;
    switch (self.state) {
        case GestureItemStateNormal:
            color = GestureItemStateNormalOutsideColor;
            break;
        case GestureItemStateSelected:
            color = GestureItemStateSelectedOutsideColor;
            break;
        case GestureItemStateError:
            color = GestureItemStateErrorOutsideColor;
            break;
        case GestureItemStateLastOneSelected:
            color = GestureItemStateSelectedOutsideColor;
            break;
        case GestureItemStateLastOneError:
            color = GestureItemStateErrorOutsideColor;
            break;
        default:
            color = GestureItemStateNormalOutsideColor;
            break;
    }
    return color;
}

/**
 *  实心圆绘制颜色的getter
 */
- (UIColor *)inCircleColor
{
    UIColor *color;
    switch (self.state) {
        case GestureItemStateNormal:
            color = GestureItemStateNormalInsideColor;
            break;
        case GestureItemStateSelected:
            color = GestureItemStateSelectedInsideColor;
            break;
        case GestureItemStateError:
            color = GestureItemStateErrorInsideColor;
            break;
        case GestureItemStateLastOneSelected:
            color = GestureItemStateSelectedInsideColor;
            break;
        case GestureItemStateLastOneError:
            color = GestureItemStateErrorInsideColor;
            break;
        default:
            color = GestureItemStateNormalInsideColor;
            break;
    }
    return color;
}

/**
 *  三角形颜色的getter
 */
- (UIColor *)trangleColor
{
    UIColor *color;
    switch (self.state) {
        case GestureItemStateNormal:
            color = GestureItemStateNormalTrangleColor;
            break;
        case GestureItemStateSelected:
            color = GestureItemStateSelectedTrangleColor;
            break;
        case GestureItemStateError:
            color = GestureItemStateErrorTrangleColor;
            break;
        case GestureItemStateLastOneSelected:
            color = GestureItemStateNormalTrangleColor;
            break;
        case GestureItemStateLastOneError:
            color = GestureItemStateNormalTrangleColor;
            break;
        default:
            color = GestureItemStateNormalTrangleColor;
            break;
    }
    return color;
}

/**
 *  重写angle的setter
 */
- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    
    [self setNeedsDisplay];
}

/**
 *  重写state Setter
 */
- (void)setState:(GestureItemState)state
{
    _state = state;
    
    [self setNeedsDisplay];
}

@end