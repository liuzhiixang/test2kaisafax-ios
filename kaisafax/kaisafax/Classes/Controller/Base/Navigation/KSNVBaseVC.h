//
//  KSNVBaseVC.h
//  kaisafax
//
//  Created by SemnyQu on 14/10/25.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Util.h"
#import "UIView+Toast.h"
#import "UIBarButtonItem+Badge.h"
#import "MBProgressHUD.h"
#import "NSString+Format.h"
#import "UINavigationBar+Additions.h"
#import <MJRefresh/MJRefresh.h>
#import "KSRefreshFooter.h"
#import "KSRefreshHeader.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "KSUserMgr.h"

#pragma mark -
#pragma mark the navgation button type
#define kNavLeftButtonTag 1101
#define kNavRightButtonTag 1102
#define kNavBackButtonTag 1103

#pragma mark -
#pragma mark the navgation title show style
#define kNavTitleImageStyle 1
#define kNavTitleTextStyle 2

#pragma mark -
#pragma mark the navgation button size
#define kNavButtonWidth 75
#define kNavButtonHeight 25

//VC所有标题的字体样式
#define WholeVCTitleFont            SYSFONT(15.0f)
//页面背景色
#define WholeVCColorBg             UIColorFromHex(0xEBEBEB)

@interface KSNVBaseVC : UIViewController
//{
//    UIButton *navLeftBtn;
//    UIButton *navRightBtn;
//}

@property (nonatomic,assign) BOOL     isHUDShowing;
//是否隐藏导航栏的返回按钮
@property (nonatomic, assign) BOOL shouldShowLeftNavBtn;
//是否显示导航栏
@property (nonatomic, assign) BOOL needShowNavBar;

//VC是否显示的标记
@property (nonatomic, assign) BOOL isAppear;

@property (nonatomic, assign) BOOL isWillAppear;

//统计用的页面名称
@property (nonatomic, copy, readonly) NSString *pageName;
/**
 *  @author semny
 *
 *  是否透明navbar
 *
 *  @return YES:透明，NO：不透明
 */
- (BOOL)transparentNavigationBar;

//设置当前view的满填充
- (void)setFillContentView;

#pragma mark - HUD
- (void)showProgressHUD;
- (void)hideProgressHUD;
- (void)showFailedHUDWithStr:(NSString *)str;
- (void)showSuccessHUDWithStr:(NSString *)str;
- (void)showOperationHUDWithStr:(NSString *)str;
- (void)showOperationHUDToJumpWithStr:(NSString *)str completion:(void(^)(void))completion;

- (void)showProgressHUDInView:(UIView*)aView;
- (void)hideProgressHUDInView:(UIView*)aView;

/**
 *  显示toast信息
 *
 *  @param view  显示toast信息的父视图
 *  @param title 描述信息
 */
- (void)showToastWithView:(UIView *)view title:(NSString *)title position:(NSString*)position;

- (void)showToastWithView:(UIView *)view title:(NSString *)title;
- (void)showToastWithTitle:(NSString *)title;
- (void)showToastWithTitle:(NSString *)title position:(NSString*)position;
//- (void)showToastWithView:(UIView *)view title:(NSString *)title hideCallBack:(hideCallBack)hideCallBack;

#pragma mark -
#pragma mark These three functions used before using the super - (void)viewDidLoad to init the child view
// LeftButton
-(void)setNavLeftButtonByImage:(NSString *) leftBtnImgName
             selectedImageName:(NSString *)leftBtnSImageName
                  navBtnAction:(SEL) btnAction;

-(void)setNavLeftButtonByImage:(NSString *) leftBtnImgName
             selectedImageName:(NSString *)leftBtnSImageName;

-(void)setNavLeftButtonByText:(NSString *)btnName
                   titleColor:(UIColor *)titleColor
                    imageName:(NSString *)leftBtnImgName
            selectedImageName:(NSString *)leftBtnSImageName
                 navBtnAction:(SEL) btnAction;

-(void)setNavLeftButton:(UIButton *)lBtn;

// RightButton
-(void)setNavRightButtonByImage:(NSString *) rightBtnImgName
              selectedImageName:(NSString *)rightBtnSImageName
                   navBtnAction:(SEL) btnAction;

-(void)setNavRightButtonByText:(NSString *)btnName
                    titleColor:(UIColor *)titleColor
                     imageName:(NSString *)rightBtnImgName
             selectedImageName:(NSString *)rightBtnSImageName
                  navBtnAction:(SEL) btnAction;

-(void)setNavRightButton:(UIButton *)rBtn;

// NavShow
-(void)setNavShow:(NSInteger) navTitleShowStyle titleImageName:(NSString *) currentTitleImageName titleText:(NSString *) currentTitleText;

-(void)setNavShow:(NSInteger) navTitleShowStyle titleImageName:(NSString *) currentTitleImageName titleText:(NSString *) currentTitleText leftButton:(NSString *)currentLBtnImgName leftButtonSelected:(NSString *)currentLBtnSelectedImgName;

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
   leftButtonName:(NSString *) currentLBtnName
       leftButton:(NSString *)currentLBtnImgName
leftButtonSelected:(NSString *)currentLBtnSelectedImgName;

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
  rightButtonName:(NSString *) currentRBtnName
      rightButton:(NSString *)currentRBtnImgName
rightButtonSelected:(NSString *)currentRBtnSelectedImgName;

-(void)setNavShow:(NSInteger) navTitleShowStyle titleImageName:(NSString *) currentTitleImageName titleText:(NSString *) currentTitleText leftButton:(NSString *)currentLBtnImgName leftButtonSelected:(NSString *)currentLBtnSelectedImgName rightButton:(NSString *)currentRBtnImgName rightButtonSelected:(NSString *)currentRBtnSelectedImgName;

-(void)setNavShow:(NSInteger) navTitleShowStyle
   titleImageName:(NSString *) currentTitleImageName
        titleText:(NSString *) currentTitleText
   leftButtonName:(NSString *) currentLBtnName
       leftButton:(NSString *)currentLBtnImgName
leftButtonSelected:(NSString *)currentLBtnSelectedImgName
  rightButtonName:(NSString *) currentRBtnName
      rightButton:(NSString *)currentRBtnImgName
rightButtonSelected:(NSString *)currentRBtnSelectedImgName;

-(void)setNavShowDefaultLeft:(NSInteger) navTitleShowStyle titleImageName:(NSString *) currentTitleImageName titleText:(NSString *) currentTitleText;

// NavTitle
-(void)setNavTitleByImage:(NSString *) titleImageName;
-(void)setNavTitleByText:(NSString *)titleText;
-(void)setNavTitleByText:(NSString *)titleText withColor:(UIColor *)color;
-(void)setNavTitleByView:(UIView *) view;
-(void)setNavTitleTextAttributss:(NSDictionary *)titleAttributes;

// NavigationBarColor
-(void)setNavBarBackgroundImage:(UINavigationBar *)navCTL navBackImgName:(NSString *)navBackImgName;
//-(void)setNavBackgroundImage2:(UINavigationBar *)navigationBar navBackImgName:(NSString *)navBackImgName;
- (void)setNavigationBarTintColorWithUIColor:(UIColor *)tintColor;
- (void)setNavigationBarColorWithUIColor:(UIColor *)color;
- (void)setNavigationBarTransparentWithAlpha:(float)alpha;

// Others
- (void)setBackgroundColor;
- (void)setViewControllerBackgroundImage:(NSString *)imageName;
- (void)setExtensionWithJudger:(BOOL)judger;
- (void)setStatusBarStyleWith:(UIStatusBarStyle)style;

//发帖模块清空缓存内容接口
- (void)cleanCurrenEditData;

- (void)setNoTabBarFrame;



/**
 *  设置下bar
 *
 *  @param imageName       左边按钮的背景图名称
 *  @param selector1       左边按钮响应事件
 *  @param title           右边按钮title
 *  @param selector2       右边按钮响应事件
 *  @param height          下bar高
 *  @param backgroundColor 下bar背景色
 */
- (void)setBottomNavigationBarWithLeftButtonImageName:(NSString *)imageName andSelector:(SEL)selector1 andRightButtonTittle:(NSString *)title andSelector:(SEL)selector2 andBarHeight:(float)height andBackgroundColor:(UIColor *)backgroundColor;

/**
 *  设置下toolbar
 */
- (void)setButtonToolBarForLeftImage:(NSString *)image andSelector:(SEL)selector1 andRightButtonTitle:(NSString *)title andColor:(UIColor *)titleColor andSelector:(SEL)selector2 andBackgroundColor:(UIColor *)color;

#pragma mark - Alert
/**
 *  显示提示框
 *
 *  @param alertStr 提示信息
 */
- (void)showSimpleAlert:(NSString *)alertStr;

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 *  @param message           信息
 *  @param view              自定义信息视图
 *  @param otherButtonTitles 其他操作按钮的title
 *  @param cancelButtonTitle 取消操作按钮的title
 *  @param okButtonTitle     确认操作按钮的title
 *  @param otherButtonBlock  其他操作按钮的回调
 *  @param cancelBlock       取消的回调
 *  @param okBlock           确认的回调
 *  @param completionBlock   显示完成的回调
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message view:(UIView *)view otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle otherButtonBlock:(void (^)(id alert, NSString *title, NSUInteger index))otherButtonBlock cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock completionBlock:(void(^)())completionBlock;

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 *  @param message           信息
 *  @param cancelButtonTitle 取消操作按钮的title
 *  @param okButtonTitle     确认操作按钮的title
 *  @param cancelBlock       取消的回调
 *  @param okBlock           确认的回调
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock;

- (LGAlertView *)showLGAlertTitle:(NSString *)title message:(NSString *)message view:(UIView *)view cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle cancelBlock:(void (^)(id alert))cancelBlock okBlock:(void (^)(id alert))okBlock;

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 *  @param okButtonTitle     确认操作按钮的title
 *  @param okBlock           确认的回调
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title okButtonTitle:(NSString *)okButtonTitle okBlock:(void (^)(id alert))okBlock;
- (LGAlertView *)showLGAlertTitle:(NSString *)title okButtonTitle:(NSString *)okButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle okBlock:(void (^)(id alert))okBlock cancelBlock:(void (^)(id alert))cancelBlock;

/**
 *  @author semny
 *
 *  显示自定义的alert
 *
 *  @param title             标题
 */
- (LGAlertView *)showLGAlertTitle:(NSString *)title;

#pragma mark - 
/**
 *  @author semny
 *
 *  左边按钮的操作
 *
 *  @param sender 按钮
 */
- (void)leftButtonAction:(id)sender;

#pragma mark - UIScrollView上拉下拉刷新动画
/**
 *  @author semny
 *
 *  scroll view的顶部和底部刷新操作，
 *
 *  @param hRefreshAction 顶部刷新操作方法(nil的话无顶部动画)
 *  @param fRefreshAction 底部刷新操作方法(nil的话无底部动画)
 */
- (void)scrollView:(UIScrollView *)scrollView headerRefreshAction:(SEL)hRefreshAction footerRefreshAction:(SEL)fRefreshAction;
@end
