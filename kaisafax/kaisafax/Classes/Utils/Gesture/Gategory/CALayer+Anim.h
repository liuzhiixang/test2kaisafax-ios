
#import <QuartzCore/QuartzCore.h>

@interface CALayer (Animation)

/*
 *  摇动
 */
-(void)shake;

-(void)shakeWithDelegate:(id<CAAnimationDelegate>)delegate;

-(void)shakeWithDuration:(CFTimeInterval)duration repeatCount:(NSInteger)repeatCount delegate:(id<CAAnimationDelegate>)delegate;

@end
