//
// JXFaceView.h
//

#import <UIKit/UIKit.h>

#import "JXFacialView.h"

@protocol JXFaceDelegate

@required
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmotion:(NSString *)emotion;

@end

@interface JXFaceView : UIView<JXFacialViewDelegate>

@property(nonatomic, assign) id<JXFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

/*!
 @method
 @brief 通过数据源获取表情分组数,
 @discussion
 @param number 分组数
 @param emotionManagers 表情分组列表
 @result
 */
- (void)setEmotionManagers:(NSArray *)emotionManagers;

@end
