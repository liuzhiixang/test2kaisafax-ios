//
//  KSFundRecordVC.m
//  kaisafax
//
//  Created by BeiYu on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSFundRecordVC.h"
#import "KSAccountFundRecordCell.h"
#import "KSAccountFundRecordModel.h"
#import "KSAccountFundRecordSortView.h"
#import "KSTimeChoose.h"
#import "KSConst.h"
#import "KSFundBL.h"
#import "KSUserMgr.h"
#import "KSUserFRItemEntity.h"
#import "NSDate+Utilities.h"
#import "KSListEntity.h"
#import "KSUserFRGroupEntity.h"
//#import "UIViewController+BackButtonHandler.h"

#define daysTosecs   (24*3600)
#define msecs        1000
#define  animalKeyPath @"position"//@"transform.scale"
#define kPageNumber   20
#define  cellHeight   60
#define  cellTtlHeight 30
#define  margin        10

@interface KSFundRecordVC ()<KSAccountFundRecordSortDelegate,KSTimeDelegate,KSBLDelegate>
@property (strong, nonatomic) KSTimeChoose *timeChoose;
@property (nonatomic,weak) KSAccountFundRecordSortView *sortsubView;
@property (weak, nonatomic) UIView *sortView;
@property (weak, nonatomic) UIButton *fromBtn;
@property (strong, nonatomic) KSFundBL *fundBL;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

////数据模型数组，资金的数据和是否显示week和date的标志
//@property (nonatomic,strong) NSMutableArray *dataArray;
////显示title的数组
//@property (nonatomic,strong) NSMutableArray *titlesArray;

//请求返回的封装好的接口原始数据
@property (nonatomic, strong) KSListEntity *listData;
@property (nonatomic, weak)  NSArray *dataArray;

//整理后的数据title key & KSAccountFundRecordModel array
//@property (nonatomic,strong) NSMutableDictionary *titleAndItemDict;
//@property (nonatomic,strong) NSMutableArray *titlesArray;

@property (nonatomic,assign) BOOL isOpenSort;
@property (weak, nonatomic) IBOutlet UIView *noFundChars;
//预加载的index
@property (nonatomic,assign) BOOL updating;

//@property (nonatomic,assign) BOOL isFirstLoading;

@end

@implementation KSFundRecordVC
//懒加载
-(NSArray *)dataArray
{
    _dataArray = _listData.dataList;
    return _dataArray;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //加载导航栏
    [self configNav];
    
    
    self.isOpenSort = NO;
    
    kRegisterCellNib(self.tableView,kSAccountFundRecordCell);
    // 去外围的线条
    self.tableView.separatorColor = ClearColor;
    
    self.tableView.backgroundColor = UIColorFromHex(0xebebeb);
    
    // 创建请求的BL
    if (!self.fundBL)
    {
        KSFundBL *fundBL = [[KSFundBL alloc]init];
        fundBL.delegate = self;
        self.fundBL = fundBL;
    }
    
    // 进入页面初始化设置为查询三个月，全部资金信息
    [self initFundBL];
    
    //配置下拉上拉刷新操作
    [self tableRefreshGif];
    
//    _updating = NO;
    //开始请求数据
    [self refreshWithAnimation:YES];
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if (self.isOpenSort)
//    {
//        [self exitSort];
//        
//        UIWindow *window = KEY_WINDOW;
//        INFO(@"%@",window.subviews);
//        //        if (window.subviews.count >= ) {
//        //            <#statements#>
//        //        }
//        [window.subviews.lastObject removeFromSuperview];
//        [window.subviews.lastObject removeFromSuperview];
//        INFO(@"%@",window.subviews);
//    }
    
}

-(void)leftButtonAction:(id)sender
{
    if (self.isOpenSort)
    {
        [self exitSort];
        
        UIWindow *window = KEY_WINDOW;
        INFO(@"%@",window.subviews);
        if (window.subviews.count >= 2)
        {
            [window.subviews.lastObject removeFromSuperview];
            [window.subviews.lastObject removeFromSuperview];
        }

        INFO(@"%@",window.subviews);
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 加载视图
- (void)configNav
{
    // 设置导航栏标题，左边右边图标
    
    self.title = KFundRecordTitle;

    [self setNavRightButtonByImage:@"ic_fund_sort" selectedImageName:nil navBtnAction:@selector(sortMenuOpen)];
    

}

#pragma mark - 刷新控件
- (void)tableRefreshGif
{
    // 添加动画图片的上拉刷新
    [self scrollView:_tableView headerRefreshAction:@selector(refreshing) footerRefreshAction:@selector(loadingMore)];
}

/**
 *  @author semny
 *
 *  刷新操作
 *
 *  @param flag YES:支持动画；NO:不支持动画
 */
- (void)refreshWithAnimation:(BOOL)flag
{
    if (flag)
    {
        //支持下拉刷新动画
        [_tableView.mj_header beginRefreshing];
    }
    else
    {
        //无下拉刷新动画
        [self refreshing];
    }
}
/**
 *  @author yubei
 *
 *  刷新操作
 *
 *  @param
 */
-(void)initFundBL
{
    NSDate *now = [NSDate date];
    long long nowInterval = (long long)[now timeIntervalSince1970];
    
    //拉取最多三个月的资金流水
    long long chaInterval = 90*daysTosecs;
    self.fundBL.toTime = nowInterval * msecs;
    self.fundBL.fromTime = (nowInterval-chaInterval) * msecs;
    
    INFO(@"%@",[NSDate dateWithTimeIntervalSince1970:(nowInterval-chaInterval)]);
    self.fundBL.filterType = @"ALL";
}
/**
 *  @author semny
 *
 *  刷新当前页面数据
 */
- (void)refreshing
{
    if(!_fundBL)
    {
        _fundBL = [[KSFundBL alloc] init];
        _fundBL.delegate = self;
    }
    
    //请求首页信息
    [_fundBL refreshUserFundRecords];
}

- (void)loadingMore
{
    //加载更多
    if(!_fundBL)
    {
        _fundBL = [[KSFundBL alloc] init];
        _fundBL.delegate = self;
    }
    //请求用户交易记录
    [_fundBL requestNextPageUserFundRecords];
}



#pragma mark - 打开筛选查询下拉菜单
-(void)sortMenuOpen
{
    DEBUGG(@"------sortMenuOpen------");
    
    self.isOpenSort = !self.isOpenSort;
    if (self.isOpenSort)
    {
        if(self.sortView)
        {
            [self sortAnimation];
            return;
        }
        
        CGFloat navH = navBarHeight;
        UIView *sortView = [[UIView alloc]init];
        sortView.frame = CGRectMake(0, navH, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT-navH);
        sortView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitSort)];
        [sortView addGestureRecognizer:gesture];
        
        CGRect frame = CGRectMake(0, navH, MAIN_BOUNDS_SCREEN_WIDTH, 332);
        KSAccountFundRecordSortView *sortsubView = ViewFromNib(@"KSAccountFundRecordSortView",0);
        sortsubView.frame = frame;
        [sortsubView initStatus];
        sortsubView.delegate = self;
        [self sortAnimation];
        
        self.sortsubView = sortsubView;
        self.sortView = sortView;
        UIWindow *window = KEY_WINDOW;
        [window addSubview:sortView];
        [window addSubview:sortsubView];
        
    }
    else
    {
        [self exitSort];
    }

}

-(void)sortAnimation
{
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:animalKeyPath];
//    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:animalKeyPath];
    scaleAnimation.duration = 0.1;
    if (self.isOpenSort)
    {
        scaleAnimation.values = @[@0.2,@0.5,@0.8,@1.0];

    }
    else
    {
        scaleAnimation.values = @[@0.8,@0.5,@0.2,@0.0];

    }
    
    
    [self.sortView.layer addAnimation:scaleAnimation forKey:animalKeyPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sortView.layer removeAllAnimations];
        
        self.sortView.hidden = !self.isOpenSort;
        self.sortsubView.hidden = self.sortView.hidden;
    });
}

-(void)exitSort
{

    [self sortAnimation];
    self.isOpenSort = NO;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.dataArray.count;
    return count>0?count:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger secNum = 0;
    KSUserFRGroupEntity *group = nil;
    NSArray *array = nil;
    if (section >= 0 && section < self.dataArray.count)
    {
        group = [self.dataArray objectAtIndex:section];
    }
    if (group)
    {
        array = group.dataList;
    }
    secNum = array.count;
    return secNum;
}

//#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KSAccountFundRecordCell *cell = (KSAccountFundRecordCell *) [tableView dequeueReusableCellWithIdentifier:kSAccountFundRecordCell forIndexPath:indexPath];
    
    // Configure the cell...
    if (!cell)
    {
        cell = (KSAccountFundRecordCell *)[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:kSAccountFundRecordCell ];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    KSUserFRGroupEntity *group = nil;
    NSArray *array = nil;
    if (section >= 0 && section < self.dataArray.count)
    {
        group = [self.dataArray objectAtIndex:section];
    }
    if (group)
    {
        array = group.dataList;
    }

//    NSLog(@"%s %p",__FUNCTION__,cell);
    // 设置模型数据到cell控件
    
    KSAccountFundRecordModel *item = nil;
    if (row >= 0 && row < array.count)
    {
        item = array[row];
        
        if (row == array.count-1)
        {
            [cell updateItem:item clearSeprator:YES];
        }
        else
        {
            [cell updateItem:item clearSeprator:NO];
        }
    }


    return cell;
}

//section title
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    KSUserFRGroupEntity *group = nil;
    NSString *title = nil;
    if (section >= 0 && section < self.dataArray.count)
    {
        group = [self.dataArray objectAtIndex:section];
    }
    
    title = [NSString stringWithFormat:@"%@ 年",group.sectionDateTitle];
    return title;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil)
    {
        return  nil;
    }
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(margin, 0, MAIN_BOUNDS_SCREEN_WIDTH-margin, cellTtlHeight);
    label.textColor = UIColorFromHex(0xa0a0a0);
    label.font=[UIFont systemFontOfSize:12.0];
    label.text = sectionTitle;
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, cellTtlHeight)] ;
    [sectionView setBackgroundColor:UIColorFromHex(0xf0f0f0)];
    [sectionView addSubview:label];
    return sectionView;
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%@",scrollView);
    NSInteger contentOffSetY = scrollView.contentOffset.y;
    NSInteger contentSizeH = scrollView.contentSize.height;
    
    
    NSUInteger line = 5;
    NSInteger chaContent = (NSInteger)(contentSizeH-contentOffSetY);
    NSInteger chaHetight = (NSInteger)(cellHeight*line+MAIN_BOUNDS_SCREEN_HEIGHT-NavigationBarHeight- StatusBarHeight);
    
//    NSLog(@"%ld - %ld = %ld - %ld",contentSizeH,contentOffSetY,contentSizeH-contentOffSetY,chaHetight);
    //还剩5行cell的时候去预加载
    if(contentSizeH == 0)
    {
        return;
    }
    
    if ((chaContent >= chaHetight-10 && chaContent <= chaHetight+10) && !_updating)
    {
        _updating = YES;
        [self loadingMore];
    }
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    KSUserFRGroupEntity *group = nil;
//    NSArray *array = nil;
//    if (section >= 0 && section < self.dataArray.count)
//    {
//        group = [self.dataArray objectAtIndex:section];
//    }
//    if (group)
//    {
//        array = group.dataList;
//    }
//
//    if ((array.count - row < 5) && !_updating)
//    {
//        _updating = YES;
//        [self loadingMore];
//    }
//
//
//}

#pragma mark - 资金筛选的 Delegate
-(void)accountFundRecordSortTimeFrom:(long long)from To:(long long)to Type:(NSString *)type
{
    NSLog(@"----------%s-------------from(%lld)to(%lld)",__FUNCTION__,from,to);
    //赋值参数
    self.fundBL.fromTime = from;
    self.fundBL.toTime = to;
    self.fundBL.filterType = type;
    
    self.listData = nil;
    
    [self exitSort];
    //发送请求
    [self.fundBL refreshUserFundRecords];
}


-(void)accountFundRecordSortDatePickerWithBtn:(UIButton *)btn
{
    
    KSTimeChoose *datePicker = [[KSTimeChoose alloc]initWithFrame:CGRectMake(0, 0,MAIN_BOUNDS_SCREEN_WIDTH , MAIN_BOUNDS_SCREEN_HEIGHT) type:(UIDatePickerModeDate)];
    self.timeChoose = datePicker;
    self.timeChoose.delegate = self;
    
    UIWindow *window = KEY_WINDOW;
    
    [window addSubview:datePicker];
    
    self.fromBtn = btn;
    

}

#pragma mark-  日期选择器的代理
-(void)changeTime:(NSDate *)date
{
    
}

-(void)determine:(NSDate *)date
{
    if (!self.fromBtn || !self.timeChoose)
    {
        return;
    }
    
    [self.fromBtn setTitle:[self.timeChoose stringFromDate:date] forState:(UIControlStateNormal)];
}




#pragma mark - 请求回调
-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    
//    [self endRefreshing];
    _updating = NO;
    
    INFO(@"%s %@ %@",__FUNCTION__,blEntity,result.body);
//    if (!result) return;
//    if (!result.body) return;
//    if(result.errorCode != 0) return;
    
    
    self.listData = result.body;
    
    //id entity = result.body;
    NSString *tradeId = result.tradeId;
    //INFO(@"finishBatchHandle %@", NSStringFromClass([entity class]));
    
    if([tradeId isEqualToString:KUserFundRecordTradeId])
    {
        self.listData = result.body;
        //列表刷新
        BOOL isRefresh = self.listData.isRefresh;
        //取消转菊花
        if (isRefresh)
        {
            [_tableView.mj_header endRefreshing];
        }else{
            [_tableView.mj_footer endRefreshing];
        }
        //把新的数据存在显示数组
//        if (self.listData.dataList)
//        {
//            [self calculateIsShowDate:self.listData.dataList];
//            [self titles:self.listData.dataList];
//        }
        
        
        
        //刷新列表
        [self.tableView reloadData];
        
        //是否显示没有资金记录
        if (self.dataArray.count == 0)
        {
            self.noFundChars.hidden = NO;
        }
        else
        {
            self.noFundChars.hidden = YES;
        }
        
        
    }
}




-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%s %@ %@",__FUNCTION__,blEntity,result.body);
    _updating = NO;
//    [self endRefreshing];
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tradeId = result.tradeId;
        if([tradeId isEqualToString:KUserFundRecordTradeId])
        {
            weakself.listData = result.body;
            //列表刷新
            BOOL isRefresh = weakself.listData.isRefresh;
            //取消转菊花
            if (isRefresh)
            {
                [weakself.tableView.mj_header endRefreshing];
            }else{
                [weakself.tableView.mj_footer endRefreshing];
            }
//            _updating = NO;
        }
        //隐藏菊花
        //        [weakself hideProgressHUD];
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
        

    });
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
//    [self endRefreshing];
     INFO(@"%s %@ %@",__FUNCTION__,blEntity,result);
    _updating = NO;
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tradeId = result.tradeId;
        if([tradeId isEqualToString:KUserFundRecordTradeId])
        {
            weakself.listData = result.body;
            //列表刷新
            BOOL isRefresh = weakself.listData.isRefresh;
            //取消转菊花
            if (isRefresh)
            {
                [weakself.tableView.mj_header endRefreshing];
            }else{
                [weakself.tableView.mj_footer endRefreshing];
            }
//            _updating = NO;
        }
        
        //隐藏菊花
        //        [weakself hideProgressHUD];

        {
            [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
        }
        
       
        
        //产品需求输出没有资金记录提示
        if(weakself.dataArray.count == 0 || !weakself.dataArray)
        {
            weakself.noFundChars.hidden = NO;
        }
    });

}

@end
