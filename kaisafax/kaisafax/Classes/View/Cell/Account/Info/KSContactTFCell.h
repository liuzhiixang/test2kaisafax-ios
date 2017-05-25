//
//  KSContactTFCell.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScontactTFCell    @"KSContactTFCell"
@protocol KSContactTFCellDelegate <NSObject>
@optional
-(void)contactTransformValueWithIndex:(NSInteger)index str:(NSString*)str;
@end

@interface KSContactTFCell : UITableViewCell
-(void)updateItem:(NSInteger)index str:(NSString*)str;
@property (weak, nonatomic) id<KSContactTFCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraintW;

@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@end
