//
//  KSBaseCell.m
//  kaisafax
//
//  Created by Jjyo on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseCell.h"

#define kRoundRaidus 5.0f


@interface KSBaseCell()
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) KSCellRoundCornerType roundType;
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) CGFloat radius;//圆半径

@property (nonatomic, assign) BOOL enableRoundCorner;
@end


@implementation KSBaseCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _roundType = KSCellRoundCornerTypeCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_enableRoundCorner) {
        [self layoutRoundCorner];
    }
    
}


- (CGRect)getMarginBoundsInView:(UIView *)view
{
    CGRect bounds = view.bounds;
    bounds.origin.x = _margins.left;
    bounds.origin.y = _margins.top;
    bounds.size.width -= (_margins.left + _margins.right);
    bounds.size.height -= (_margins.top + _margins.bottom);
    return bounds;
}

- (void)layoutRoundCorner
{
    KSCellRoundCornerType type = self.roundType;
    if (_indexPath) {
        NSInteger rows = [_tableView numberOfRowsInSection:_indexPath.section];
        if (rows > 1) {
            if (_indexPath.row == 0) {
                type = KSCellRoundCornerTypeTop;
            }else if(_indexPath.row == rows - 1){
                type = KSCellRoundCornerTypeBottom;
            }else{
                type = KSCellRoundCornerTypeCenter;
            }
        }
    }
    
    CGRect bounds = [self getMarginBoundsInView:self];
    
    
    
    if (self.backgroundView) {
        CAShapeLayer *maskLayer = [self layerFormView:self.backgroundView];
        UIBezierPath *maskPath = [self bezierPathWithRoundedRect:bounds byCornerType:type cornerRadius:_radius];
        
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
    }
    if (self.selectedBackgroundView) {
        bounds.size.height += 1;//为什么要+1 ??? 这样背景色才能完全覆盖backgroundView呀, 不服来辨...
        CAShapeLayer *maskLayer = [self layerFormView:self.selectedBackgroundView];
        UIBezierPath *maskPath = [self bezierPathWithRoundedRect:bounds byCornerType:type cornerRadius:_radius];
        
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
    }
}


- (CAShapeLayer *)layerFormView:(UIView *)view
{
    CAShapeLayer *maskLayer = nil;
    if (!view.layer.mask) {
        maskLayer = [[CAShapeLayer alloc] init];
        view.layer.mask = maskLayer;
    }else{
        maskLayer = (CAShapeLayer *)view.layer.mask;
    }
    return maskLayer;
}



- (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)bounds byCornerType:(KSCellRoundCornerType)type cornerRadius:(CGFloat)radius
{
    UIBezierPath *maskPath;
    if (type == KSCellRoundCornerTypeAll) {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:UIRectCornerAllCorners
                                               cornerRadii:CGSizeMake(radius, radius)];
    }
    else if (type == KSCellRoundCornerTypeTop)
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                               cornerRadii:CGSizeMake(radius, radius)];
    }
    else if (type == KSCellRoundCornerTypeCenter)
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:UIRectCornerTopLeft
                                               cornerRadii:CGSizeZero];
    }
    else if (type == KSCellRoundCornerTypeBottom)
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                               cornerRadii:CGSizeMake(radius, radius)];
    }
    
    return maskPath;
}


- (void)tableView:(UITableView *)tableView autoCornerRaduis:(CGFloat)radius atIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView autoCornerRaduis:radius atIndexPath:indexPath inLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView autoCornerRaduis:(CGFloat)radius atIndexPath:(NSIndexPath *)indexPath inLayoutMargins:(UIEdgeInsets)margins
{
    _enableRoundCorner = YES;
    self.tableView = tableView;
    self.indexPath = indexPath;
    self.radius = radius;
    self.margins = margins;
}

- (void)tableView:(UITableView *)tableView setCornerRaduis:(CGFloat)radius byRoundType:(KSCellRoundCornerType)type
{
    [self tableView:tableView setCornerRaduis:radius byRoundType:type inLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView setCornerRaduis:(CGFloat)radius byRoundType:(KSCellRoundCornerType)type inLayoutMargins:(UIEdgeInsets)margins
{
    _enableRoundCorner = YES;
    self.tableView = tableView;
    self.radius = radius;
    self.margins = margins;
    self.indexPath = nil;
    self.roundType = type;
}


@end
