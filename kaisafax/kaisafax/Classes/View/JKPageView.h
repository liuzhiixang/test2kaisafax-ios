//
//  JKPageView.h
//  JKPageView
//
//  Created by Jjyo on 16/4/24.
//  Copyright © 2016年 Jjyo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKPageView;

typedef NS_ENUM(NSInteger, JKPageControlPosition) {
    JKPageControlPositionTopLeft,
    JKPageControlPositionTopCenter,
    JKPageControlPositionTopRight,
    JKPageControlPositionBottomLeft,
    JKPageControlPositionBottomCenter,
    JKPageControlPositionBottomRight
};



@protocol JKPageViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInPageView:(JKPageView *)pageView;
- (UIView *)pageView:(JKPageView *)pageView viewAtIndex:(NSInteger)index;
@optional
- (void)pageView:(JKPageView *)pageView didTapAtIndex:(NSInteger)index;
- (void)pageView:(JKPageView *)pageView didScorllIndex:(NSInteger)index;
@end

@interface JKPageView : UIView
@property (nonatomic, weak) IBOutlet id<JKPageViewDelegate> delegate;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) BOOL autoScroll;  // default is YES, set NO to turn off autoScroll
@property (nonatomic, assign) NSUInteger scrollInterval;    // scroll interval, unit: second, default is 2 seconds
@property (nonatomic, assign) JKPageControlPosition pageControlPosition;    // pageControl position, defautl is bottomright
@property (nonatomic, assign) BOOL hidePageControl; // hide pageControl, default is NO
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) BOOL endlessScroll; // endless scroll, default is NO
@property (nonatomic, assign) BOOL isVertical;
@property(nonatomic,getter=isScrollEnabled) BOOL scrollEnabled;

/**
 *  Reload everything
 */
- (void)reloadData;

/**
 *  Stop timer before your view controller is poped
 */
- (void)stopTimer;

@end
