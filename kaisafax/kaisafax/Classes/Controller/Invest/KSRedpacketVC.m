//
//  KSRedpacketVC.m
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRedpacketVC.h"
#import "KSRedpacketCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KSStatisticalMgr.h"

@interface KSRedpacketVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation KSRedpacketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_tableView registerNib:[UINib nibWithNibName:kRedpacketCell bundle:nil] forCellReuseIdentifier:kRedpacketCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] beginLogPageView:self.pageName];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面统计
    [[KSStatisticalMgr sharedInstance] endLogPageView:self.pageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef DEBUG
- (void)dealloc
{
    DEBUGG(@"%s", __FUNCTION__);
}
#endif

- (NSString *)pageName
{
    NSString *tPageName = NSStringFromClass(self.class);
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"KS" withString:@""];
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"VC" withString:@"Page"];
    return tPageName;
}

#pragma mark - TableView DataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:kRedpacketCell cacheByIndexPath:indexPath configuration:^(KSRedpacketCell *cell) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSRedpacketCell *cell = [tableView dequeueReusableCellWithIdentifier:kRedpacketCell];
    
    return cell;
}

@end
