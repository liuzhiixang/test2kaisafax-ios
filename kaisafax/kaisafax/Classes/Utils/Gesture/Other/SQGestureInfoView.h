
#import <UIKit/UIKit.h>

@interface SQGestureInfoView : UIView

#pragma mark - Public
//显示密码路径
- (void)showGesture:(NSString *)gesture;

//重新加载
- (void)resetGestureInitializationState;

@end
