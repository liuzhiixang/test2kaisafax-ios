//
//  KSADStartVC.m
//  kaisafax
//
//  Created by semny on 16/9/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADStartVC.h"
#import "KSADStartCell.h"
#import "KSADStartLayout.h"
#import "AppDelegate.h"
#import "KSADMgr.h"

//网路广告数据key
#define KADStartNWURLKey @"ADStartNWURLKey"

@interface KSADStartVC ()<UICollectionViewDelegate, UICollectionViewDataSource, KSADStartDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//是否为网络广告数据
@property (assign, nonatomic) BOOL isNWAD;
//广告数据或者本地启动数据
@property (strong, nonatomic) NSArray *adDatas;

@end

@implementation KSADStartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //设置layout
    KSADStartLayout *layout = [[KSADStartLayout alloc] init];
    _collectionView.collectionViewLayout = layout;
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"KSADStartCell" bundle:nil] forCellWithReuseIdentifier:KADStartReusedID];
    
    //加载数据
    [self loadData];
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

- (void)loadData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *adStartNWURLArray = [userDefaults objectForKey:KADStartNWURLKey];
    //判断是不是本地的启动数据
    if (adStartNWURLArray && adStartNWURLArray.count > 0)
    {
        _isNWAD = YES;
        _adDatas = adStartNWURLArray;
    }
    else
    {
        _isNWAD = NO;
        _adDatas = @[@"new_feature_1", @"new_feature_2", @"new_feature_3"];
    }
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.adDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KSADStartCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:KADStartReusedID forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = ViewFromNib(@"KSADStartCell", 0);
    }
    cell.delegate = self;
    
    NSInteger row = indexPath.row;
    UIImage *image = [self loadImageWith:indexPath array:_adDatas isNWAD:_isNWAD];
    //判断最后一行
    if (row == _adDatas.count - 1)
    {
        cell.startBtn.hidden = NO;
    }
    else
    {
        cell.startBtn.hidden = YES;
    }
    [cell.adImageView setImage:image];
    return cell;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.adDatas.count <= indexPath.row)
    {
        return;
    }
    
    [self collectionViewTapCellAtIndex:indexPath];
}

- (void)collectionViewTapCellAtIndex:(NSIndexPath *)indexPath
{
    NSString *imgUrl = [self.adDatas objectAtIndex:indexPath.row];
    
    // 填补Item不作处理
    if (imgUrl == nil) {
        return;
    }
}

#pragma mark - 加载图片
- (UIImage *)loadImageWith:(NSIndexPath *)indexPath array:(NSArray *)array isNWAD:(BOOL)flag
{
    NSString *name = nil;
    NSInteger index = indexPath.row;
    UIImage *image = nil;
    if (flag)
    {
        //网络广告
        //TODO: Hanle network AD data
    }
    else
    {
        //本地广告
        NSString *defaultName = nil;
        if(index >= 0 && array.count > index)
        {
            defaultName = [array objectAtIndex:index];
        }
        if (defaultName && defaultName.length > 0)
        {
            //本地AD数据
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                CGFloat mainHeight = [UIScreen mainScreen].bounds.size.height;
                if (mainHeight == 480)
                {
                    // iPhone 4/4s, 3.5 inch screen
                    name = [NSString stringWithFormat:@"%@", defaultName];
                }
                else if (mainHeight == 568)
                {
                    // iPhone 5/5s, 4.0 inch screen
                    name = [NSString stringWithFormat:@"%@-568h", defaultName];
                }
                else if (mainHeight == 667)
                {
                    // iPhone 6, 4.7 inch screen
                    name = [NSString stringWithFormat:@"%@-667h", defaultName];
                }
                else if (mainHeight == 736)
                {
                    // iPhone 6+, 5.5 inch screen
                    name = [NSString stringWithFormat:@"%@-736h", defaultName];
                }
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
            }
            
            //name = defaultName;
        }
        if (name && name.length > 0)
        {
            image = [UIImage imageNamed:name];
        }
    }
    return image;
}

#pragma mark - KSADStartDelegate
- (void)startAction:(KSADStartCell *)cell
{
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    //启动安全相关流程
    UIViewController *securityVC = [appDelegate startSecurityPageWithBegin:nil afterBlock:nil];
    if (!securityVC)
    {
        //启动主界面
        [appDelegate startMainPage];
    }
    //设置显示启动广告页的标志
    [KSADMgr setUnshowFlagADStartPage];
}
@end
