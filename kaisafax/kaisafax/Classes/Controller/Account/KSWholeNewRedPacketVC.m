//
//  KSWholeNewRedPacketVC.m
//  kaisafax
//
//  Created by BeiYu on 2017/4/12.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSWholeNewRedPacketVC.h"
#import "KSSingleRedPacketVC.h"
#import "KSWebVC.h"
#import "KSConst.h"
#define  kRedPacketRules    @"红包规则"


@interface KSWholeNewRedPacketVC ()
@property (nonatomic, strong) NSArray *redpacketCategories;

@end

@implementation KSWholeNewRedPacketVC

- (instancetype)init {
    if (self = [super init])
    {
        self.title = @"我的红包";
        self.menuViewStyle = WMMenuViewStyleLine;
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15.0;
        self.pageAnimatable = YES;
        self.menuItemWidth = MAIN_BOUNDS_SCREEN_WIDTH/self.redpacketCategories.count;
        self.menuHeight = KWMPageTitleHeight;
        self.menuBGColor = WhiteColor;
        self.titleColorSelected = NUI_HELPER.appOrangeColor;
        self.titleColorNormal = NUI_HELPER.appLightGrayColor;
        self.selectIndex = 0;
        
        UIView *sepView = [[UIView alloc]init];
        sepView.frame = CGRectMake(0, KWMPageTitleHeight-0.5, MAIN_BOUNDS_SCREEN_WIDTH, 0.5);
        sepView.backgroundColor = UIColorFromHex(0xebebeb);
        [self.view addSubview:sepView];
        //        self.viewFrame = CGRectMake(0.0f, 0.0f, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT-20.0f-44.0f);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
    [self setNavRightButtonByText:kRedPacketRules titleColor:[UIColor whiteColor] imageName:nil selectedImageName:nil navBtnAction:@selector(seeRules)];
}

-(void)setNavLeftButtonByImage:(NSString *) leftBtnImgName
             selectedImageName:(NSString *)leftBtnSImageName
                  navBtnAction:(SEL) btnAction{
    [self setNavButtonByImage:kNavLeftButtonTag
                    imageName:leftBtnImgName
            selectedImageName:leftBtnSImageName
                 navBtnAction:btnAction];
}

-(void)setNavButtonByImage:(NSInteger) btnType
                 imageName:(NSString *) btnImageName
         selectedImageName:(NSString *)btnSelectedImageName
              navBtnAction:(SEL) btnAction
{
    if (btnImageName) {
        UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [customButton addTarget:self action:btnAction forControlEvents:UIControlEventTouchUpInside];
        [customButton setImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
        customButton.tag = btnType;
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -8.0f;
        
        UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:customButton ];
        navBtnItem.tag = btnType;
        if(btnType == kNavLeftButtonTag){
            //self.navLeftBtn = navBtn;
            //            navBtnItem.tag = 112801;
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

-(void)setNavButtonByText:(NSInteger)btnType
               navBtnName:(NSString *)btnName
               titleColor:(UIColor *)titleColor
                imageName:(NSString *)btnImageName
        selectedImageName:(NSString *)btnSelectedImageName
             navBtnAction:(SEL) btnAction
              navBtnWidth:(NSInteger)width
             navBtnHeight:(NSInteger)height{
    CGRect frameimg = CGRectMake(0, 0, width, height);
    UIButton *navBtn = [[UIButton alloc] initWithFrame:frameimg];
    if ([btnImageName isValid]) {
        [navBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
    }else{
        [navBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    if ([btnSelectedImageName isValid]) {
        [navBtn setBackgroundImage:[UIImage imageNamed:btnSelectedImageName] forState:UIControlStateSelected];
    }else{
        [navBtn setBackgroundImage:nil forState:UIControlStateSelected];
    }
    [navBtn setTitle:btnName forState:UIControlStateNormal];
    [navBtn setTitleColor:titleColor forState:UIControlStateNormal];
    [navBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    navBtn.titleLabel.font = WholeVCTitleFont;
    [navBtn addTarget:self action:btnAction forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil action:nil];
    space.width = -3.0f;
    
    UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:navBtn] ;
    if(btnType == kNavLeftButtonTag){
        // self.navLeftBtn = navBtn;
        [navBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.navigationItem.leftBarButtonItems= @[space, navBtnItem];;
    }else if (btnType == kNavRightButtonTag) {
        // self.navRightBtn = navBtn;
        [navBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.navigationItem.rightBarButtonItems = @[space, navBtnItem];;
    }
}

-(void)setNavRightButtonByText:(NSString *)btnName
                    titleColor:(UIColor *)titleColor
                     imageName:(NSString *)rightBtnImgName
             selectedImageName:(NSString *)rightBtnSImageName
                  navBtnAction:(SEL) btnAction
{
    [self setNavButtonByText:kNavRightButtonTag navBtnName:btnName titleColor:titleColor imageName:rightBtnImgName selectedImageName:rightBtnSImageName navBtnAction:btnAction navBtnWidth:kNavButtonWidth navBtnHeight:kNavButtonHeight];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 数据
/**
 *  @author semny
 *
 *  红包类型数组
 *
 *  @return 红包类型数组
 */
- (NSArray *)redpacketCategories
{
    if (!_redpacketCategories)
    {
        NSArray *titles = @[@"未激活",@"已激活",@"已过期"];
        _redpacketCategories = titles;
    }
    return _redpacketCategories;
}

#pragma mark - 响应点击事件
-(void)seeRules
{
    NSString *urlStr  = [KSRequestBL createGetRequestURLWithTradeId:KRedpacketRulePage data:nil error:nil];
    [KSWebVC pushInController:self.navigationController urlString:urlStr title:kRedPacketRules type:self.type];
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
    return self.redpacketCategories.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    KSSingleRedPacketVC *vc = [[KSSingleRedPacketVC alloc] init];
    vc.type = self.type;
    
    NSArray *tepArray = kRedPacketTypeArray;
    if (index >= 0 && index < tepArray.count)
    {
        vc.status = tepArray[index];
    }
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index
{
    NSString *string = nil;
    if (index >= 0 && index < self.redpacketCategories.count)
    {
        string = self.redpacketCategories[index];
    }
    return string;
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    DEBUGG(@"%@ %@",viewController,info);
}


@end
