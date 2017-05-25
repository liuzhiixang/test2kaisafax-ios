//
//  KSContactPickCell.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSContactPickCell.h"
@interface KSContactPickCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)selBtnAction:(UIButton *)sender;

@end

@implementation KSContactPickCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateItem:(NSString*)str
{
    _nameLabel.text = str;
}

- (IBAction)selBtnAction:(UIButton *)sender
{
    //弹出选择器
    
//    UIPickerView *pickview = [UIPickerView alloc]initWithFrame:<#(CGRect)#>
    if (_delegate && [_delegate respondsToSelector:@selector(contactPick:)])
    {
        [_delegate contactPick:sender];
    }
}
@end
