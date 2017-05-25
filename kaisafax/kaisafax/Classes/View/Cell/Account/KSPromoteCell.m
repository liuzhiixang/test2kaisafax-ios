//
//  KSPromoteCell.m
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPromoteCell.h"
#import "NSDate+Utilities.h"

@interface KSPromoteCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end



@implementation KSPromoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateItem:(KSInviteUserEntity *)entity
{
    _nameLabel.text = entity.user.showName;
    //重构直接推荐接口，没有的数据
    _statusLabel.text = [entity getInvestStatus];
    _dateLabel.text = [entity.user.registerTime dateStringWithFormat:@"yyyy/MM/dd HH:mm"];
}

@end
