//
//  KSAccountInfoVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountInfoVC.h"
#import "KSAccountInfoCell.h"
#import "KSOpenAccountVC.h"
#import "KSBindPhoneVC.h"
#import "KSMailVC.h"
#import "KSPersonInfoBL.h"
#import "KSPersonInfoEntity.h"
#import "KSContactEntity.h"
#import "KSContactVC.h"
#import "KSAddrVC.h"
#import "KSUserMgr.h"
#import "KSUserBaseEntity.h"
#import "KSUserInfoEntity.h"
#import "KSVerifiedPhoneVC.h"
#import "KSFileUtil.h"
#import "KSCommonResultVC.h"
#import "KSOpenAccountBL.h"




#define kSecNum   3
#define kCellHeight   49.0
#define kDetailArray  @[@"实名认证",@"手机认证",@"电子邮箱",@"紧急联系人",@"收货地址"]
#define kVerifyArray  @[@"业主认证",@"员工认证"]

typedef NS_ENUM(NSInteger,KSPersonalInfo)
{
    KSPersonalInfoBrief = 0,        //简要的，名字，等级等
    KSPersonalInfoDetail,           //详细的，地址，电话号码等
    KSPersonalInfoVerify,           //认证
    KSPersonalInfoMax,              //最大枚举值
};

typedef NS_ENUM(NSInteger,KSDetailInfo)
{
    KSDetailInfoNameVer = 0,            //实名认证
    KSDetailInfoPhoneVer,               //手机认证
    KSDetailInfoMailVer,                //邮箱
    KSDetailInfoEmeContactVer,          //紧急联系人
    KSDetailInfoAddrVer,                //地址
    KSDetailInfoMax,               //最大枚举值;
};

typedef NS_ENUM(NSInteger,KSVerifyType)
{
    KSVerifyOwner = 0,            //实名认证
    KSVerifyStaff,               //手机认证

    KSVerifyMax,               //最大枚举值;
};

@interface KSAccountInfoVC ()<UITableViewDataSource,UITableViewDelegate,KSBLDelegate>
@property (weak, nonatomic) IBOutlet UITableView *infoTabView;

@property (strong, nonatomic) KSPersonInfoBL *perBL;
@property (strong, nonatomic) KSPersonInfoEntity *infoEntity;
@end

@implementation KSAccountInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = KPersonalInfoTitle;
    
    NSDictionary *json = [KSFileUtil openFile:[self getCacheFileName]];
    if (json)
    {
        self.infoEntity = [KSPersonInfoEntity yy_modelWithJSON:json];
    }
    
    [self setupTableView];

    [self requestData];
    
    //接收启动页面完成的通知
    @WeakObj(self);
    [[NOTIFY_CENTER rac_addObserverForName:KAccountInfoChangeNotificationKey object:nil] subscribeNext:^(id x){
        [weakself requestData];
    }];
}

- (NSString *)getCacheFileName
{
    return [NSString stringWithFormat:@"%lld.account_info.cache", USER_MGR.user.user.userId];
}

#pragma mark - 设置tableview属性
-(void)setupTableView
{
    //注册头部的cell
    [_infoTabView registerNib:[UINib nibWithNibName:kSAccountInfoCell bundle:nil]  forCellReuseIdentifier:kSAccountInfoCell];
    
    _infoTabView.backgroundColor = UIColorFrom255RGBA(235, 235, 235, 1.0);
    _infoTabView.dataSource = self;
    _infoTabView.delegate = self;
    
    _infoTabView.separatorColor = NUI_HELPER.appBorderColor;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(MAIN_BOUNDS), CGRectGetWidth(MAIN_BOUNDS), CGRectGetHeight(MAIN_BOUNDS))];
    view.backgroundColor = UIColorFromHex(0x3e3e40);
    [_infoTabView insertSubview:view atIndex:0];
}

-(void)requestData
{
    if (!_perBL)
    {
        _perBL = [[KSPersonInfoBL alloc]init];
    }
    _perBL.delegate = self;
    
    [_perBL doGetPersonalInfo];
}

#pragma mark - tableview datasource and delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return KSPersonalInfoMax;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = KSPersonalInfoBrief;
    if (section == KSPersonalInfoBrief)
    {
        num = 1;
    }
    else if (section == KSPersonalInfoDetail)
    {
        num = KSDetailInfoMax;
    }
    else if (section == KSPersonalInfoVerify)
    {
        BOOL isStaff = (self.infoEntity.userType == 4);
        if(isStaff)
            num = 2;
        else
            num = 1;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    if (sec == KSPersonalInfoBrief)
    {
        KSAccountInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kSAccountInfoCell];
        cell.backgroundColor = NUI_HELPER.appNavigationBarTintColor;
        [cell updateItem:self.infoEntity];
        return cell;
    }
    else if (sec == KSPersonalInfoDetail)
    {
        static NSString *identifier = @"infodetail";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = kDetailArray[row];
//        cell.textLabel.textColor = NUI_HELPER.appDarkGrayColor;
//        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.nuiClass = NUIAppNormalDarkGrayLabel;

        cell.detailTextLabel.textColor = NUI_HELPER.appLightGrayColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        DEBUGG(@"222 row: %ld , infoEntity: %@",(long)row,self.infoEntity);
        if (row == KSDetailInfoNameVer)
        {

            NSString *nameStr = [NSString stringWithFormat:@"%@ %@",self.infoEntity.userName,self.infoEntity.idNumberConvert];
            cell.detailTextLabel.text = (self.infoEntity.idNumberConvert!=nil)?nameStr:KNotCertifiedTitle;
            if (self.infoEntity.idNumberConvert) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.userInteractionEnabled = NO;
            }

        }
        else if (row == KSDetailInfoPhoneVer)
        {
            if(self.infoEntity.mobileConvert)
                cell.detailTextLabel.text = self.infoEntity.mobileConvert;
            else
                cell.detailTextLabel.text = KNotCertifiedTitle;

            
        }
        else if (row == KSDetailInfoMailVer)
        {
            cell.detailTextLabel.text = (self.infoEntity.email!=nil)?self.infoEntity.email:KUnboundTitle;

        }
        else if (row == KSDetailInfoEmeContactVer)
        {
            cell.detailTextLabel.text =(self.infoEntity.contactData!=nil)? self.infoEntity.contactData.name:KUnboundTitle;

        }
        else if (row == KSDetailInfoAddrVer)
        {
//            if(self.infoEntity.ownerAddress)
//                cell.detailTextLabel.text = self.infoEntity.ownerAddress;
//            else
                cell.detailTextLabel.text = @"";

        }
        
        return cell;

        
    }
    else if (sec == KSPersonalInfoVerify)
    {
        DEBUGG(@"333 row: %ld , infoEntity: %@",(long)row,self.infoEntity);
        static NSString *identifier = @"infodetailver";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = kVerifyArray[row];
//        cell.textLabel.textColor = NUI_HELPER.appDarkGrayColor;
//        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.nuiClass = NUIAppNormalDarkGrayLabel;
        
        cell.detailTextLabel.textColor = NUI_HELPER.appLightGrayColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        if (row == KSVerifyOwner)
        {
//            NSString *ownerAddr = self.infoEntity.ownerAddress;
            //1 普通用户 2 业主用户 3 员工用户 4 员工&业主用户
            NSInteger userType = self.infoEntity.userType;
            BOOL isOwner = NO;
            if (userType == 2 ||
                userType == 4 )
            {
                isOwner = YES;
            }
            cell.detailTextLabel.text = (isOwner == YES)?KCertifiedTitle:KNotCertifiedTitle;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
        else
        {
            cell.detailTextLabel.text = KCertifiedTitle;
            cell.detailTextLabel.textColor = NUI_HELPER.appOrangeColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
        }
       
        return cell;
    }

    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
//    if (section>0) {
//        return nil;
//    }

    UIView *footerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 15.0)];
    footerview.backgroundColor =  UIColorFrom255RGBA(235, 235, 235, 1.0); /*UIColorFromHex(0x3e3e40)*/;
    return footerview;

}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec = indexPath.section;
    CGFloat height = 0.0;
    if (sec == KSPersonalInfoBrief)
    {
        height = 118.0;
    }
    else if (sec == KSPersonalInfoDetail)
    {
        height = kCellHeight;
    }
    else if (sec == KSPersonalInfoVerify)
    {
        height = kCellHeight;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (sec)
    {
        case KSPersonalInfoDetail:
            if (row == KSDetailInfoNameVer)
            {
                if (!self.infoEntity.idNumberConvert)
                {
                    [self turn2OpenAccountPage];
                }
            }
            else if (row == KSDetailInfoPhoneVer)
            {
                [self turn2BindPhonePage];

            }
            else if (row == KSDetailInfoMailVer)
            {
                [self turn2BindMailPage];
            }
            else if (row == KSDetailInfoEmeContactVer)
            {
                [self turn2EmeContactVerPage];
            }
            else if (row == KSDetailInfoAddrVer)
            {
                [self turn2DetailInfoAddrVerPage];
            }
            break;
        case KSPersonalInfoVerify:
            if(row == KSVerifyOwner)
            {
                [self turn2OwnerVerPage];
            }
            else if (row == KSVerifyStaff)
            {
                
            }
            break;
        default:
            break;
    }

}
#pragma mark - 去开户，实名认证
- (void)turn2OpenAccountPage
{
//    NSString *imeiStr = USER_SESSIONID;
//    NSString *urlStr = [NSString stringWithFormat:@"%@?imei=%@&app=1", KOpenAccountPage, imeiStr];
//    //NSString *urlStr = [NSString stringWithFormat:@"%@", KOpenAccountPage];
//    
//    //开托管账户
//    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:KSWebSourceTypeAccount];
//    openAccountVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:openAccountVC animated:YES];
    
    [KSOpenAccountBL pushOpenAccountPageWith:self.navigationController hidesBottomBarWhenPushed:YES type:KSWebSourceTypeAccount];
}

- (void)turn2BindPhonePage
{
    if(self.infoEntity.mobileConvert)
    {
        KSVerifiedPhoneVC *verVc = [[KSVerifiedPhoneVC alloc]init];
        verVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:verVc animated:YES];
    }
    else
    {
        KSBindPhoneVC *bindvc = [[KSBindPhoneVC alloc]init];
        bindvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:bindvc animated:YES];
    }
}


- (void)turn2BindMailPage
{
    KSMailVC *mailvc = [[KSMailVC alloc]init];
    mailvc.hidesBottomBarWhenPushed = YES;
    mailvc.mailStr = self.infoEntity.email;
    [self.navigationController pushViewController:mailvc animated:YES];
}

- (void)turn2EmeContactVerPage
{
    KSContactVC *convc = [[KSContactVC alloc]init];
    convc.hidesBottomBarWhenPushed = YES;
    convc.contactData = self.infoEntity.contactData;
    [self.navigationController pushViewController:convc animated:YES];
}

- (void)turn2DetailInfoAddrVerPage
{
    KSAddrVC *addrvc = [[KSAddrVC alloc]init];
    addrvc.hidesBottomBarWhenPushed = YES;
    addrvc.addrData = self.infoEntity.addrData;
    [self.navigationController pushViewController:addrvc animated:YES];
}

-(void)turn2OwnerVerPage
{
    NSInteger userType = self.infoEntity.userType;

        
    if (userType == 2 ||
        userType == 4 )
        {
            // 已认证
//            [self showOperationHUDWithStr:@"已完成业主认证"];
            KSCommonResultVC *reselutVc =   [[KSCommonResultVC alloc]init];
            reselutVc.hidesBottomBarWhenPushed = YES;
            if (self.infoEntity.ownerAddress) {
                reselutVc.ownerInfo = self.infoEntity.ownerAddress;
            }
            
            [self.navigationController pushViewController:reselutVc animated:YES];
        }
        else
        {
            //业主认证
            [self gotoCertifyOwnerUserPage];
        }
    
}

//业主认证
-(void)gotoCertifyOwnerUserPage
{
    if (![USER_MGR isLogin])
    {
        return;
    }
    
    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KCertifyOwnerUserTradeId data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:@"业主认证" type:KSWebSourceTypeHome];
}

#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    DEBUGG(@"%s %@",__FUNCTION__,result.body);
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        //        [weakself hideProgressHUD];
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
    });
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    DEBUGG(@"%s %@",__FUNCTION__,result.body);
    
//    if (!result) return;
//    if (!result.body) return;

    if ([result.tradeId isEqualToString:KPersonalInfoTradeId])
    {
        self.infoEntity = result.body;
        NSDictionary *json = [self.infoEntity yy_modelToJSONObject];
        [KSFileUtil saveFile:[self getCacheFileName] data:json];
        [self.infoTabView reloadData];
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    DEBUGG(@"%s %@",__FUNCTION__,result.body);
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}
@end
