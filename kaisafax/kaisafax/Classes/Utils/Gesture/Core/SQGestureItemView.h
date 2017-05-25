
#import <UIKit/UIKit.h>

/**
 *  单个圆的各种状态
 */
typedef enum{
    GestureItemStateNormal = 1,
    GestureItemStateSelected,
    GestureItemStateError,
    GestureItemStateLastOneSelected,
    GestureItemStateLastOneError
}GestureItemState;

/**
 *  单个圆的用途类型
 */
typedef enum
{
    GestureItemTypeInfo = 1,
    GestureItemTypeGesture
}GestureItemType;

@interface SQGestureItemView : UIView

/**
 *  所处的状态
 */
@property (nonatomic, assign) GestureItemState state;

/**
 *  类型
 */
@property (nonatomic, assign) GestureItemType type;

/**
 *  是否有箭头 default is YES
 */
@property (nonatomic, assign) BOOL arrow;

/** 角度 */
@property (nonatomic,assign) CGFloat angle;

@end
