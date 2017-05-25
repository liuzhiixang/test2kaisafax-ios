//
//  KSInvestHistoryVC.h
//  kaisafax
//
//  Created by Jjyo on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBaseVC.h"

/**
 *  @author semny
 *
 *  标的投资记录
 */
@interface KSInvestHistoryVC : KSNVBaseVC

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) long long loanId;

@end
