//
//  KSNVBaseVC.h
//  kaisafax
//
//  Created by SemnyQu on 14/10/25.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import "KSNVBaseVC.h"
//#import "UIImage+Resize.h"
#import "KSStatisticalMgr.h"
#import "UINavigationBar+Additions.h"

@interface KSNVBaseVC()
{
    BOOL _navigationBarTranslucent;
}

//进度加载框
@property (nonatomic,strong) MBProgressHUD    *appLoadingView;

@property (nonatomic,strong) UIButton *navLeftBtn;
@property (nonatomic,strong) UIButton *navRightBtn;

//是否显示nav bar下的黑线
@property (nonatomic,assign) BOOL showShadowImage;

@end

@implementation KSNVBaseVC
//@synthesize navLeftBtn;
//@synthesize navRightBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _shouldShowLeftNavBtn = YES;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _shouldShowLeftNavBtn = YES;
//        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navBackImgName"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)] forBarMetrics:UIBarMetricsDefault];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#ifdef DEBUG
- (void)dealloc
{
    DEBUGG(@"<--------------%s, %@-------------->", __FUNCTION__, self);
}
#endif

- (NSString *)pageName
{
    NSString *tPageName = NSStringFromClass(self.class);
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"KS" withString:@""];
    tPageName = [tPageName stringByReplacingOccurrencesOfString:@"VC" withString:@"Page"];
    return tPageName;
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    //默认会显示
    _needShowNavBar = YES;
    
    //只有在父类先设置好返回按钮, 二级VC才能生效
    [self userBackBarButtonItem];
    if (!_shouldShowLeftNavBtn)
    {
        //DEBUGG(@"Hide left nav btn!");
        //隐藏回退按钮
        [self.navigationItem setHidesBackButton:YES];
    }
    else
    {
        //DEBUGG(@"Show left nav btn!");
        [self.navigationItem setHidesBackButton:NO];
    }
    
    if (IOS7_AND_LATER)
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    _navigationBarTranslucent = self.navigationController.navigationBar.translucent;

//    [self configNavView];
//    [self setBackgroundColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isWillAppear = YES;
    //页面统计
    [[KSStatisticalMgr sharedInstance] beginLogPageView:self.pageName];
    
    /**
     *  针对最外层的navgation bar的处理，无navgation bar
     */
    if (self.navigationController.navigationController) {
        self.navigationController.navigationController.navigationBarHidden = YES;
    }
    
    //显示导航栏的判断
    if(self.needShowNavBar)
    {
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController.navigationBar setHidden:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController.navigationBar setHidden:YES];
    }
    
    if (self.navigationController)
    {
        if ([self preferredStatusBarStyle] == UIStatusBarStyleLightContent) {
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        }else{
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        }
        
        if ([self transparentNavigationBar])
        {
            [self.navigationController.navigationBar makeTransparent];
        }
        else if(!self.showShadowImage)
        {
            //背景隐藏线
            [self.navigationController.navigationBar hideBottomHairline];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isWillAppear = NO;
    //页面统计
    [[KSStatisticalMgr sharedInstance] endLogPageView:self.pageName];

    if ([self transparentNavigationBar]) {
        [self.navigationController.navigationBar makeDefault];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isAppear = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//显示方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)configNavView
//{
//    if(IOS5_AND_LATER)
//    {
//        if (IOS7_AND_LATER)
//        {
//            //设置文字颜色
//            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
//            [self.navigationController.navigationBar setTitleTextAttributes:attributes];
//        }
//        else
//        {
//            //设置文字颜色
//            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
//            [self.navigationController.navigationBar setTitleTextAttributes:attributes];
//        }
//    }
//}

//统一设备返回按钮的文本
- (void)userBackBarButtonItem
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


//导航栏显示标志/透明标志
- (BOOL)transparentNavigationBar
{
    return NO;
}

//状态栏的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//设置当前view的满填充
- (void)setFillContentView
{
    CGRect fillRect = [self getCurrentFillFrame];
    if (CGRectEqualToRect(fillRect, CGRectZero) || CGRectEqualToRect(fillRect, self.view.frame))
    {
        return;
    }
    self.view.frame = fillRect;
}

//获取当前应该填充的frame
- (CGRect)getCurrentFillFrame
{
    CGRect rect = self.view.frame;
    CGFloat fillHeight = MAIN_BOUNDS_SCREEN_HEIGHT;
    CGFloat navbarHeight = 0.0f;
    CGFloat tabbarHeight = 0.0f;
    BOOL navBarHidden = YES;
    if (self.navigationController)
    {
        navBarHidden = self.transparentNavigationBar;
        //导航栏未隐藏
        if (!navBarHidden)
        {
            navbarHeight = NavigationBarHeight+StatusBarHeight;
        }
    }
    
    BOOL tabbarHidden = self.hidesBottomBarWhenPushed;
    //导航栏未隐藏
    if (!tabbarHidden)
    {
        tabbarHeight = TabBarHeight;
    }
    fillHeight -= (navbarHeight+tabbarHeight);
    
    //当前应该显示的fill rect
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, fillHeight);
    
    return rect;
}

#pragma mark - HUD
//- (void)showProgressHUD {
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    //[self.view addSubview:hud];
//    //hud.opacity = 0.8;
//    hud.color = UIColorFromHexA(0xFFFFFF, 0.6);
//    hud.activityIndicatorColor = UIColorFromHex(0xFD3D07);
//    
//    [self.view addSubview:hud];
//    [hud show:YES];
//}
//
//- (void)hideProgressHUD
//{
////    NSArray *hudArr = [MBProgressHUD allHUDsForView:self.navigationController.view];
////    for (int i = 0; i < hudArr.count; i++) {
////        MBProgressHUD *hud = hudArr[i];
////        [hud removeFromSuperview];
////        hud = nil;
////    }
//    
//    NSArray *hudArr = [MBProgressHUD allHUDsForView:self.view];
//    for (int i = 0; i < hudArr.count; i++) {
//        MBProgressHUD *hud = hudArr[i];
//        [hud removeFromSuperview];
//        hud = nil;
//    }
//}

- (void)showFailedHUDWithStr:(NSString *)str {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minSize = CGSizeMake(130, 130);
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_failed"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 1.0;
    hud.color = [UIColor whiteColor];
    hud.labelText = str;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.labelColor = [UIColor blackColor];
    
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

- (void)showSuccessHUDWithStr:(NSString *)str {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minSize = CGSizeMake(130, 130);
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_success"]];;
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 1.0;
    hud.color = [UIColor whiteColor];
    hud.labelText = str;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.labelColor = [UIColor blackColor];
    
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

- (void)showOperationHUDWithStr:(NSString *)str
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minSize = CGSizeMake(130, 130);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_operation"]];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.frame  = CGRectMake(0, 0, 60, 60);
    
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 1.0;
    hud.color = [UIColor colorWithWhite:0 alpha:0.5];
    hud.labelText = str;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.labelColor = [UIColor whiteColor];
    
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

- (void)showOperationHUDToJumpWithStr:(NSString *)str completion:(void(^)(void))completion
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minSize = CGSizeMake(130, 130);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_operation"]];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.frame  = CGRectMake(0, 0, 60, 60);
    
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 1.0;
    hud.color = [UIColor colorWithWhite:0 alpha:0.5];
    hud.labelText = str;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.labelColor = [UIColor whiteColor];
    
    [self.view addSubview:hud];
    [hud show:YES];
//    hud showAnimated:<#(BOOL)#> whileExecutingBlock:<#^(void)block#> completionBlock:<#^(void)completion#>
    hud.completionBlock = completion;
    [hud hide:YES afterDelay:3.0];
}


#pragma mark -
#pragma mark ----------------hud-----------------
/**
 *  菊花
 */
- (void)showProgressHUD
{
    if (_isHUDShowing)
    {
        [self.view bringSubviewToFront:_appLoadingView];
        return;
    }
    
    if (_appLoadingView == nil)
    {
        _appLoadingView = [[MBProgressHUD alloc] initWithView:self.view];
        _appLoadingView.color = UIColorFromHexA(0xFFFFFF, 0.6);
        _appLoadingView.activityIndicatorColor = UIColorFromHex(0xFD3D07);
    }
    
    [self.view addSubview:_appLoadingView];
    [self.view bringSubviewToFront:_appLoadingView];
    [_appLoadingView show:YES];
    _isHUDShowing = YES;
}

- (void)hideProgressHUD
{
    if (!_isHUDShowing)
    {
        return;
    }
    NSArray *hudArr = [MBProgressHUD allHUDsForView:self.view];
    for (int i = 0; i < hudArr.count; i++) {
        MBProgressHUD *hud = hudArr[i];
        [hud removeFromSuperview];
        hud = nil;
    }
    _isHUDShowing = NO;
}

- (void)showLoading
{
    [self showLoading:@"正在加载数据，请稍候…"];
}

- (void)showLoading:(NSString*)msg
{
    if (_isHUDShowing)
    {
        [self.view bringSubviewToFront:_appLoadingView];
        return;
    }
    
    if (_appLoadingView == nil)
    {
        _appLoadingView = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [self.view addSubview:_appLoadingView];
    
    _appLoadingView.labelText = msg;
    [self.view bringSubviewToFront:_appLoadingView];
    [_appLoadingView show:YES];
    _isHUDShowing = YES;
}

- (void)showLoading:(NSString *)msg belowView:(UIView *)view
{
    if (_isHUDShowing)
    {
        return;
    }
    if (_appLoadingView == nil)
    {
        _appLoadingView = [[MBProgressHUD alloc] initWithView:self.view];
        [_appLoadingView setRemoveFromSuperViewOnHide:YES];
    }
    [self.view addSubview:_appLoadingView];
    if (view) {
        [self.view insertSubview:_appLoadingView belowSubview:view];
    }else{
        [self.view bringSubviewToFront:_appLoadingView];
    }
    
    _appLoadingView.labelText = msg;
    
    [_appLoadingView show:YES];
    _isHUDShowing = YES;
}

- (void)hideLoading
{
    if (!_isHUDShowing) {
        return;
    }
    [_appLoadingView hide:YES];
    _isHUDShowing = NO;
}

#pragma mark -  
#pragma mark --------------  extend method for hud ------------
- (void)showProgressHUDInView:(UIView*)aView{
    //如果aView不为空，则把转菊花加在aView上
    if (aView) {
        if (_isHUDShowing)
        {
            [aView bringSubviewToFront:_appLoadingView];
            return;
        }
        
        if (_appLoadingView == nil)
        {
            _appLoadingView = [[MBProgressHUD alloc] initWithView:aView];
            _appLoadingView.color = UIColorFromHexA(0xFFFFFF, 0.6);
            _appLoadingView.activityIndicatorColor = UIColorFromHex(0xFD3D07);
        }
        
        [aView addSubview:_appLoadingView];
        [aView bringSubviewToFront:_appLoadingView];
        [_appLoadingView show:YES];
        _isHUDShowing = YES;
    }else{
        [self showProgressHUD];
    }
}

- (void)hideProgressHUDInView:(UIView*)aView{
    if (aView) {
        if (!_isHUDShowing)
        {
            return;
        }
        NSArray *hudArr = [MBProgressHUD allHUDsForView:aView];
        for (int i = 0; i < hudArr.count; i++) {
            MBProgressHUD *hud = hudArr[i];
            [hud removeFromSuperview];
            hud = nil;
        }
        _isHUDShowing = NO;
    }else{
        [self hideProgressHUD];
    }
}

#pragma mark -
#pragma mark ------Toast-----------------
- (void)showToastWithView:(UIView *)view title:(NSString *)title position:(NSString*)position
{
    NSString *titleStr = [title trim];
    if (!titleStr || titleStr.length <= 0)
    {
        return;
    }
    [view hideToastActivity];
    [view makeToast:titleStr duration:2.0f position:position];
}
- (void)showToastWithView:(UIView *)view title:(NSString *)title
{
    NSString *titleStr = [title trim];
    if (!titleStr || titleStr.length <= 0)
    {
        return;
    }
    [view hideToastActivity];
    [view makeToast:titleStr duration:2.0f position:CSToastPositionCenter];
}
- (void)showToastWithTitle:(NSString *)title
{
    [self showToastWithView:self.view title:title];
}
- (void)showToastWithTitle:(NSString *)title position:(NSString*)position
{
    [self showToastWithView:self.view title:title position:position];
}
//- (void)showToastWithView:(UIView *)view title:(NSString *)title hideCallBack:(hideCallBack)hideCallBack
//{
//    NSString *titleStr = [title trim];
//    if (!titleStr || titleStr.length <= 0)
//    {
//        return;
//    }
//    
//    NSValue * positionValue = [NSValue valueWithCGPoint:CGPointMake(MAIN_BOUNDS_SCREEN_WIDTH/2, MAIN_BOUNDS_SCREEN_HEIGHT/2)];
//    [view makeToast:titleStr duration:1.0f position:positionValue hideCallback:hideCallBack];
//}


#pragma mark -
-(void)setNavTitleByView:(UIView *) view
{
    if (!view)
    {
        return;
    }
    self.navigationItem.titleView = view;
}

-(void)setNavTitleByImage:(NSString *) titleImageName
{
    UIImage *mTitleImage = [UIImage imageNamed:titleImageName];
    UIImageView *mTitleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 165, 28)];
    [mTitleImageView setImage:mTitleImage];
    //[[Login _navigationItem] titleView:mTitleImageView];
    self.navigationItem.titleView = mTitleImageView;
}

-(void)setNavTitleByText:(NSString *)titleText
{
//    //DEBUGG(@"setNavTitleByText titleText: %@ <<>> %@", titleText, [self class]);
    if (titleText)
    {
        self.navigationItem.title = titleText;
    }
    else
    {
        self.navigationItem.title = self.title;
    }
}

-(void)setNavTitleByText:(NSString *)titleText withColor:(UIColor *)color
{
//    //DEBUGG(@"setNavTitleByText titleText: %@ <<>> %@", titleText, [self class]);
    if (titleText)
    {
        self.navigationItem.title = titleText;
    }
    else
    {
        self.navigationItem.title = self.title;
    }
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: WholeVCTitleFont, NSForegroundColorAttributeName: color};
}

-(void)setNavTitleTextAttributss:(NSDictionary *)titleAttributes
{
    if (titleAttributes)
    {
        self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    }
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

//-(void)setNavButtonByImage:(NSInteger) btnType
//                 imageName:(NSString *) btnImageName
//         selectedImageName:(NSString *)btnSelectedImageName
//              navBtnAction:(SEL) btnAction
//{
//    if (btnImageName) {
//        //        UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        //        [customButton addTarget:self action:btnAction forControlEvents:UIControlEventTouchUpInside];
//        //        [customButton setImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
//        //
//        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                               target:nil action:nil];
//        space.width = -8.0f;
//        //
//        //        UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:customButton ];
//        
//        UIImage *image = [UIImage imageNamed:btnImageName];
//        UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil  action:nil];
//        
//        if(btnType == kNavLeftButtonTag){
//            //self.navLeftBtn = navBtn;
//            navBtnItem.tag = 112801;
//            //self.navigationItem.leftBarButtonItems = @[space, navBtnItem];
//            
//            //self.navigationItem.backBarButtonItem = navBtnItem;//@[space, navBtnItem];
//            
//            [self.navigationItem setBackBarButtonItem:navBtnItem];
//        }else if (btnType == kNavRightButtonTag) {
//            //self.navRightBtn = navBtn;
//            self.navigationItem.rightBarButtonItems = @[space, navBtnItem];
//        }
//    }
//}

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
    navBtn.tag = btnType;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil action:nil];
    space.width = -3.0f;
    
    UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:navBtn] ;
    navBtnItem.tag = btnType;
    if(btnType == kNavLeftButtonTag){
       // self.navLeftBtn = navBtn;
        [navBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.navigationItem.leftBarButtonItems= @[space, navBtnItem];;
    }else if (btnType == kNavRightButtonTag) {
       // self.navRightBtn = navBtn;
        [navBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.navigationItem.rightBarButtonItems = @[space, navBtnItem];;
    }
    else if(btnType == kNavBackButtonTag)
    {
        self.navigationItem.backBarButtonItem = navBtnItem;
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

-(void)setNavLeftButtonByImage:(NSString *)leftBtnImgName
             selectedImageName:(NSString *)leftBtnSImageName
{
    [self setNavButtonByImage:kNavLeftButtonTag
                    imageName:leftBtnImgName
            selectedImageName:leftBtnSImageName
                 navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavLeftButtonByText:(NSString *)btnName
                   titleColor:(UIColor *)titleColor
                    imageName:(NSString *)leftBtnImgName
            selectedImageName:(NSString *)leftBtnSImageName
                 navBtnAction:(SEL) btnAction{
    [self setNavButtonByText:kNavLeftButtonTag navBtnName:btnName titleColor:titleColor imageName:leftBtnImgName selectedImageName:leftBtnSImageName navBtnAction:btnAction navBtnWidth:kNavButtonWidth navBtnHeight:kNavButtonHeight];
}

-(void)setNavLeftButton:(UIButton *)lBtn
{
    UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:lBtn];
    self.navLeftBtn = lBtn;
    self.navigationItem.leftBarButtonItem = navBtnItem;
}

#pragma mark - 右边按钮设置
-(void)setNavRightButtonByImage:(NSString *) rightBtnImgName
              selectedImageName:(NSString *)rightBtnSImageName
                   navBtnAction:(SEL) btnAction{
    [self setNavButtonByImage:kNavRightButtonTag
                    imageName:rightBtnImgName
            selectedImageName:rightBtnSImageName
                 navBtnAction:btnAction];
}

-(void)setNavRightButtonByText:(NSString *)btnName
                    titleColor:(UIColor *)titleColor
                     imageName:(NSString *)rightBtnImgName
             selectedImageName:(NSString *)rightBtnSImageName
                  navBtnAction:(SEL) btnAction
{
    [self setNavButtonByText:kNavRightButtonTag navBtnName:btnName titleColor:titleColor imageName:rightBtnImgName selectedImageName:rightBtnSImageName navBtnAction:btnAction navBtnWidth:kNavButtonWidth navBtnHeight:kNavButtonHeight];
}

-(void)setNavRightButton:(UIButton *)rBtn
{
    UIBarButtonItem *navBtnItem =[[UIBarButtonItem alloc] initWithCustomView:rBtn];
    self.navRightBtn = rBtn;
    self.navigationItem.rightBarButtonItem = navBtnItem;
}

#pragma mark - 左右按钮操作方法
-(void)navigationButtonOpption:(id)sender{
    if(sender)
    {
        NSInteger tag = -1;
        if ([sender isKindOfClass:[UIView class]])
        {
            tag = ((UIView*)sender).tag;
        }
        
        switch (tag) {
            case kNavLeftButtonTag:
                [self leftButtonAction:sender];
                break;
            case kNavRightButtonTag:
                break;
            case kNavBackButtonTag:
                break;
            default:
                break;
        }
    }
}

- (void)leftButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - nav标题
-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText{
    if (navTitleShowStyle == kNavTitleImageStyle) {
        [self setNavTitleByImage:currentTitleImageName];
    }else if (navTitleShowStyle == kNavTitleTextStyle) {
        [self setNavTitleByText:currentTitleText];
    }
}

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
       leftButton:(NSString *) currentLBtnImgName
leftButtonSelected:(NSString *)currentLBtnSelectedImgName{
    [self setNavShow:navTitleShowStyle
      titleImageName:currentTitleImageName
           titleText:currentTitleText];
    [self setNavLeftButtonByImage:currentLBtnImgName
                selectedImageName:currentLBtnSelectedImgName
                     navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
   leftButtonName:(NSString *) currentLBtnName
       leftButton:(NSString *) currentLBtnImgName
leftButtonSelected:(NSString *) currentLBtnSelectedImgName{
    [self setNavShow:navTitleShowStyle
      titleImageName:currentTitleImageName
           titleText:currentTitleText];
    [self setNavLeftButtonByText:currentLBtnName titleColor:[UIColor blueColor] imageName:currentLBtnImgName selectedImageName:currentLBtnSelectedImgName navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
  rightButtonName:(NSString *) currentRBtnName
      rightButton:(NSString *)currentRBtnImgName
rightButtonSelected:(NSString *)currentRBtnSelectedImgName{
    [self setNavShow:navTitleShowStyle
      titleImageName:currentTitleImageName
           titleText:currentTitleText];
    [self setNavRightButtonByText:currentRBtnName titleColor:[UIColor blueColor] imageName:currentRBtnImgName selectedImageName:currentRBtnSelectedImgName navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
   leftButtonName:(NSString *) currentLBtnName
       leftButton:(NSString *)currentLBtnImgName
leftButtonSelected:(NSString *)currentLBtnSelectedImgName
  rightButtonName:(NSString *) currentRBtnName
      rightButton:(NSString *)currentRBtnImgName
rightButtonSelected:(NSString *)currentRBtnSelectedImgName{
    [self setNavShow:navTitleShowStyle titleImageName:currentTitleImageName titleText:currentTitleText leftButtonName:currentLBtnName leftButton:currentLBtnImgName leftButtonSelected:currentLBtnSelectedImgName];
    [self setNavRightButtonByText:currentRBtnName titleColor:[UIColor blueColor] imageName:currentRBtnImgName selectedImageName:currentRBtnSelectedImgName navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
       leftButton:(NSString *)currentLBtnImgName
leftButtonSelected:(NSString *)currentLBtnSelectedImgName
      rightButton:(NSString *)currentRBtnImgName
rightButtonSelected:(NSString *)currentRBtnSelectedImgName
{
    [self setNavShow:navTitleShowStyle
      titleImageName:currentTitleImageName
           titleText:currentTitleText
          leftButton:currentLBtnImgName
  leftButtonSelected:currentLBtnSelectedImgName];
    [self setNavRightButtonByImage:currentRBtnImgName
                 selectedImageName:currentRBtnSelectedImgName
                      navBtnAction:@selector(navigationButtonOpption:)];
}

-(void)setNavShowDefaultLeft:(NSInteger) navTitleShowStyle
              titleImageName:(NSString *) currentTitleImageName
                   titleText:(NSString *) currentTitleText
{
    NSString *mleftUnSlectedImg = [[NSString alloc] initWithFormat:@"%@", @"btn_back"];
    NSString *mLeftSlectedImg = [[NSString alloc] initWithFormat:@"%@", @"btn_back_press"];
    //	NSString *mLeftUnSlectedImg = [[NSString alloc] initWithFormat:@"%@", @"top_left_bt_bg1"];
    //  NSString *mLeftSlectedImg = [[NSString alloc] initWithFormat:@"%@", @"top_left_bt_bg2"];
    [self setNavShow:navTitleShowStyle
      titleImageName:currentTitleImageName
           titleText:currentTitleText
          leftButton:mleftUnSlectedImg
  leftButtonSelected:mLeftSlectedImg];
}

#pragma mark - nav背景相关
-(void)setNavBarBackgroundImage:(UINavigationBar *)navigationBar navBackImgName:(NSString *)navBackImgName
{
    if (navigationBar)
    {
        //在5.0以后可以使用该方法
        [navigationBar setBackgroundImage:[[UIImage imageNamed:navBackImgName] rescaleImageToSize:CGSizeMake(MAIN_BOUNDS_SCREEN_WIDTH, 44)] forBarMetrics:UIBarMetricsDefault];
        //[navigationBar setBackgroundImage:[UIImage imageNamed:navBackImgName] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setNavigationBarTransparentWithAlpha:(float)alpha
{
    [self setNavigationBarColorWithUIColor:UIColorFromHexA(0xffffff, alpha)];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setNavigationBarColorWithUIColor:(UIColor *)color
{
    if (color != nil)
    {
        UIImage * image = [UIImage imageFromColor:color withFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, (IOS7_AND_LATER ? 64 : 44))];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationController.navigationBar.shadowImage = nil;
    //self.navigationController.navigationBar.translucent = NO;
}

- (void)setNavigationBarTintColorWithUIColor:(UIColor *)tintColor
{
    if (tintColor)
    {
        if (IOS7_AND_LATER)
        {
            [self.navigationController.navigationBar setBarTintColor:tintColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:tintColor];
        }
    }
}

- (void)setExtensionWithJudger:(BOOL)judger
{
    if (IOS7_AND_LATER)
    {
        if (judger)
        {
            self.edgesForExtendedLayout = UIRectEdgeAll;
        }
        else
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
}

- (void)setBottomNavigationBarWithLeftButtonImageName:(NSString *)imageName andSelector:(SEL)selector1 andRightButtonTittle:(NSString *)title andSelector:(SEL)selector2 andBarHeight:(float)height andBackgroundColor:(UIColor *)backgroundColor
{
    UIView * barBackView = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_BOUNDS_SCREEN_HEIGHT - height, MAIN_BOUNDS_SCREEN_WIDTH, height)];
    barBackView.backgroundColor = backgroundColor;
    
    [self.view addSubview:barBackView];
    
    UIButton * leftButton = [[UIButton alloc]initWithFrame:CGRectMake(20, height/2 - 10, 20, 20)];
    [leftButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [leftButton addTarget:self action:selector1 forControlEvents:UIControlEventTouchUpInside];
    leftButton.contentMode = UIViewContentModeScaleAspectFit;
    
    [barBackView addSubview:leftButton];
    
    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_BOUNDS_SCREEN_WIDTH - 70, 0, 60, height)];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitle:title forState:UIControlStateNormal];
    [rightButton addTarget:self action:selector2 forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [barBackView addSubview:rightButton];
}

#pragma mark -VC背景颜色
- (void)setBackgroundColor
{
    //    [self.view setBackgroundColor:UIColorFromHexA(0xDFDFDF, 1)];
    [self.view setBackgroundColor:WholeVCColorBg];
}

-(void)setViewControllerBackgroundImage:(NSString *)imageName {
    if (IOS7_AND_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    
    UIImage *image = [UIImage imageFromColor:UIColorFromHexA(0x000000, 0.0) withFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, IOS7_AND_LATER ? 64 : 44)];

    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    //self.navigationController.navigationBar.backgroundColor = UIColorFrom255RGBA(1.0, 1.0, 1.0, 0.0);
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBarHidden = NO;
    
//    UIImage *backImg = [UIImage imageNamed:imageName];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backImg]];
    if (IPHONE4_S) {
        imageName = [NSString stringWithFormat:@"%@_4s.jpg", imageName];
    } else {
        imageName = [NSString stringWithFormat:@"%@.jpg", imageName];
    }
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT)];
    bgImageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
}

- (void)setStatusBarStyleWith:(UIStatusBarStyle)style
{
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

- (void)cleanCurrenEditData
{
    //子类实现，退出后清理当前页面编辑的数据
}

- (void)setNoTabBarFrame
{
    CGRect myFrame = self.view.frame;
    myFrame.size.height = MAIN_BOUNDS_SCREEN_HEIGHT - myFrame.origin.y;
    [self.view setFrame:myFrame];
}

- (void)setButtonToolBarForLeftImage:(NSString *)image andSelector:(SEL)selector1 andRightButtonTitle:(NSString *)title andColor:(UIColor *)titleColor andSelector:(SEL)selector2 andBackgroundColor:(UIColor *)color
{
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:selector1];
    
    UIBarButtonItem* toolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * nextSetpItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStyleDone target:self action:selector2];
    [nextSetpItem setTintColor:titleColor];

    [self setToolbarItems:[NSArray arrayWithObjects:backItem,toolBarSpace,nextSetpItem, nil]];
//    self.navigationController.toolbar.barTintColor = color;
//    self.navigationController.toolbar.tintColor = [UIColor redColor];
    
    self.navigationController.navigationBarHidden = YES;
}

//TODO
- (void)showSimpleAlert:(NSString *)alertStr
{
    if (IOS8_AND_LATER)
    {
        //大于或等于IOS8的时候使用
        //NSString *message = NSLocalizedString(@"您尚未安装微信，请用微吃账号登录", nil);
        NSString *message = NSLocalizedString(alertStr, nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"好的", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the action.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // 取消后的操作
        }];
        
        // Add the action.
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        //小于IOS8的时候使用其他的Alert
        NSString *message = alertStr;
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertview show];
    }
}

- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message view:(UIView *)view otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle otherButtonBlock:(void (^)(id alert, NSString *title, NSUInteger index))otherButtonBlock cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock completionBlock:(void(^)())completionBlock
{
    //隐藏键盘
    [self.view endEditing:YES];
    
    //显示alert
    LGAlertView *alertView  = nil;
    if (view && [view isKindOfClass:[UIView class]])
    {
        alertView = [[LGAlertView alloc] initWithViewAndTitle:title message:message style:LGAlertViewStyleAlert view:view  buttonTitles:otherButtonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:okButtonTitle];
    }
    else
    {
        alertView = [[LGAlertView alloc] initWithTitle:title message:message style:LGAlertViewStyleAlert buttonTitles:otherButtonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:okButtonTitle];
    }
    
    //回调
    alertView.destructiveHandler = okBlock;
    alertView.cancelHandler = cancelBlock;
    alertView.actionHandler = otherButtonBlock;
    
    //颜色样式
    alertView.titleTextColor = NUI_HELPER.appDarkGrayColor;
   
    alertView.messageTextColor = NUI_HELPER.appLightGrayColor;
    
    alertView.destructiveButtonTitleColor = NUI_HELPER.appOrangeColor;
    alertView.destructiveButtonBackgroundColorHighlighted = NUI_HELPER.appOrangeColor;
    alertView.cancelButtonTitleColor = NUI_HELPER.appDarkGrayColor;
    alertView.cancelButtonBackgroundColorHighlighted = NUI_HELPER.appOrangeColor;

    //显示
    [alertView showAnimated:YES completionHandler:completionBlock];
    return alertView;
}

- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock
{
    return [self showLGAlertTitle:title message:message view:nil otherButtonTitles:nil cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle otherButtonBlock:nil cancelBlock:cancelBlock okBlock:okBlock completionBlock:nil];
}

- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message view:(UIView *)view cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock
{
    return [self showLGAlertTitle:title message:message view:view otherButtonTitles:nil cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle otherButtonBlock:nil cancelBlock:cancelBlock okBlock:okBlock completionBlock:nil];
}

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 *  @param okButtonTitle     确认操作按钮的title
 *  @param okBlock           确认的回调
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title okButtonTitle:(NSString *)okButtonTitle okBlock:(void (^)(id alert))okBlock
{
    return [self showLGAlertTitle:title message:nil view:nil otherButtonTitles:nil cancelButtonTitle:nil okButtonTitle:okButtonTitle otherButtonBlock:nil cancelBlock:nil okBlock:okBlock completionBlock:nil];
}

- (LGAlertView *)showLGAlertTitle:(NSString *)title okButtonTitle:(NSString *)okButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle okBlock:(void (^)(id alert))okBlock cancelBlock:(void (^)(id alert))cancelBlock
{
    return [self showLGAlertTitle:title message:nil view:nil otherButtonTitles:nil cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle otherButtonBlock:nil cancelBlock:cancelBlock okBlock:okBlock completionBlock:nil];
}

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title
{
    NSString *okTitle = @"确定";
    return [self showLGAlertTitle:title message:nil view:nil otherButtonTitles:nil cancelButtonTitle:nil okButtonTitle:okTitle otherButtonBlock:nil cancelBlock:nil okBlock:nil completionBlock:nil];
}

#pragma mark - UIScrollView上拉下拉刷新动画
/**
 *  @author semny
 *
 *  scroll view的顶部和底部刷新操作，
 *
 *  @param hRefreshAction 顶部刷新操作方法(nil的话无顶部动画)
 *  @param fRefreshAction 底部刷新操作方法(nil的话无底部动画)
 */
- (void)scrollView:(UIScrollView *)scrollView headerRefreshAction:(SEL)hRefreshAction footerRefreshAction:(SEL)fRefreshAction
{
    if (!scrollView || ![scrollView isKindOfClass:[UIScrollView class]])
    {
        //异常的scroll view
        return;
    }
    
    // 添加动画图片的下拉刷新
    __weak typeof(self) weakSelf = self;
    //如果不为nil无顶部加载动画
    if (hRefreshAction)
    {
        // 设置下拉刷新回调
        KSRefreshHeader *header = [KSRefreshHeader headerWithRefreshingBlock:^{
            if (weakSelf && [weakSelf respondsToSelector:hRefreshAction])
            {
                //[weakSelf performSelector:hRefreshAction];
                SuppressPerformSelectorLeakWarning([weakSelf performSelector:hRefreshAction] );
            }
        }];
        scrollView.mj_header = header;
    }
    
    //如果不为nil无底部加载动画
    if (fRefreshAction)
    {
        //设置上拉加载更多的回调
        KSRefreshFooter *footer = [KSRefreshFooter footerWithRefreshingBlock:^{
            if (weakSelf && [weakSelf respondsToSelector:fRefreshAction])
            {
                //[weakSelf performSelector:fRefreshAction];
                SuppressPerformSelectorLeakWarning([weakSelf performSelector:fRefreshAction] );
            }
        }];
        scrollView.mj_footer = footer;
    }
    
        // 设置正在刷新状态的动画图片
//        NSMutableArray *refreshingImages = [NSMutableArray array];
//        for (NSUInteger i = 1; i<=8; i++)
//        {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
//            [refreshingImages addObject:image];
//        }
//        //顶部刷新图片
//        [scrollView.mj_header setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
//    
//        //底部隐藏状态
//        scrollView.footer.stateHidden = YES;
//        [scrollView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
//        [scrollView.footer setTitle:@"" forState:MJRefreshFooterStateRefreshing];
//        [scrollView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
//        //底部刷新图片
//        [scrollView.gifFooter setRefreshingImages:refreshingImages];
}


@end
