//
//  KSJingDongCardVC.h
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"
#import "KSJDCardCell.h"
#import "KSJDCardDetailVC.h"
#import "KSJDCardPayrollRecordVC.h"
#import "KSJDCardReceiveVC.h"


#import "KSJDExtractListBL.h"
#import "KSJDExtractListEntity.h"

#import "KSJDExtractListBL.h"
#import "KSBJDExtractListEntity.h"



@interface KSJDCardVC : KSNVBackVC
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//京东E卡请求BL
@property (weak, nonatomic) IBOutlet UIButton *takeActionBtn;

@property (weak, nonatomic) IBOutlet KSLabel *extractLab;

@end
