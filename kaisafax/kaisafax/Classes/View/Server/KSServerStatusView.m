//
//  KSServerStatusView.m
//  kaisafax
//
//  Created by semny on 16/8/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSServerStatusView.h"
#import "UIView+YYAdd.h"

@implementation KSServerStatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)awakeFromNib
{
    [super awakeFromNib];
    //关闭事件
    [self.actionBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    
    //ios10以后的编译环境需要根据这句话才能得到准确的size，不然全是1000*1000，作死啊
    [self.commentLabel3 layoutIfNeeded];
    
    //初始化YYLabel
    self.commentLabel3.textAlignment = NSTextAlignmentCenter;
    self.commentLabel3.numberOfLines = 0;
    self.commentLabel3.lineBreakMode = NSLineBreakByWordWrapping;
    self.commentLabel3.backgroundColor = self.backgroundColor;
    
    //根据设置的text改变具体改变高度
    //监听description视图的文字信息的变化
    @WeakObj(self);
    [[self.commentLabel3 rac_valuesAndChangesForKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTuple *tuple) {
        
        NSLog(@"descriptionView text: %@",tuple.first);
        NSLog(@"descriptionView second: %@",weakself.commentLabel3.text);
        NSAttributedString *description = tuple.first;
        
        //标题
        CGFloat subX = weakself.commentLabel3.frame.origin.x;
        CGFloat subY = weakself.commentLabel3.frame.origin.y;
        CGFloat subW = weakself.commentLabel3.frame.size.width;
        CGFloat subH = weakself.commentLabel3.frame.size.height;
        
        //更新自定义视图的高度
        CGFloat x = weakself.frame.origin.x;
        CGFloat y = weakself.frame.origin.y;
        CGFloat w = weakself.frame.size.width;
        CGFloat superHeight = self.frame.size.height;
        
        //描述信息文字高度
        CGFloat descriptionH = 0.0f;
        //描述信息是否为空
        if(!description || description.length <= 0)
        {
            //设置不显示
            CGFloat tempH = 0.0f;
            
            weakself.commentLabel3.frame = CGRectMake(subX, subY, subW, tempH);
            weakself.commentLabel3.height = tempH;
            weakself.commentLabel3.hidden = YES;
            //父视图
            superHeight += (descriptionH - subH);
            if (superHeight > weakself.maxHeight)
            {
                superHeight = weakself.maxHeight;
            }
            weakself.frame = CGRectMake(x, y, w, superHeight);
        }
        else
        {
            //计算实际高度
            CGSize size = CGSizeMake(subW, CGFLOAT_MAX);
            YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:size text:description];
            
//            CGSize descSize = [weakself calculateDescriptionSizeWithString:description font:weakself.descriptionView.font width:subW minLine:3];
            descriptionH = textLayout.textBoundingSize.height;
            //设置高度（只需要设置父控件高度即可）
            weakself.commentLabel3.frame = CGRectMake(subX, subY, subW, descriptionH);
            weakself.commentLabel3.height = descriptionH;
            weakself.commentLabel3.hidden = NO;
            //weakself.descHidden = NO;
            
            //父视图
            superHeight += (descriptionH - subH);
            if (superHeight > weakself.maxHeight)
            {
                superHeight = weakself.maxHeight;
            }
            weakself.frame = CGRectMake(x, y, w, superHeight);
        }
    }];
    
//     NSAttributedString *text = @"";
//     CGSize size = CGSizeMake(100, CGFLOAT_MAX);
//     YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:text];
//     
//     // 获取文本显示位置和大小
//     layout.textBoundingRect; // get bounding rect
//     layout.textBoundingSize; // get bounding size
//     
//     // 查询文本排版结果
//     [layout lineIndexForPoint:CGPointMake(10,10)];
//     [layout closestLineIndexForPoint:CGPointMake(10,10)];
//     [layout closestPositionToPoint:CGPointMake(10,10)];
//     [layout textRangeAtPoint:CGPointMake(10,10)];
//     [layout rectForRange:[YYTextRange rangeWithRange:NSMakeRange(10,2)]];
//     [layout selectionRectsForRange:[YYTextRange rangeWithRange:NSMakeRange(10,2)]];
//     
//     // 显示文本排版结果
//     YYLabel *label = [YYLabel new];
//     label.frame.size = layout.textBoundingSize;
//     label.textLayout = layout;
    
    
}

- (void)action:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(serverViewCancel:)])
    {
        [self.delegate serverViewCancel:self];
    }
}
@end
