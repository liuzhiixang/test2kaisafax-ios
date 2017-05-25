//
//  KSServerStatusView.h
//  kaisafax
//
//  Created by semny on 16/8/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText/YYText.h>

@class KSServerStatusView;

@protocol ServerStatusViewDelegate <NSObject>
@optional

- (void)serverViewCancel:(KSServerStatusView *)serverView;

@end


@interface KSServerStatusView : UIView

//@property (weak, nonatomic) IBOutlet UILabel *commentLabel1;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel2;
@property (weak, nonatomic) IBOutlet YYLabel *commentLabel3;
//@property (weak, nonatomic) IBOutlet UILabel *commentLabel3;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

//最大高度尺寸(暂时只需要考虑高度)
@property (assign, nonatomic) CGFloat maxHeight;

@property (weak, nonatomic) id<ServerStatusViewDelegate> delegate;
@end
