//
//  KSWholeInvestVC.m
//  kaisafax
//
//  Created by philipyu on 16/8/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSWholeInvestVC.h"
#import "KSAccountInvestVC.h"

//#define kAccountInvestStatusArray  @[@"FROZEN",@"LOANED",@"CLEARED"]

@interface KSWholeInvestVC ()
@property (nonatomic,strong) NSArray *investCategories;
@end

@implementation KSWholeInvestVC

//懒加载
-(NSArray*)investCategories
{
    if (_investCategories== nil) {
        self.investCategories = @[@"投标中",@"还款中",@"已还清"];
    }
    return _investCategories;
    
}

- (instancetype)initWithIndex:(int)index {
    if (self = [super init])
    {
        self.title = KMyInvestTitle;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15.0;
        self.pageAnimatable = YES;
        self.menuItemWidth = MAIN_BOUNDS_SCREEN_WIDTH/self.investCategories.count;
        self.menuHeight = KWMPageTitleHeight;
        self.menuBGColor= WhiteColor;
        self.hidesBottomBarWhenPushed = YES;
        self.selectIndex = index;

        self.titleColorSelected = NUI_HELPER.appOrangeColor;
        self.titleColorNormal = NUI_HELPER.appLightGrayColor;
//        self.progressColor = NUI_HELPER.appDarkGrayColor;
        
        UIView *sepView = [[UIView alloc]init];
        sepView.frame = CGRectMake(0, KWMPageTitleHeight-0.5, MAIN_BOUNDS_SCREEN_WIDTH, 0.5);
        sepView.backgroundColor = UIColorFromHex(0xebebeb);
        [self.view addSubview:sepView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //设置返回按钮
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 内部加载
-(void)setNavButtonByImage:(NSInteger) btnType
                 imageName:(NSString *) btnImageName
         selectedImageName:(NSString *)btnSelectedImageName
              navBtnAction:(SEL) btnAction
{
    if (btnImageName) {
        UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [customButton addTarget:self action:btnAction forControlEvents:UIControlEventTouchUpInside];
        [customButton setImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -8.0f;
        
        UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:customButton ];
        
        if(btnType == kNavLeftButtonTag){
            //self.navLeftBtn = navBtn;
            navBtnItem.tag = 112801;
            self.navigationItem.leftBarButtonItems = @[space, navBtnItem];
        }else if (btnType == kNavRightButtonTag) {
            //self.navRightBtn = navBtn;
            self.navigationItem.rightBarButtonItems = @[space, navBtnItem];
        }
        else if(btnType == kNavBackButtonTag)
        {
            self.navigationItem.backBarButtonItem = navBtnItem;
        }
    }
}

-(void)setNavLeftButtonByImage:(NSString *) leftBtnImgName
             selectedImageName:(NSString *)leftBtnSImageName
                  navBtnAction:(SEL) btnAction{
    [self setNavButtonByImage:kNavLeftButtonTag
                    imageName:leftBtnImgName
            selectedImageName:leftBtnSImageName
                 navBtnAction:btnAction];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
    return self.investCategories.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    KSAccountInvestVC *vc = [[KSAccountInvestVC alloc] init];
//    NSArray *tepArray = kAccountInvestStatusArray;
//    vc.status = tepArray[index];
    NSInteger status = KSDoInvestStatusFrozen;
    switch (index)
    {
        case 0:
            status = KSDoInvestStatusFrozen;
            break;
        case 1:
            status = KSDoInvestStatusLoaned;
            break;
        case 2:
            status = KSDoInvestStatusCleared;
            break;
        default:
            break;
    }
    vc.status = status;
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index
{
    return self.investCategories[index];
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
   DEBUGG(@"%@ %@",viewController,info);
}


@end
