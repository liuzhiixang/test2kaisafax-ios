//
//  KSSingleRedPacketVC.m
//  sxfax
//
//  Created by philipyu on 16/2/24.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "KSSingleRedPacketVC.h"
#import "KSRedPacketInactiveCell.h"
#import "KSRedPacketActivedCell.h"
#import "KSRedPacketOverdueCell.h"
#import "KSRedPacketGotCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSWholeNewRedPacketVC.h"
#import "KSNValidRewardVC.h"
#import "KSRewardListBL.h"
#import "KSRewardsEntity.h"
#import "KSRewardItemEntity.h"
#import "KSUserMgr.h"
#import "KSConst.h"
#import "KSRedPacketGotValidCell.h"
#import "KSValidRedRewardEntity.h"
#import "KSWebVC.h"
#import "KSRewardBL.h"
#import "KSBRewardListEntity.h"

typedef NS_ENUM(NSInteger,KSRedPacketType)
{
    KSRedPacketInactive = 0,       //
    KSRedPacketActived,            //
    KSRedPacketOverdue,
    KSRedPacketMax,               //最大枚举值;
};

#define kRatio    (95/355.0)
#define kPadding  10
#define kCellMargin  (MAIN_BOUNDS_SCREEN_WIDTH*kRatio*(1-0.947)/2)
#define kFlagConst   0x11


@interface KSSingleRedPacketVC ()<KSBLDelegate,KSRedPacketGotValidCellDelegate>

@property (weak, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) KSBRewardListEntity *listData;
@property (weak, nonatomic) IBOutlet UILabel *noRedBagLabel;
@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (strong, nonatomic) KSRewardListBL *rewardListBL;
@property (nonatomic,strong) KSRewardBL *rewardBL;
@property (nonatomic,strong) KSValidRedRewardEntity *validReward;
@property (weak, nonatomic)  UILabel *noRedRepperLabel;

//判断是否激活红包页面两个数据都返回
@property (nonatomic,assign) NSInteger activeFlag;
@property (nonatomic,assign) CGSize contentSize;
@property (nonatomic,assign) BOOL isFirst;
@end

@implementation KSSingleRedPacketVC

//懒加载
-(NSMutableArray*)dataArray
{
    _dataArray = self.listData.dataList;
    return _dataArray;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //已激活红包的flag
    _activeFlag = 0x00;
    _isFirst = YES;

    //注册4种cell
    kRegisterCellNib(self.tabView, kSRedPacketActivedCell);
    kRegisterCellNib(self.tabView, kSRedPacketInactiveCell);
    kRegisterCellNib(self.tabView, kSRedPacketOverdueCell);
    
    [self tableRefreshGif];
    [self.tabView.mj_header beginRefreshing];
    [self addNoRedRepperTips];
    
    DEBUGG(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DEBUGG(@"%s, height11: %f", __FUNCTION__, self.tabView.frame.size.height);
    DEBUGG(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));

    if (_isFirst)
    {
        DEBUGG(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));
        self.tabView.contentInset = UIEdgeInsetsMake(0, 0, StatusBarHeight+NavigationBarHeight+KWMPageTitleHeight+kPadding/*+MJRefreshFooterHeight*/, 0);
        _isFirst = NO;
    }


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    DEBUGG(@"%s, height22: %f", __FUNCTION__, self.tabView.frame.size.height);
    DEBUGG(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));


}

#pragma mark - 添加没有红包提示label

-(void)addNoRedRepperTips
{
    UILabel *noRedRepperLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (MAIN_BOUNDS_SCREEN_HEIGHT-16-64-44)/2, MAIN_BOUNDS_SCREEN_WIDTH, 16.0)];
    noRedRepperLabel.text = @"暂无红包";
    noRedRepperLabel.backgroundColor = ClearColor;
    noRedRepperLabel.textAlignment = NSTextAlignmentCenter;
    noRedRepperLabel.textColor = NUI_HELPER.appLightGrayColor;
    noRedRepperLabel.font = [UIFont systemFontOfSize:16.0];
    noRedRepperLabel.hidden = YES;
    _noRedRepperLabel = noRedRepperLabel;
    [self.view addSubview:noRedRepperLabel];
}

#pragma mark - 上下拉刷新逻辑

-(void)refreshing
{
    if (!_rewardListBL)
    {
        _rewardListBL = [[KSRewardListBL alloc]init];
        _rewardListBL.delegate = self;
    }

    _rewardListBL.status = self.status;
    [_rewardListBL refreshRewardList];
    
}

-(void)endRefreshing
{
    [self.tabView.mj_header endRefreshing];
    [self.tabView.mj_footer endRefreshing];
}

- (void)tableRefreshGif
{
    // 添加动画图片的下拉刷新
    [self scrollView:_tabView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
}

-(void)loadingMore
{
    [_rewardListBL requestNextPageRewardList];
}

#pragma mark - 是否激活红包页
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *status = self.status;
    NSArray *tmpArray = kRedPacketTypeArray;
    NSInteger section = indexPath.section;
    KSRewardItemEntity  *entity;
    
    if (section>=0 && section<_dataArray.count)
    {
        entity =(KSRewardItemEntity *)[KSRewardItemEntity yy_modelWithJSON:_dataArray[section]];
    }
    

    if (status.intValue == [tmpArray[KSRedPacketInactive] intValue])
    {
        KSRedPacketInactiveCell *cell = [tableView dequeueReusableCellWithIdentifier:kSRedPacketInactiveCell];
        if (section>=0 && section<_dataArray.count)
        {
            
            [cell updateItem:entity];
        }
        return cell;
    }
    else if(status.intValue == [tmpArray[KSRedPacketActived] intValue])
    {
        KSRedPacketActivedCell *cell = [tableView dequeueReusableCellWithIdentifier:kSRedPacketActivedCell];
        if (section>=0 && section<_dataArray.count)
        {
            [cell updateItem:entity];
        }
        return cell;
    }
    else if(status.intValue == [tmpArray[KSRedPacketOverdue] intValue])
    {
        KSRedPacketOverdueCell *cell = [tableView dequeueReusableCellWithIdentifier:kSRedPacketOverdueCell];
        if (section>=0 && section<_dataArray.count)
        {
        
            [cell updateItem:entity];
        }
        return cell;
    }
    return nil;
    
}
//
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //由于等比例缩放了图片之后会出现空档，需要对第一个和第二个cell特殊情况处理
    CGFloat secGap = 0.0;
    if (section == 0)
    {
        secGap = 10.0-kCellMargin;
    }
    else
    {
        secGap = 10.0-kCellMargin*2;
    }
    return secGap;
}
//
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat secHeight = 0.01;
    return secHeight;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = MAIN_BOUNDS_SCREEN_WIDTH*95/355.0;
    return height;
}

#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    [self endRefreshing];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
    });
    INFO(@"%@ %@",blEntity,result);
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@ %@",blEntity,result.body);
    
    NSString *tradeId = result.tradeId;

    if (result.errorCode == 0)
    {
        if([tradeId isEqualToString:KGetRewardListTradeId])
        {
            _listData = (KSBRewardListEntity*)result.body;
            [self.tabView reloadData];
            if(self.dataArray.count == 0)
            {
                if (self.noRedRepperLabel.hidden)
                {
                    self.noRedRepperLabel.hidden = NO;
                }
                
            }
            else
            {
                self.noRedRepperLabel.hidden = YES;
                
            }
            
        }
    }
    [self endRefreshing];
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{

    [self endRefreshing];
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
    INFO(@"%@ %@",blEntity,result);
}

@end
