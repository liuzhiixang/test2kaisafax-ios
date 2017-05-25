//
//  KSLaunchVC.m
//  kaisafax
//
//  Created by semny on 11/7/15.
//  Copyright © 2015 kaisafax. All rights reserved.
//

#import "KSLaunchVC.h"
#import "KSStatisticalMgr.h"

@interface KSLaunchVC ()

//黑色圆点视图
//@property (weak, nonatomic) IBOutlet UIImageView *blackCircleView;

//启动背景图
@property (nonatomic, retain) UIImageView *splashBGView;

@end

@implementation KSLaunchVC

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    //加载启动图
    if (!_splashBGView && self.view)
    {
        UIImage *bg = [self getSplashImage];
        
        //设置splash的背景图片大小为 屏幕尺寸大小
        _splashBGView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_splashBGView setImage:bg];
        [self.view addSubview:_splashBGView];
    }
    
    //开启定时器
    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:2.0f];
}

/**
 *  @author semny
 *
 *  隐藏启动页
 */
- (void)dismissSelf
{
    //发出启动的通知
    [NOTIFY_CENTER postNotificationName:KLaunchCompletedNotificationKey object:nil userInfo:nil];
    [self.view removeFromSuperview];
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

#pragma mark - 加载图片
- (UIImage *)getSplashImage
{
    UIImage *launchImage = nil;
    NSString *launchImageName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 480) launchImageName = @"LaunchImage-700@2x.png";//@"welcome_4s.png"; // iPhone 4/4s, 3.5 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 568) launchImageName = @"LaunchImage-700-568h@2x.png"; //@"welcome.png"; // iPhone 5/5s, 4.0 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 667) launchImageName = @"LaunchImage-800-667h@2x.png"; //@"welcome.png"; // iPhone 6, 4.7 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 736) launchImageName = @"LaunchImage-800-Portrait-736h@3x.png";//@"welcome.png"; // iPhone 6+, 5.5 inch screen
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIScreen mainScreen].scale == 1) launchImageName = @"LaunchImage-700-Portrait~ipad.png"; // iPad 2
        if ([UIScreen mainScreen].scale == 2) launchImageName = @"LaunchImage-700-Portrait@2x~ipad.png"; // Retina iPads
    }
    
    if (!launchImageName)
    {
        return nil;
    }
    
    launchImage = [UIImage imageNamed:launchImageName];
    return launchImage;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
- (BOOL)shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#endif

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)logoAnimation
{
//    [UIView beginAnimations:@"LogoIn" context:nil];
//    [UIView setAnimationDuration:2.0f];
//    [UIView setAnimationTransition:<#(UIViewAnimationTransition)#> forView:<#(nonnull UIView *)#> cache:<#(BOOL)#>];
//    
//    CGPoint oldPoint = self.blackCircleView.center;
//    CGFloat newX = oldPoint.x+5.6f;
//    CGFloat newY = oldPoint.y+5.6f;
//    CGPoint newPoint = CGPointMake(newX, newY);
//    self.blackCircleView.center = newPoint;
//    [UIView commitAnimations];
    [self doTranslateFor:self.splashBGView];
}

//位移
-(void)doTranslateFor:(UIView *)animationView
{
    CGFloat newX = 4.8f;
    CGFloat newY = -4.8f;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(newX, newY);
    [UIView animateWithDuration:0.5f animations:^{
        animationView.transform = transform;
    }];
}
@end
