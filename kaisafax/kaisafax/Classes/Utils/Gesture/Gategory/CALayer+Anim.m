
#import "CALayer+Anim.h"

//默认动画时间(一次)
#define KAnimationDefaultDuration       0.3f
//默认动画重复次数
#define KAnimationDefaultRepeatCount    3

@implementation CALayer (Animation)

- (void)shake
{
    [self shakeWithDelegate:nil];
}

/*
 *  摇动
 */
-(void)shakeWithDelegate:(id<CAAnimationDelegate>)delegate
{
    CFTimeInterval duration = 0.3f;
    NSInteger repeatCount = 3;
    [self shakeWithDuration:duration repeatCount:repeatCount delegate:delegate];
}

/*
 *  摇动
 */
-(void)shakeWithDuration:(CFTimeInterval)duration repeatCount:(NSInteger)repeatCount delegate:(id<CAAnimationDelegate>)delegate
{
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    kfa.delegate = delegate;
    
    CGFloat s = 5;
    
    kfa.values = @[@(-s),@(0),@(s),@(0),@(-s),@(0),@(s),@(0)];
    
    //时长
    kfa.duration = 0.3f;
    
    //重复
    kfa.repeatCount = 3;
    
    //移除
    kfa.removedOnCompletion = YES;
    
    [self addAnimation:kfa forKey:@"shake"];
}

@end
