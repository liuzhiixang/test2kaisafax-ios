//
//  KSContactPickCell.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSContactPickCell  @"KSContactPickCell"

@protocol  KSContactPickCellDelegate<NSObject>
@optional
-(void)contactPick:(UIButton*)btn;
@end

@interface KSContactPickCell : UITableViewCell
-(void)updateItem:(NSString*)str;
@property (weak, nonatomic) id<KSContactPickCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraintW;
@property (weak, nonatomic) IBOutlet UIButton *selBtn;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@end
