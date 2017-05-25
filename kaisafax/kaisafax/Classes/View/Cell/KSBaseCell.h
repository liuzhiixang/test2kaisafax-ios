//
//  KSBaseCell.h
//  kaisafax
//
//  Created by Jjyo on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSCellRoundCornerType) {
    KSCellRoundCornerTypeTop,
    KSCellRoundCornerTypeCenter,
    KSCellRoundCornerTypeBottom,
    KSCellRoundCornerTypeAll,
};

@interface KSBaseCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, assign) UIEdgeInsets margins;//cell到tableview的边距

/**
 *  自动将cell的backgroundView圆角
 *
 *  @param tableView cell的父类
 *  @param radius    圆角半径
 *  @param indexPath cell的位置
 */
- (void)tableView:(UITableView *)tableView autoCornerRaduis:(CGFloat)radius atIndexPath:(NSIndexPath *)indexPath;

/**
 *  自动设置cell backgroundView的圆角属性
 *
 *  @param tableView cell的父类
 *  @param radius    圆角半径
 *  @param indexPath cell的位置
 *  @param margins   backgroundView到tableview的边距
 */
- (void)tableView:(UITableView *)tableView autoCornerRaduis:(CGFloat)radius atIndexPath:(NSIndexPath *)indexPath inLayoutMargins:(UIEdgeInsets)margins;

/**
 *  手动设置cell backgroundView 的圆角属性
 *
 *  @param tableView tableView cell的父类
 *  @param radius    圆角半径
 *  @param type      圆角类型
 */
- (void)tableView:(UITableView *)tableView setCornerRaduis:(CGFloat)radius byRoundType:(KSCellRoundCornerType)type;


/**
 *  手动设置cell backgroundView 的圆角属性
 *
 *  @param tableView tableView cell的父类
 *  @param radius    圆角半径
 *  @param type      圆角类型
 *  @param margins   backgroundView到tableview的边距
 */
- (void)tableView:(UITableView *)tableView setCornerRaduis:(CGFloat)radius byRoundType:(KSCellRoundCornerType)type inLayoutMargins:(UIEdgeInsets)margins;
@end
