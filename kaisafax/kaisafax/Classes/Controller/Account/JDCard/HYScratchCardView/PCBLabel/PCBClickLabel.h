//
//  PCBClickLabel.h
//  部分label点击事件
// 简书 http://www.jianshu.com/u/bb2db3428fff
//  Created by pcb on 16/2/5.
//  Copyright © 2016年 DWade. All rights reserved.
//

#import <UIKit/UIKit.h>
//点击按钮
typedef void (^clickBlock)();
@interface PCBClickLabel : UIView
- (instancetype)initLabelViewWithLab:(NSString *)text clickTextRange:(NSRange)clickTextRange clickAtion:(clickBlock)clickAtion;
@property (nonatomic, copy)clickBlock clickBlock;
@end
