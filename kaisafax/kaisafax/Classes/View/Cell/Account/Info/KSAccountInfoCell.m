//
//  KSAccountInfoCell.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInfoCell.h"
#import "KSPersonInfoEntity.h"
#import "KSContactEntity.h"
#import "KSUserMgr.h"
#import "KSUserInfoEntity.h"

@interface KSAccountInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *exView;

@end

@implementation KSAccountInfoCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.exView.layer.borderWidth = 1.0;
    self.exView.layer.borderColor = NUI_HELPER.appOrangeColor.CGColor;
    
    //进入页面先加载用户信息里面的数据，然后再拉接口数据
    KSUserInfoEntity *userInfo = USER_MGR.user;
    _nameLabel.text = [userInfo.user showName];
    _dateLabel.text = [KSBaseEntity formatDate:userInfo.user.registerTime];

    
//    self.exView.layer.cornerRadius = 1.0;
}

-(void)updateItem:(id)item
{
    if (!item) return;
    KSPersonInfoEntity *entity = (KSPersonInfoEntity *)item;
    _nameLabel.text = entity.userName;

    _dateLabel.text = [KSBaseEntity formatDate:entity.registerTime];
//    _photoImageView.image = [UIImage imageNamed:@"ic_defaultphoto_big"];
    CGFloat percent = (CGFloat)entity.percent/100.0;
    [_progressView setProgress:percent];
}

@end
