
#import "SQGestureInfoView.h"
#import "SQGestureConfig.h"
#import "SQGestureItemView.h"

//Gesture item的tag基数
#define KGestureItemTagBaseValue 161100

@interface SQGestureInfoView()

//手势子视图的数组
@property (nonatomic, strong) NSMutableArray<SQGestureItemView*> *allItemsArray;
@property (nonatomic, strong) NSMutableArray<SQGestureItemView*> *selectedItemsArray;
@end

@implementation SQGestureInfoView

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
    if (self = [super initWithCoder:aDecoder])
    {
        DEBUGG(@"%s 111", __FUNCTION__);
        // 解锁视图准备
        [self lockViewPrepare];
    }
    return self;
}

/*
 *  解锁视图准备
 */
-(void)lockViewPrepare
{
    DEBUGG(@"%s 111", __FUNCTION__);
    
    //item视图数组
    self.allItemsArray         = [NSMutableArray array];
    self.selectedItemsArray = [NSMutableArray array];
    
    //背景颜色
    self.backgroundColor = CircleBackgroundColor;
    
    //初始化子视图
    for (NSUInteger i=0; i<KCircleWholeItemCountDefault; i++)
    {
        DEBUGG(@"%s index<%d>", __FUNCTION__, (int)i);
        SQGestureItemView *item = [[SQGestureItemView alloc] init];
        item.tag = KGestureItemTagBaseValue+i;
        item.type = GestureItemTypeInfo;
        [self addSubview:item];
        //加入数组
        [self.allItemsArray addObject:item];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    DEBUGG(@"%s 111", __FUNCTION__);
    
    CGFloat itemViewWH = CircleInfoRadius * 2;
    CGFloat marginValue = (self.frame.size.width - 3 * itemViewWH) / 3.0f;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        DEBUGG(@"%s 222", __FUNCTION__);
        //判断是否为item视图
        if ([subview isKindOfClass:[SQGestureItemView class]])
        {
            NSInteger tag = subview.tag;
            NSInteger index = tag - KGestureItemTagBaseValue;
            //行列
            NSUInteger row = index % 3;
            NSUInteger col = index / 3;
            //设置视图位置
            CGFloat x = marginValue * row + row * itemViewWH + marginValue/2;
            CGFloat y = marginValue * col + col * itemViewWH + marginValue/2;
            CGRect frame = CGRectMake(x, y, itemViewWH, itemViewWH);
            subview.frame = frame;
            // 设置tag -> 密码记录的单元
            //subview.tag = idx + 1;
        }
    }];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    DEBUGG(@"%s 111", __FUNCTION__);
    if (self.selectedItemsArray.count == 0)
    {
        return;
    }
    
    DEBUGG(@"%s 222", __FUNCTION__);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, CircleConnectLineWidth);
    [CircleConnectLineNormalColor set];
    
    CGPoint addLines[9];
    int count = 0;
    for (SQGestureItemView *item in self.selectedItemsArray)
    {
        CGPoint point = CGPointMake(item.center.x, item.center.y);
        DEBUGG(@"%s index<%d> point: <%f, %f>", __FUNCTION__, count, point.x, point.y);
        addLines[count++] = point;
    }
    
    CGContextAddLines(context, addLines, count);
    CGContextStrokePath(context);
}

#pragma mark - Public

- (void)showGesture:(NSString *)gesture
{
    [self reset];
    
    DEBUGG(@"%s gesture: %@", __FUNCTION__, gesture);
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:gesture.length];
    for (int i = 0; i < gesture.length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *numberStr = [gesture substringWithRange:range];
        NSNumber *number = [NSNumber numberWithInt:numberStr.intValue];
        [numbers addObject:number];
        NSInteger index = 0;
        SQGestureItemView *item = nil;
        if ((index=number.intValue-1) < self.allItemsArray.count && index >= 0)
        {
            item = self.allItemsArray[index];
        }
        DEBUGG(@"%s index<%d> item: %@", __FUNCTION__, i, item);
        if (item)
        {
            [item setState:GestureItemStateSelected];
            [self.selectedItemsArray addObject:item];
        }
    }
    [self setNeedsDisplay];
}

- (void)resetGestureInitializationState
{
    [self reset];
    [self setNeedsDisplay];
}

- (void)reset
{
    for (SQGestureItemView *item in self.allItemsArray)
    {
        [item setState:GestureItemStateNormal];
    }
    [self.selectedItemsArray removeAllObjects];
}
@end

