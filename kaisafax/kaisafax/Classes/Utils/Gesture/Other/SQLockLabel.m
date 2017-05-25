
#import "SQLockLabel.h"
#import "SQGestureConfig.h"
#import "CALayer+Anim.h"
/**
 *  普通状态下文字提示的颜色
 */
#define KTextColorNormalState GES_UIColorFromHex(0xffffff)

/**
 *  警告状态下文字提示的颜色
 */
#define KTextColorWarningState GES_UIColorFromHex(0xe60012)

@interface SQLockLabel()<CAAnimationDelegate>

//开始block
@property (nonatomic, copy) void (^startBlock)(void);
//开始block
@property (nonatomic, copy) void (^finishBlock)(BOOL finish);

@end

@implementation SQLockLabel


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        //视图初始化
        [self viewPrepare];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    
    if(self)
    {
        //视图初始化
        [self viewPrepare];
    }
    
    return self;
}

/*
 *  视图初始化
 */
-(void)viewPrepare{
    
    [self setFont:[UIFont systemFontOfSize:14.0f]];
    [self setTextAlignment:NSTextAlignmentCenter];
}

/*
 *  普通提示信息
 */
-(void)showNormalMsg:(NSString *)msg{
    
    [self setText:msg];
    [self setTextColor:KTextColorNormalState];
}

/*
 *  警示信息
 */
-(void)showWarnMsg:(NSString *)msg{
    
    [self setText:msg];
    [self setTextColor:KTextColorWarningState];
}

/*
 *  警示信息(shake)
 */
-(void)showWarnMsgAndShake:(NSString *)msg
{
    [self showWarnMsgAndShake:msg startBlock:nil finishBlock:nil];
}

-(void)showWarnMsgAndShake:(NSString *)msg startBlock:(void (^)(void))startBlock finishBlock:(void (^)(BOOL finish))finishBlock
{
    [self setText:msg];
    [self setTextColor:KTextColorWarningState];
    
    //设置block
    self.startBlock = startBlock;
    self.finishBlock = finishBlock;
    
    //添加一个shake动画
    [self.layer shakeWithDelegate:self];
}

#pragma mark -----CAAnimationDelegate------
- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.startBlock)
    {
        self.startBlock();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.finishBlock)
    {
        self.finishBlock(flag);
    }
}
@end
