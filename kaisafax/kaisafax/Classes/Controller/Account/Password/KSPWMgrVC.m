//
//  KSPWMgrVCViewController.m
//  kaisafax
//
//  Created by semny on 16/11/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPWMgrVC.h"
#import "KSPasswordMGRTopCell.h"
#import "KSUserMgr.h"
#import "KSModifyLoginPWVC.h"
#import "KSWebVC.h"
#import "KSOpenAccountBL.h"

#define KNormalCellReusableId @"NormalCellReusableId"

@interface KSPWMgrVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation KSPWMgrVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //标题
    self.title = KPasswordManngerTitle;
    //背景颜色
    self.tableView.backgroundColor = NUI_HELPER.appBackgroundColor;
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"KSPasswordMGRTopCell" bundle:nil] forCellReuseIdentifier:KPasswordMGRTopCellReusableId];
    //间隔线颜色
    self.tableView.separatorColor = NUI_HELPER.appBackgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section)
    {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = 1;
            break;
        case 2:
            rows = 2;
            break;
        default:
            rows = 0;
            break;
    }
    return rows;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell *tempCell = nil;
    switch (section)
    {
        case 0:
        {
            KSPasswordMGRTopCell *cell = [tableView dequeueReusableCellWithIdentifier:KPasswordMGRTopCellReusableId];
            //    用户名
            KSUserInfoEntity *userInfo = USER_MGR.user;
//            NSString *userName = userInfo.name;
//            if (!userName || userName.length <= 0)
//            {
//                userName = userInfo.loginName;
//            }
//            if (!userName || userName.length <= 0)
//            {
//                userName = userInfo.mobile;
//            }
            NSString *userName = [userInfo.user showName];
            cell.userNameLabel.text = userName;
            
            
            //账号
            NSString *tpAccountStr = nil;
            if (USER_MGR.assets && (tpAccountStr=userInfo.chinaPnrAccount.pnrUsrId).length>0)
            {
                cell.thirdPartTransAccountLabel.hidden = NO;
                cell.thirdPartTransAccountLabel.text = tpAccountStr;
            }
            else
            {
                cell.thirdPartTransAccountLabel.hidden = YES;
            }
            tempCell = cell;
        }
            break;
        case 1:
        {
            //cell对象
            UITableViewCell *cell = [self normalCellWith:tableView];
            cell.textLabel.text = KModifyLoginPasswordTitle;
            tempCell = cell;
        }
            break;
        case 2:
        {
            //cell对象
            UITableViewCell *cell = [self normalCellWith:tableView];
            if (row==0)
            {
                cell.textLabel.text = KModifyThirdPartLoginPasswordTitle;

            }
            else
            {
                cell.textLabel.text = KModifyThirdPartPayPasswordTitle;

            }
            tempCell = cell;
        }
            break;
        default:
            break;
    }
    tempCell.selectionStyle =  UITableViewCellSelectionStyleNone;
    return tempCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    CGFloat height = 0.0f;
    switch (section)
    {
        case 0:
            height = MAIN_BOUNDS_SCREEN_WIDTH*21/40;
            break;
        case 1:
            height = 49.0f;
            break;
        case 2:
            height = 49.0f;
            break;
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footView = [[UIView alloc]initWithFrame:CGRectZero];
    footView.backgroundColor = NUI_HELPER.appBackgroundColor;
    return footView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section)
    {
        case 0:
            if (row==0)
            {
                //无效
            }
            break;
        case 1:
            if (row==0)
            {
                //修改登录密码
                [self turn2ModifyLoginPWPage];
            }
            break;
        case 2:
            if (row==0)
            {
                //修改支付平台登录密码
                [self turn2PayLoginPWPage];
            }
            else if (row==1)
            {
                //修改支付平台交易密码
                [self turn2PayTransactionPWPage];
            }
            break;
        default:
            break;
    }
}

#pragma mark -----内部方法----------
- (UITableViewCell *)normalCellWith:(UITableView*)tableView
{
    if (!tableView)
    {
        return nil;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KNormalCellReusableId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KNormalCellReusableId];
    }
//    //字体
//    cell.textLabel.font = SYSFONT(15.0f);
//    //颜色
//    cell.textLabel.textColor = UIColorFromHex(0x4c4c4e);
    cell.textLabel.nuiClass = NUIAppNormalDarkGrayLabel;
    //显示尖括号
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)turn2ModifyLoginPWPage
{
    //修改登录密码
    KSModifyLoginPWVC *controller = [[KSModifyLoginPWVC alloc] initWithNibName:@"KSModifyLoginPWVC" bundle:nil];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)turn2PayLoginPWPage
{
    //修改支付平台登录密码
//    NSString *title = KModifyThirdPartLoginPasswordTitle;
//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@",KOpenAccountPage,USER_SESSIONID];
//    [KSWebVC pushInController:self.navigationController urlString:urlStr title:title type:KSWebSourceTypeAccount];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeAccount];
}

- (void)turn2PayTransactionPWPage
{
    //修改支付平台交易密码
//    NSString *title = KModifyThirdPartPayPasswordTitle;
//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@",KOpenAccountPage,USER_SESSIONID];
//    [KSWebVC pushInController:self.navigationController urlString:urlStr title:title type:KSWebSourceTypeAccount];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeAccount];
}
@end
