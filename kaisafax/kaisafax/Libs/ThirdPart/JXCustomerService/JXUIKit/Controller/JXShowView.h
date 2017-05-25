//
//  JXShowView.h
//  JXUIKit
//
//  Created by 王jie on 16/5/19.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXMessage.h"

@protocol JXShowViewDelegate <NSObject>

- (void)didSelectedUrlString:(NSString *)urlString;

@end

@interface JXShowView : UIView

@property (nonatomic, strong) JXMessage *message;
@property (nonatomic, weak) id<JXShowViewDelegate> delegate;

- (void)loadShowView;
@end
