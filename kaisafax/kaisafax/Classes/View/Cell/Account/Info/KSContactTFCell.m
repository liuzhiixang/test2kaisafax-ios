//
//  KSContactTFCell.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSContactTFCell.h"

#define kItemArrays   @[@"姓名",@"手机",@"关系"]
@interface KSContactTFCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (assign, nonatomic) NSInteger index;
@end

@implementation KSContactTFCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self= [super initWithCoder:aDecoder];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

-(void)updateItem:(NSInteger)index str:(NSString*)str
{

    _nameLabel.text = str;
    _index = index;
    
    //增加校验事件
//    @WeakObj(self);
    //用户名或手机号
//    RAC(self.contentTF, text) = [self.contentTF.rac_textSignal map:^id(NSString *value) {
//        NSString *newValue = value;
//        if (_delegate && [_delegate respondsToSelector:@selector(contactTransformValueWithIndex:str:)]) {
//            [_delegate contactTransformValueWithIndex:(weakself.index) str:value];
//            
//        }
//        return newValue;
//    }];
    
}
@end
