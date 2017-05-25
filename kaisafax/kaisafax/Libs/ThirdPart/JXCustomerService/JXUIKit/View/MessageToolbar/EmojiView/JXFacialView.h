//
// JXFacialView.h
//

#import <UIKit/UIKit.h>

@protocol JXFacialViewDelegate

@optional
- (void)selectedFacialView:(NSString *)str;
- (void)deleteSelected:(NSString *)str;
- (void)sendFace;
- (void)sendFace:(NSString *)str;

@end

@class EaseEmotionManager;

@interface JXFacialView : UIView {
    NSMutableArray *_faces;
}

@property(nonatomic) id<JXFacialViewDelegate> delegate;

@property(nonatomic, readonly) NSArray *faces;

- (void)loadFacialView:(EaseEmotionManager *)emotionManager size:(CGSize)size;

//-(void)loadFacialView:(int)page size:(CGSize)size;

@end
