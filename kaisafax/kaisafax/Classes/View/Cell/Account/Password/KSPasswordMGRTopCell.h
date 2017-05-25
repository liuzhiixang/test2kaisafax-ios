//
//  KSPasswordMGRTopCell.h
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KPasswordMGRTopCellReusableId   @"PasswordMGRTopCellReusableId"
@interface KSPasswordMGRTopCell : UITableViewCell
//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *userIconView;
//用户名或者手机号
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//第三方交易平台账号
@property (weak, nonatomic) IBOutlet UILabel *thirdPartTransAccountLabel;

@end
