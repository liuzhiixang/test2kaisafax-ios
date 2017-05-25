
#import "SQGestureView.h"
#import "SQGestureItemView.h"
#import "SQGestureMgr.h"

//连接的圆最少的个数(选择的最小数量，外部选择不能低于这个数量)
#define KCircleSelectedItemCountLeast    2
//默认链接的最小数量(选择的默认最小数量，外部选择如果没有设置最小数量就是这个)
#define KCircleSelectedItemCountDefault  4

//错误状态下回显的时间
#define KGestureFinishedDisplayTime     1.0f

//错误domain
#define KGestureResultErrorDomain                  @"GestureResultErrorDomain"

@interface SQGestureView()

// 选中的圆的集合
@property (nonatomic, strong) NSMutableArray *circleSet;

// 当前点
@property (nonatomic, assign) CGPoint currentPoint;

// 数组清空标志
@property (nonatomic, assign) BOOL hasClean;

// 最小限制数量
@property (nonatomic, assign) NSInteger inner_minNumberOfSelectedItems;

//第几次输入(包括错误输入)
@property (nonatomic, assign) NSInteger numberOfSelectedIndex;

//第几次正确输入
@property (nonatomic, assign) NSInteger numberOfRightSelectedIndex;

//第一次正确的设置手势密码
@property (nonatomic, strong) NSString *firstRightSelectedGesture;

//跳跃绘制的标志
@property (nonatomic, assign) BOOL canJump;

@end

@implementation SQGestureView

#pragma mark - 重写arrow的setter
- (void)setArrow:(BOOL)arrow
{
    _arrow = arrow;
    
    // 遍历子控件，改变其是否有箭头
    [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
        [circle setArrow:arrow];
    }];
}

- (NSMutableArray *)circleSet
{
    if (_circleSet == nil) {
        _circleSet = [NSMutableArray array];
    }
    return _circleSet;
}

#pragma mark - 初始化方法：初始化type、clip、arrow
/**
 *  初始化方法
 *
 *  @param type  类型
 *  @param clip  是否剪裁
 *  @param arrow 三角形箭头
 */
//- (instancetype)initWithType:(CircleViewType)type clip:(BOOL)clip arrow:(BOOL)arrow
//{
//    if (self = [super init]) {
//        // 解锁视图准备
//        [self lockViewPrepare];
//        
//        self.type = type;
//        self.clip = clip;
//        self.arrow = arrow;
//    }
//    return self;
//}

- (instancetype)init
{
    if (self = [super init]) {
        // 解锁视图准备
        [self lockViewPrepare];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 解锁视图准备
        [self lockViewPrepare];
    }
    return self;
}

#pragma mark ------------内部绘制方法---------------
- (void)drawRect:(CGRect)rect
{
    // 如果没有任何选中按钮， 直接retrun
    if (self.circleSet == nil || self.circleSet.count == 0) return;
    
    //默认线条颜色
    UIColor *color = CircleConnectLineNormalColor;
    NSInteger errorCode = [self getGestureItemState];
    if (errorCode == GestureItemStateError)
    {
        color = CircleConnectLineErrorColor;
    }
    // 绘制图案
    [self connectCirclesInRect:rect lineColor:color];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat itemViewWH = CircleRadius * 2;
    CGFloat marginValue = (self.frame.size.width - 3 * itemViewWH) / 3.0f;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        
        NSUInteger row = idx % 3;
        
        NSUInteger col = idx / 3;
        
        CGFloat x = marginValue * row + row * itemViewWH + marginValue/2;
        
        CGFloat y = marginValue * col + col * itemViewWH + marginValue/2;
        
        CGRect frame = CGRectMake(x, y, itemViewWH, itemViewWH);
        
        // 设置tag -> 密码记录的单元
        subview.tag = idx + 1;
        
        subview.frame = frame;
    }];
}

//最小选择步骤
- (NSInteger)minNumberOfSelectedItems
{
    return _inner_minNumberOfSelectedItems;
}

#pragma mark - 解锁视图准备
/*
 *  解锁视图准备
 */
-(void)lockViewPrepare
{
    //内部标志
    [self setInnerFlag];
    
    [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - CircleViewEdgeMargin * 2, [UIScreen mainScreen].bounds.size.width - CircleViewEdgeMargin * 2)];
    [self setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, CircleViewCenterY)];
    
    // 默认剪裁子控件
    [self setClip:YES];
    
    // 默认有箭头
    [self setArrow:YES];
    //背景颜色
    self.backgroundColor = CircleBackgroundColor;
    //初始化每个item
    for (NSUInteger i=0; i<KCircleWholeItemCountDefault; i++)
    {
        SQGestureItemView *circle = [[SQGestureItemView alloc] init];
        circle.type = GestureItemTypeGesture;
        circle.arrow = self.arrow;
        [self addSubview:circle];
    }
}

- (void)setInnerFlag
{
    //设置默认的最小步骤数
    NSInteger minNum = KCircleSelectedItemCountDefault;
    if (self.delegate && [self.delegate respondsToSelector:@selector(minNumberOfSelectedItemsInGestureView:)])
    {
        NSInteger minNumT = [self.delegate minNumberOfSelectedItemsInGestureView:self];
        if (minNumT >= KCircleSelectedItemCountLeast)
        {
            minNum = minNumT;
        }
    }
    self.inner_minNumberOfSelectedItems = minNum;
    
    //默认不能跳跃中间节点
    BOOL canJumpFlag = NO;
    //设置是否跳跃
    if (self.delegate && [self.delegate respondsToSelector:@selector(canJumpInGestureView:)])
    {
        canJumpFlag = [self.delegate canJumpInGestureView:self];
    }
    self.canJump = canJumpFlag;
}

#pragma mark - touch began - moved - end
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //清理显示
    [self gestureEndResetMembers];
    
    self.currentPoint = CGPointZero;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(circle.frame, point))
        {
            [circle setState:GestureItemStateSelected];
            [self.circleSet addObject:circle];
        }
    }];
    
    // 数组中最后一个对象的处理
    [self circleSetLastObjectWithState:GestureItemStateLastOneSelected];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentPoint = CGPointZero;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(circle.frame, point))
        {
            if ([self.circleSet containsObject:circle])
            {
                //如果包含当前节点，暂时不用处理
            }
            else
            {
                //增加节点item到集合中
                [self.circleSet addObject:circle];
                //是否跳过越过的节点
                if (!self.canJump)
                {
                    // move过程中的连线（包含跳跃连线的处理）
                    // 不跳过，链接中间的节点
                    [self calAngleAndconnectTheJumpedCircle];
                }
            }
        }
        else
        {
            self.currentPoint = point;
        }
    }];
    
    [self.circleSet enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
        [circle setState:GestureItemStateSelected];
        // 如果是登录或者验证原手势密码，就改为对应的状态
        //if (self.type != CircleViewTypeSetting)
        //使用三角箭头标记
        if(self.arrow)
        {
            [circle setState:GestureItemStateLastOneSelected];
        }
    }];
    // 数组中最后一个对象的处理
    [self circleSetLastObjectWithState:GestureItemStateLastOneSelected];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHasClean:NO];
    
    NSString *gesture = [self getGestureResultFromCircleSet:self.circleSet];
    CGFloat length = [gesture length];
    
    if (length == 0)
    {
        return;
    }
    
    // 手势绘制结果处理
    [self gestureEndWith:gesture length:length];
    // 手势结束后是否错误回显重绘，取决于是否延时清空数组和状态复原
    [self handleResultToDisplay];
}

#pragma mark - 是否错误回显重绘
//处理是否错误回显重绘
- (void)handleResultToDisplay
{
    NSInteger errorCode = [self getGestureItemState];
    if (errorCode == GestureItemStateError || errorCode == GestureItemStateLastOneError)
    {
        //错误状态下手势结果的显示时间
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(KGestureFinishedDisplayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //清理显示数据
            [self gestureEndResetMembers];
        });
    }
    else
    {
        //正常情况下立即清理
        //清理显示数据
        [self gestureEndResetMembers];
    }
}

#pragma mark -----------手势结束时的清空操作----------
/**
 *  手势结束时的清空操作
 */
- (void)gestureEndResetMembers
{
    @synchronized(self) { // 保证线程安全
        if (!self.hasClean) {
            
            // 手势完毕，选中的圆回归普通状态
            [self changeCircleInCircleSetWithState:GestureItemStateNormal];
            
            // 清空数组
            [self.circleSet removeAllObjects];
            
            // 清空方向
            [self resetAllCirclesDirect];
            
            // 完成之后改变clean的状态
            [self setHasClean:YES];
        }
    }
}

#pragma mark -------手势路径的处理-------
/**
 *  手势路径的处理
 */
- (void)gestureEndWith:(NSString *)gesture length:(CGFloat)length
{
    //第几次输入(包括错误输入)
    ++self.numberOfSelectedIndex;
    //获取用户定义校验规则的结果
    BOOL checkResult = YES;
    //判断连接数
    if (length < self.inner_minNumberOfSelectedItems)
    {
        // 连接少于最少个数
        // 1.通知代理
        if ([self.delegate respondsToSelector:@selector(gestureView:didFailedWithError:)])
        {
            NSError *error = [self gestureResultErrorWithCode:GestureErrorCodeLessLength];
            [self.delegate gestureView:self didFailedWithError:error];
        }
        
        // 2.改变状态为error
        [self changeCircleInCircleSetWithState:GestureItemStateError];
    }
    else
    {
        // 连接多于最少个数 （>=最小个数）
        if (self.numberOfRightSelectedIndex >= 0)
        {
            if (self.numberOfRightSelectedIndex == 0)
            {
                // 1.通知代理
                if ([self.delegate respondsToSelector:@selector(gestureView:didCompleteAtIndex:gesture:)])
                {
                    checkResult = [self.delegate gestureView:self didCompleteAtIndex:self.numberOfRightSelectedIndex gesture:gesture];
                }
                if (!checkResult)
                {
                    //第一次
                    self.firstRightSelectedGesture = nil;
                    // 2.改变状态为error
                    [self changeCircleInCircleSetWithState:GestureItemStateError];
                    return;
                }
                //第一次
                self.firstRightSelectedGesture = gesture;
            }
            else
            {
                //判断两次输入是否一致
                if ([gesture isEqualToString:self.firstRightSelectedGesture])
                {
                    // 与首次输入一致
                    if ([self.delegate respondsToSelector:@selector(gestureView:didCompleteAtIndex:gesture:)])
                    {
                        checkResult = [self.delegate gestureView:self didCompleteAtIndex:self.numberOfRightSelectedIndex gesture:gesture];
                    }
                    if (!checkResult)
                    {
                        // 2.改变状态为error
                        [self changeCircleInCircleSetWithState:GestureItemStateError];
                        return;
                    }
                }
                else
                {
                    // 与首次输入不一致
                    if ([self.delegate respondsToSelector:@selector(gestureView:didFailedWithError:)])
                    {
                        NSError *error = [self gestureResultErrorWithCode:GestureErrorCodeDifferentData];
                        [self.delegate gestureView:self didFailedWithError:error];
                    }
                    // 2.改变状态为error
                    [self changeCircleInCircleSetWithState:GestureItemStateError];
                    return;
                }
            }
        }
        else
        {
            //self.numberOfRightSelectedIndex < 0;
            // 1.通知代理
            if ([self.delegate respondsToSelector:@selector(gestureView:didFailedWithError:)])
            {
                NSError *error = [self gestureResultErrorWithCode:GestureErrorCodeUnknown];
                [self.delegate gestureView:self didFailedWithError:error];
            }
            
            // 2.改变状态为error
            [self changeCircleInCircleSetWithState:GestureItemStateError];
            return;
        }
        //正确输入的手势密码的index
        ++self.numberOfRightSelectedIndex;
    }
}

//手势操作的结果错误
- (NSError*)gestureResultErrorWithCode:(NSInteger)code
{
    NSError *error = [NSError errorWithDomain:KGestureResultErrorDomain code:code userInfo:nil];
    return error;
}

#pragma mark - 获取当前选中圆的状态
- (GestureItemState)getGestureItemState
{
    return [(SQGestureItemView *)[self.circleSet firstObject] state];
}

#pragma mark - 清空所有子控件的方向
- (void)resetAllCirclesDirect
{
    [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *obj, NSUInteger idx, BOOL *stop) {
        [obj setAngle:0];
    }];
}

#pragma mark -----重置手势控件相关数据为初始状态-------
//重置手势控件相关数据为初始状态
- (void)resetGestureInitializationState
{
    @synchronized(self) { // 保证线程安全
        if (!self.hasClean)
        {
            // 手势完毕，选中的圆回归普通状态
            [self changeCircleInCircleSetWithState:GestureItemStateNormal];
            
            // 清空数组
            // 选中的圆的集合
            [self.circleSet removeAllObjects];
            self.circleSet = nil;
            
            // 清空方向
            [self resetAllCirclesDirect];
            
            // 完成之后改变clean的状态
            [self setHasClean:YES];
            
            // 当前点
            self.currentPoint = CGPointZero;;
            
            //第几次输入(包括错误输入)
            self.numberOfSelectedIndex = 0;
            
            //第几次正确输入
            self.numberOfRightSelectedIndex = 0;
            
            //第一次正确的设置手势密码
            self.firstRightSelectedGesture = nil;
            
            // 最小限制数量
            //跳跃绘制的标志
            [self setInnerFlag];
        }
    }
}

#pragma mark - 对数组中最后一个对象的处理
- (void)circleSetLastObjectWithState:(GestureItemState)state
{
    [[self.circleSet lastObject] setState:state];
}

#pragma mark - 改变选中数组CircleSet子控件状态
- (void)changeCircleInCircleSetWithState:(GestureItemState)state
{
    [self.circleSet enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
        [circle setState:state];
        // 如果是错误状态，那就将最后一个按钮特殊处理
        if (state == GestureItemStateError)
        {
            if (idx == self.circleSet.count - 1)
            {
                [circle setState:GestureItemStateLastOneError];
            }
        }
    }];
    
    [self setNeedsDisplay];
}

#pragma mark - 将circleSet数组解析遍历，拼手势密码字符串
- (NSString *)getGestureResultFromCircleSet:(NSMutableArray *)circleSet
{
    NSMutableString *gesture = [NSMutableString string];
    
    for (SQGestureItemView *circle in circleSet) {
        // 遍历取tag拼字符串
        [gesture appendFormat:@"%@", @(circle.tag)];
    }
    
    return gesture;
}

#pragma mark - 连线绘制图案(以设定颜色绘制)
/**
 *  将选中的圆形以color颜色链接起来
 *
 *  @param rect  图形上下文
 *  @param color 连线颜色
 */
- (void)connectCirclesInRect:(CGRect)rect lineColor:(UIColor *)color
{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //添加路径
    CGContextAddRect(ctx, rect);
    
    //是否剪裁
    [self clipSubviewsWhenConnectInContext:ctx clip:self.clip];
    
    //剪裁上下文
    CGContextEOClip(ctx);
    
    // 遍历数组中的circle
    for (int index = 0; index < self.circleSet.count; index++) {
        
        // 取出选中按钮
        SQGestureItemView *circle = self.circleSet[index];
        
        if (index == 0) { // 起点按钮
            CGContextMoveToPoint(ctx, circle.center.x, circle.center.y);
        }else{
            CGContextAddLineToPoint(ctx, circle.center.x, circle.center.y); // 全部是连线
        }
    }
    
    // 连接最后一个按钮到手指当前触摸得点
    if (CGPointEqualToPoint(self.currentPoint, CGPointZero) == NO) {
        
        [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
            NSInteger errorCode = [self getGestureItemState];
            if (errorCode == GestureItemStateError || errorCode == GestureItemStateLastOneError)
            {
                // 如果是错误的状态下不连接到当前点
            }
            else
            {
                CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
            }
        }];
    }
    
    //线条转角样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    // 设置绘图的属性
    CGContextSetLineWidth(ctx, CircleConnectLineWidth);
    
    // 线条颜色
    [color set];
    
    //渲染路径
    CGContextStrokePath(ctx);
}

#pragma mark - 是否剪裁
/**
 *  是否剪裁子控件
 *
 *  @param ctx  图形上下文
 *  @param clip 是否剪裁
 */
- (void)clipSubviewsWhenConnectInContext:(CGContextRef)ctx clip:(BOOL)clip
{
    if (clip) {
        // 遍历所有子控件
        [self.subviews enumerateObjectsUsingBlock:^(SQGestureItemView *circle, NSUInteger idx, BOOL *stop) {
            CGContextAddEllipseInRect(ctx, circle.frame); // 确定"剪裁"的形状
        }];
    }
}

#pragma mark - 每添加一个圆，就计算一次方向
-(void)calAngleAndconnectTheJumpedCircle
{
    if(self.circleSet == nil || [self.circleSet count] <= 1) return;
    
    //取出最后一个对象
    SQGestureItemView *lastOne = [self.circleSet lastObject];
    
    //倒数第二个
    SQGestureItemView *lastTwo = [self.circleSet objectAtIndex:(self.circleSet.count -2)];
    
    //计算倒数第二个的位置
    CGFloat last_1_x = lastOne.center.x;
    CGFloat last_1_y = lastOne.center.y;
    CGFloat last_2_x = lastTwo.center.x;
    CGFloat last_2_y = lastTwo.center.y;
    
    // 1.计算角度（反正切函数）
    CGFloat angle = atan2(last_1_y - last_2_y, last_1_x - last_2_x) + M_PI_2;
    [lastTwo setAngle:angle];
    
    // 2.处理跳跃连线
    CGPoint center = [self centerPointWithPointOne:lastOne.center pointTwo:lastTwo.center];
    
    SQGestureItemView *centerCircle = [self enumCircleSetToFindWhichSubviewContainTheCenterPoint:center];
    
    if (centerCircle != nil)
    {
        // 把跳过的圆加到数组中，它的位置是倒数第二个
        // 控制不跳跃的绘制连线
        if (![self.circleSet containsObject:centerCircle])
        {
            [self.circleSet insertObject:centerCircle atIndex:self.circleSet.count - 1];
        }
    }
}

#pragma mark - 提供两个点，返回一个它们的中点
- (CGPoint)centerPointWithPointOne:(CGPoint)pointOne pointTwo:(CGPoint)pointTwo
{
    CGFloat x1 = pointOne.x > pointTwo.x ? pointOne.x : pointTwo.x;
    CGFloat x2 = pointOne.x < pointTwo.x ? pointOne.x : pointTwo.x;
    CGFloat y1 = pointOne.y > pointTwo.y ? pointOne.y : pointTwo.y;
    CGFloat y2 = pointOne.y < pointTwo.y ? pointOne.y : pointTwo.y;
    
    return CGPointMake((x1+x2)/2, (y1 + y2)/2);
}

#pragma mark - 给一个点，判断这个点是否被圆包含，如果包含就返回当前圆，如果不包含返回的是nil
/**
 *  给一个点，判断这个点是否被圆包含，如果包含就返回当前圆，如果不包含返回的是nil
 *
 *  @param point 当前点
 *
 *  @return 点所在的圆
 */
- (SQGestureItemView *)enumCircleSetToFindWhichSubviewContainTheCenterPoint:(CGPoint)point
{
    SQGestureItemView *centerCircle;
    for (SQGestureItemView *circle in self.subviews) {
        if (CGRectContainsPoint(circle.frame, point)) {
            centerCircle = circle;
        }
    }
    
    if (![self.circleSet containsObject:centerCircle]) {
        // 这个circle的角度和倒数第二个circle的角度一致
        centerCircle.angle = [[self.circleSet objectAtIndex:self.circleSet.count - 2] angle];
    }
    
    return centerCircle; // 注意：可能返回的是nil，就是当前点不在圆内
}

@end
