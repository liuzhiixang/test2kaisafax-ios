//
//  KSUpdateView.m
//  kaisafax
//
//  Created by semny on 16/8/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUpdateView.h"
#import <Masonry/Masonry.h>

@interface KSUpdateView()

//@property (nonatomic, assign) CGFloat superHeight;
@property (nonatomic, assign) CGFloat oldTitleHeight;
//@property (nonatomic, assign) CGFloat oldDescHeight;
@property (nonatomic, assign) BOOL titleHidden;
@property (nonatomic, assign) BOOL descHidden;

@end

@implementation KSUpdateView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //ios10以后的编译环境需要根据这句话才能得到准确的size，不然全是1000*1000，作死啊
    [self.titleLabel layoutIfNeeded];
    [self.descriptionView layoutIfNeeded];
    
    //内部间距
    [self.closeBtn setContentEdgeInsets:UIEdgeInsetsMake(6.0f, 6.0f,6.0f, 6.0f)];
    //关闭事件
    [self.closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //other事件
    [self.otherBtn addTarget:self action:@selector(otherAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //原始数据
//    _superHeight = self.frame.size.height;
    _oldTitleHeight = self.titleLabel.frame.size.height;
//    _oldDescHeight = self.descriptionView.frame.size.height;
    
    //监听titleLabel text变化
    @WeakObj(self);
    [[self.titleLabel rac_valuesAndChangesForKeyPath:@"text" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTuple *tuple) {
        
        NSLog(@"titleLabel text: %@",tuple.first);
        NSLog(@"titleLabel second: %@",weakself.titleLabel.text);
        NSString *title = tuple.first;
        //标题
        CGFloat subX = weakself.titleLabel.frame.origin.x;
        CGFloat subY = weakself.titleLabel.frame.origin.y;
        CGFloat subW = weakself.titleLabel.frame.size.width;
        CGFloat subH = weakself.titleLabel.frame.size.height;
        //描述
        CGFloat sub1X = weakself.descriptionView.frame.origin.x;
        CGFloat sub1W = weakself.descriptionView.frame.size.width;
        CGFloat sub1H = weakself.descriptionView.frame.size.height;
        //更新自定义视图的高度
        CGFloat x = weakself.frame.origin.x;
        CGFloat y = weakself.frame.origin.y;
        CGFloat w = weakself.frame.size.width;
        CGFloat superHeight = weakself.frame.size.height;
        //标题是否为空
        if(!title || title.length <= 0)
        {
            if (!weakself.titleHidden)
            {
                CGFloat newHeight = 0.1f;
                //设置不显示
                weakself.titleLabel.frame = CGRectMake(subX, subY, subW, newHeight);
                
                //title高度约束
//                weakself.titleHLayoutConstraint.constant = newHeight;
                [weakself.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(newHeight));
                }];
                
                //description顶部约束
                CGFloat top = weakself.titleTopLayoutConstraint.constant;
//                weakself.descriptionTopLayoutConstraint.constant = top;
                weakself.descriptionView.frame = CGRectMake(sub1X, subY, sub1W, sub1H+top);
                [weakself.descriptionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(top));
                }];
                
                //隐藏title
                weakself.titleLabel.hidden = YES;
                superHeight -= subH;
                if (superHeight > weakself.maxHeight)
                {
                    superHeight = weakself.maxHeight;
                }
                weakself.frame = CGRectMake(x, y, w, superHeight);
                weakself.titleHidden = YES;
            }
        }
        else
        {
            //原来是隐藏的时候需要重置
            if (weakself.titleHidden)
            {
                CGFloat newHeight = weakself.oldTitleHeight;
                //设置显示
                weakself.titleLabel.frame = CGRectMake(subX, subY, subW, newHeight);
                //title高度约束
                weakself.titleHLayoutConstraint.constant = newHeight;
                
                //description顶部约束
                CGFloat top = weakself.titleTopLayoutConstraint.constant;
//                weakself.descriptionTopLayoutConstraint.constant = newHeight+top;
                weakself.descriptionView.frame = CGRectMake(sub1X, subY, sub1W, sub1H-top);
                [weakself.descriptionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(newHeight+top));
                }];
                //显示
                weakself.titleLabel.hidden = NO;
                weakself.titleHidden = NO;
                superHeight += newHeight;
                if (superHeight > weakself.maxHeight)
                {
                    superHeight = weakself.maxHeight;
                }
                weakself.frame = CGRectMake(x, y, w, superHeight);
            }
        }
    }];
    
    //
    
    NSString *keypath = @"attributedText";
//    if (!IOS9_AND_LATER)
//    {
//        keypath = @"text";
//        //[self.descriptionView addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:nil];
//    }
    
    //监听description视图的文字信息的变化
    [[self.descriptionView rac_valuesAndChangesForKeyPath:keypath options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTuple *tuple) {
        
        NSLog(@"descriptionView text1: %@",tuple.first);
        NSLog(@"descriptionView text2: %@",tuple.second);
        NSLog(@"descriptionView text3: %@",tuple.third);
        NSLog(@"descriptionView text4: %@",tuple.fourth);
        NSLog(@"descriptionView text5: %@",tuple.last);
        NSLog(@"titleLabel text: %@",weakself.titleLabel.text);
        id description = tuple.first;
        NSString *tempStr = nil;
        if (!description)
        {
            tempStr = weakself.descriptionView.text;
        }
        else
        {
            if ([description isKindOfClass:[NSString class]])
            {
                tempStr = (NSString*)description;
            }
            else if ([description isKindOfClass:[NSAttributedString class]])
            {
                tempStr = ((NSAttributedString*)description).string;
            }
        }
        [weakself.descriptionView layoutIfNeeded];
        //标题
        CGFloat subX = weakself.descriptionView.frame.origin.x;
        CGFloat subY = weakself.descriptionView.frame.origin.y;
        CGFloat subW = weakself.descriptionView.frame.size.width;
        CGFloat subH = weakself.descriptionView.frame.size.height;
        
        //更新自定义视图的高度
        CGFloat x = weakself.frame.origin.x;
        CGFloat y = weakself.frame.origin.y;
        CGFloat w = weakself.frame.size.width;
        CGFloat superHeight = weakself.frame.size.height;
        
        //描述信息文字高度
        CGFloat descriptionH = 0.0f;
        //描述信息是否为空
        if(!tempStr || tempStr.length <= 0)
        {
            NSLog(@"descriptionView description11: %@",description);
            //设置不显示
            CGFloat tempH = 0.0f;
            weakself.descriptionView.frame = CGRectMake(subX, subY, subW, tempH);
            weakself.descriptionView.hidden = YES;
            weakself.descHidden = YES;
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
            NSLog(@"descriptionView description22: %@",description);
            CGSize descSize = [weakself calculateDescriptionSizeWithString:description font:weakself.descriptionView.font width:subW minLine:3];
            descriptionH = descSize.height;
            //设置高度（只需要设置父控件高度即可）
            weakself.descriptionView.frame = CGRectMake(subX, subY, subW, descriptionH);
            weakself.descriptionView.hidden = NO;
            weakself.descHidden = NO;
            
            //父视图
            superHeight += (descriptionH - subH);
            if (superHeight > weakself.maxHeight)
            {
                superHeight = weakself.maxHeight;
            }
            weakself.frame = CGRectMake(x, y, w, superHeight);
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"%s %@ %@ %@", __FUNCTION__,self.titleLabel, self.descriptionView, self.closeBtn);
    
    //圆角
    CGFloat closeWidth = self.closeBtn.frame.size.width;
    self.closeBtn.layer.cornerRadius = closeWidth/2;
}

- (IBAction)closeAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateViewOther:)])
    {
        [self.delegate updateViewCancel:self];
    }
}

- (IBAction)otherAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateViewCancel:)])
    {
        [self.delegate updateViewOther:self];
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    DEBUGG(@"%s %@ %@", __FUNCTION__, ((UITextView*)object).attributedText, change);
//}

#pragma mark - 计算尺寸
//- (CGSize)calculateDescriptionSizeWithString:(NSAttributedString *)string width:(CGFloat)width minLine:(NSInteger)minLine
//{
//    NSLog(@"%s description: %@",__FUNCTION__,string);
//    CGSize size = CGSizeZero;
//    NSMutableAttributedString *atrString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
//    NSRange range = NSMakeRange(0, atrString.length);
//    
//    //获取指定位置上的属性信息，并返回与指定位置属性相同并且连续的字符串的范围信息。
//    NSDictionary* dic = [atrString attributesAtIndex:0 effectiveRange:&range];
//    
//    //设置默认字体属性
//    UIFont *font = dic[NSFontAttributeName];
//    if (!font || nil == font)
//    {
//        font = [UIFont systemFontOfSize:14.0f];
//        [atrString addAttribute:NSFontAttributeName value:font range:range];
//    }
//    
//    CGFloat minHeight = 0.0f;
//    if (minLine <= 0)
//    {
//        minLine = 3;
//    }
//    minHeight = minLine*font.pointSize;
//    
//    NSMutableDictionary *attDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//    [attDic setObject:font forKey:NSFontAttributeName];
//    //[attDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
//    
//    size = [string.string boundingRectWithSize:CGSizeMake(width, 1000)
//                                       options:NSStringDrawingUsesLineFragmentOrigin
//                                    attributes:dic
//                                       context:nil].size;
//    if (minHeight > size.height)
//    {
//        size.height = minHeight;
//    }
//    size.height += 5.0f;
//    
//    return size;
//}

- (CGSize)calculateDescriptionSizeWithString:(id)string font:(UIFont *)font width:(CGFloat)width minLine:(NSInteger)minLine
{
    NSLog(@"%s description: %@",__FUNCTION__,string);
    CGSize size = CGSizeZero;
    if ([string isKindOfClass:[NSString class]])
    {
        if (!font)
        {
            font = [UIFont systemFontOfSize:14.0f];
        }
        NSDictionary *dic = @{NSFontAttributeName: font};
        size = [string boundingRectWithSize:CGSizeMake(width, 1000)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:dic
                                           context:nil].size;
    }
    else if ([string isKindOfClass:[NSAttributedString class]])
    {
        NSMutableAttributedString *atrString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
        NSRange range = NSMakeRange(0, atrString.length);
        
        //获取指定位置上的属性信息，并返回与指定位置属性相同并且连续的字符串的范围信息。
        NSDictionary* dic = [atrString attributesAtIndex:0 effectiveRange:&range];
        
        //设置默认字体属性
        UIFont *font = dic[NSFontAttributeName];
        if (!font || nil == font)
        {
            font = [UIFont systemFontOfSize:14.0f];
            [atrString addAttribute:NSFontAttributeName value:font range:range];
        }
        
        NSMutableDictionary *attDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [attDic setObject:font forKey:NSFontAttributeName];
        //[attDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        
        size = [atrString.string boundingRectWithSize:CGSizeMake(width, 1000)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:dic
                                           context:nil].size;
    }
    
    CGFloat minHeight = 0.0f;
    if (minLine <= 0)
    {
        minLine = 3;
    }
    minHeight = minLine*font.pointSize;
    
    if (minHeight > size.height)
    {
        size.height = minHeight;
    }
    size.height += 5.0f;
    
    return size;
}


@end
