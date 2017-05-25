//
//  KSMainTabBarVC.m
//  kaisafax
//
//  Created by Semny on 14-10-21.
//
//

#import "KSMainTabBarVC.h"
#import "KSHomeVC.h"
#import "KSInvestVC.h"
#import "KSNewAccountVC.h"
#import "UIImage+Util.h"
//#import "KSNavigationVC.h"

#define UD_TABBAR_USER_TAG  888666
#define UD_TABBAR_ITEM_NUM  4

//tabbar的文字颜色
#define KMainTabBarTintColor     0xee7700


//const int kTabBarViewTag = 564;

@interface KSMainTabBarVC ()<UINavigationControllerDelegate>
{
}

//@property (nonatomic, assign) BOOL isAddCenterButton;


@end

@implementation KSMainTabBarVC


- (id)init
{
    self = [super init];
    if (self)
    {
        shouldSwithTabBarHidden = YES;
        //self.isAddCenterButton = NO;
    }
    return self;
}

- (void)dealloc
{
    //[self.tabBar removeObserver:self forKeyPath:@"hidden"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    INFO(@"%@ viewDidload: test tabbar", self);
    
//    self.view.backgroundColor = NUI_HELPER.appNavigationBarTintColor;
    
    //初始化tabbar子视图
    [self configTabbarVC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    INFO(@"%@ viewWillAppear: test tabbar", self);
    
    if(SystemVersion >= 7.0)
    {
        //去掉颜色设置，将translucent设置为yes，才会有毛玻璃效果
//        self.tabBar.barTintColor = ColorTitleBarBg;
        self.tabBar.translucent = YES;
    }
    else
    {
        self.tabBar.tintColor = UIColorFromHex(KMainTabBarTintColor);
    }
    
    //显示居中的按钮
    [self willAppearIn:self.navigationController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //TabBarVC 显示
    _isSelfAppear = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:KTabBarVCShowNotifyKey object:[NSNumber numberWithBool:self.isSelfAppear]];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.isSelfAppear = NO;
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //TabBarVC 隐藏
    _isSelfAppear = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:KTabBarVCShowNotifyKey object:[NSNumber numberWithBool:self.isSelfAppear]];
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
//    if (self.isAddCenterButton == NO) {
//        [self addCenterButtonWithImage:[UIImage imageNamed:@"record_icon_normal"] highlightImage:[UIImage imageNamed:@"record_icon_pressed"]];
//        self.isAddCenterButton = YES;
//    }
}

#pragma mark - Tabbar子页面
- (void)configTabbarVC
{
    //tab子页面
    //首页
    UIViewController *homeVC = [[KSHomeVC alloc] initWithNibName:@"KSHomeVC" bundle:nil];
    [NUIRenderer renderTabBarItem:homeVC.tabBarItem withClass:@"HomeTabBarItem"];
    [NUIRenderer renderTabBarItem:homeVC.tabBarItem withClass:@"TabBarItem"];
    homeVC.tabBarItem.title = KTabbarHomeTitle;
    //理财页面
    UIViewController *investVC = [[KSInvestVC alloc] initWithNibName:@"KSInvestVC" bundle:nil];
    [NUIRenderer renderTabBarItem:investVC.tabBarItem withClass:@"InvestTabBarItem"];
    [NUIRenderer renderTabBarItem:investVC.tabBarItem withClass:@"TabBarItem"];
    investVC.tabBarItem.title = KTabbarInvestTitle;
    //我的，个人中心
    UIViewController *accountVC = [[KSNewAccountVC alloc] initWithNibName:@"KSNewAccountVC" bundle:nil];
    [NUIRenderer renderTabBarItem:accountVC.tabBarItem withClass:@"AccountTabBarItem"];
    [NUIRenderer renderTabBarItem:accountVC.tabBarItem withClass:@"TabBarItem"];
    accountVC.tabBarItem.title = KTabbarAccountTitle;
    
    //tabbar所有页面数组
    NSMutableArray *vcArray = [NSMutableArray arrayWithObjects:homeVC, investVC, accountVC, /*moreVC,*/ nil];
    
    // 各选项卡设置
    for (int i = 0; i < vcArray.count; i++)
    {
        UIViewController *viewController = vcArray[i];
        UINavigationController *tabItemNav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [tabItemNav setDelegate:self];
        
        //设置tab bar item的颜色和字体大小
        //UITabBarItem *tabBarItem = tabItemNav.tabBarItem;
        //tabBarItem.title = title;
        
        [vcArray replaceObjectAtIndex:i withObject:tabItemNav];
    }
    [self setViewControllers:vcArray];
    //[self.tabBar setShadowImage:nil];
    //设置分割线颜色
//    [self setTopLineColor:UIColorFromHex(0x1b1b1b)];
    [self setTopLineHidden:NO];
    
    //默认进到第一个tab页面
    [self setSelectedIndex:0];
}

- (void)setTopLineHidden:(BOOL)hidden
{
    if (hidden)
    {
        [self.tabBar setClipsToBounds:YES];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
        {
            UIImage *image = [[UIImage alloc] init];
            [[UITabBar appearance] setShadowImage:image];
            [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
        }
    }
    else
    {
        [self.tabBar setClipsToBounds:NO];
    }
}

- (void)setTopLineColor:(UIColor *)color
{
    if (color)
    {
        [self.tabBar setClipsToBounds:NO];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
        {
            UIImage *image = [UIImage imageFromColor:color withFrame:CGRectMake(0.0f, 0.0f, MAIN_BOUNDS_SCREEN_WIDTH, 1.0f)];
            [[UITabBar appearance] setShadowImage:image];
            [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
        }
    }
}
@end
