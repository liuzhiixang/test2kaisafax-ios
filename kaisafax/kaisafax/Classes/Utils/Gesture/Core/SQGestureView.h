
#import <UIKit/UIKit.h>
#import "SQGestureConfig.h"

///**
// *  手势密码界面用途类型
// */
//typedef enum{
//    CircleViewTypeSetting = 1, // 设置手势密码
//    CircleViewTypeLogin,       // 登陆手势密码
//    CircleViewTypeVerify       // 验证旧手势密码
//}CircleViewType;

//手势操作错误
typedef NS_ENUM(NSInteger, GestureErrorCode)
{
    GestureErrorCodeUnknown = 0, //未知错误
    GestureErrorCodeLessLength = 1, //不符合最小长度
    GestureErrorCodeDifferentData = 2, //与初始数据不一致
};

@class SQGestureView;

@protocol SQGestureViewDelegate <NSObject>

@optional

#pragma mark - 设置手势密码代理方法
//手势操作完成(正常完成),校验登录的时候输入密码是否正确；校验两次输入的设置密码是否正确;
- (BOOL)gestureView:(SQGestureView *)gestureView didCompleteAtIndex:(NSInteger)index gesture:(NSString*)gesture;

//出现错误 如：1.密码格式字段不对; 2.设置的时候第一次第二次不一致；
- (void)gestureView:(SQGestureView *)gestureView didFailedWithError:(NSError*)error;

//手势最小步骤检测数设置
- (NSInteger)minNumberOfSelectedItemsInGestureView:(SQGestureView *)gestureView;

//是否可以跳跃的标志
- (BOOL)canJumpInGestureView:(SQGestureView *)gestureView;

//此回调方法用于用户自定义校验规则
//- (BOOL)gestureView:(SQGestureView *)gestureView checkGesture:(NSString*)gesture;

@end

@interface SQGestureView : UIView

/**
 *  是否剪裁 default is YES
 */
@property (nonatomic, assign) BOOL clip;

//是否有箭头 default is YES
@property (nonatomic, assign) BOOL arrow;

//最小的选择数量
@property (nonatomic, assign, readonly) NSInteger minNumberOfSelectedItems;

// 代理
@property (nonatomic, weak) id<SQGestureViewDelegate> delegate;

#pragma mark -----重置手势控件相关数据为初始状态-------
//重置手势控件相关数据为初始状态
- (void)resetGestureInitializationState;

@end
