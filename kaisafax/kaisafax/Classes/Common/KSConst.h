//
//  KSConst.h
//  kaisafax
//
//  Created by SemnyQu on 14/10/22.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#ifndef kaisafax_KSConst_h
#define kaisafax_KSConst_h

//安全release ptr对象
#if ! __has_feature(objc_arc)
#define RELEASE_SAFE(ptr) { if(ptr != nil){[ptr release]; ptr = nil;} }
#else
#define RELEASE_SAFE(ptr) {}
#endif

//系统版本
#define SystemVersion ([UIDevice currentDevice].systemVersion.floatValue)
#define IOS5_AND_LATER (SystemVersion >= 5.0)
#define IOS6_AND_LATER (SystemVersion >= 6.0)
#define IOS7_AND_LATER (SystemVersion >= 7.0)
#define IOS8_AND_LATER (SystemVersion >= 8.0)
#define IOS9_AND_LATER (SystemVersion >= 9.0)
#define IOS10_AND_LATER (SystemVersion >= 10.0)


#define IPHONE4_S ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define TabBarHeight 49.0f
#define NavigationBarHeight 44.0f
#define StatusBarHeight 20.0f
#define navBarHeight   (NavigationBarHeight+StatusBarHeight)
#define NavigationBarTitleViewLRSpace 8.0f

//APP相关的主要属性
#define APP             [UIApplication sharedApplication]
#define APP_DELEGATE    (AppDelegate *)[APP delegate]
#define USER_DEFAULT    [NSUserDefaults standardUserDefaults]
#define KEY_WINDOW      [APP keyWindow]
#define NOTIFY_CENTER   [NSNotificationCenter defaultCenter]
#define MAIN_BOUNDS     [UIScreen mainScreen].bounds
#define MAIN_BOUNDS_SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define MAIN_BOUNDS_SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define isIPhone5x      (MAIN_BOUNDS_SCREEN_HEIGHT == 568)
#define isIPhone6x      (MAIN_BOUNDS_SCREEN_HEIGHT == 667)
#define isIPhone6xp      (MAIN_BOUNDS_SCREEN_HEIGHT == 736)

#pragma mark - Color
#define UIColorFromHexA(hexValue, a)     [UIColor colorWithRed:(((hexValue & 0xFF0000) >> 16))/255.0f green:(((hexValue & 0xFF00) >> 8))/255.0f blue:((hexValue & 0xFF))/255.0f alpha:a]
#define UIColorFromHex(hexValue)        UIColorFromHexA(hexValue, 1.0f)

#define UIColorFrom255RGBA(r, g, b, a)  ([UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a])

#define UIColorFrom255RGB(r, g, b)      UIColorFrom255RGBA(r,g,b,1.0f)

////佳兆业黄色
//#define UIColorKaisaYellow UIColorFromHex(0xee7700)
////app的常用颜色(主标题)
//#define UIColorMainTitle UIColorFromHex(0x4c4c4e)
////（副标题）
//#define UIColorMinorTitle UIColorFromHex(0xa0a0a0)


#define ViewFromNib(name,index) [[[UINib nibWithNibName:name bundle:nil] instantiateWithOwner:self options:nil] objectAtIndex:index]
#define PathForPlist(name)  [[NSBundle mainBundle]pathForResource:name ofType:@"plist"]

#define kRegisterCellNib(tableView,cellName)  [tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
#define kString2Dot(x)  [NSString stringWithFormat:@"%.2f",x]
#define kRedPacketTypeArray  (@[[NSNumber numberWithInt:KSNotActive],[NSNumber numberWithInt:KSAlreadyPlayed|KSTypeEqualPrincipal|KSAlreadyExtracted],[NSNumber numberWithInt:KSExpired]])


#define ClearColor [UIColor clearColor]
#define WhiteColor [UIColor whiteColor]
#define BlackColor [UIColor blackColor]
#define RedColor   [UIColor redColor]
#define GreenColor [UIColor greenColor]

//系统默认的
#define SYSFONT(x) [UIFont systemFontOfSize:x]
#define SYSBFONT(x) [UIFont boldSystemFontOfSize:x]

//兰亭字体
//#define FONT(x) [UIFont systemFZLTZHKFontOfSize:x]
//#define BFONT(x) [UIFont boldSystemFZLTZHKFontOfSize:x]

#define UIImageFromName(x) [UIImage imageNamed:x]

#define SCREEN_SCALE        [UIScreen mainScreen].scale

#define SW(w)               ((w)*MAIN_BOUNDS_SCREEN_WIDTH/640.0f)
#define SH(h)               ((h)*MAIN_BOUNDS_SCREEN_HEIGHT/1136.0f)

#define pix(x)  (x)*MAIN_BOUNDS_SCREEN_WIDTH/375.0
#define piy(y)  y*ScreenHeight/667.0
#define StandScreenWidth    375
#define StandScreenHeight   667
//#define RGBColor(r,g,b)     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
//#define RGBAColor(r,g,b,a)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]
//#define RGBColorC(c)        RGBColor((((int)c) >> 16),((((int)c) >> 8) & 0xff),(((int)c) & 0xff))

//加载图片宏
#define LoadImage(ptr) (ptr?[UIImage imageNamed:ptr]:nil)

//Tab点击两次的通知
#define kTabBarDoubleTapNotifyName @"TabbarItemDoubleClick"

#define KReachabilityChangedNotification @"KNetworkReachabilityChangedNotification"

//随机数
#define RandomNumber(f, t)  ((NSInteger)(f + (random() % (t - f + 1))))

//代理安全判断
#define SecureDelegateMethodJudger(delegate,method) delegate != nil && [delegate respondsToSelector:@selector(method)]

//Table插入数据方法
#define InsertArrayToTableWithInsertArrAndSourceArr(table,insertArr,sourceArr,section) \
        NSMutableArray * insertIndexArr = [NSMutableArray array]; \
        int oldCount = sourceArr.count; \
        for (id entity in insertArr) {  \
            [sourceArr addObject:entity]; \
            int index = [insertArr indexOfObject:entity] + oldCount; \
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:section]; \
            [insertIndexArr addObject:indexPath]; \
        } \
            \
        [table insertRowsAtIndexPaths:insertIndexArr withRowAnimation:UITableViewRowAnimationMiddle]; \

//内存窗口测试开关(1开/0关)
#define _MONITOR_MEMORY_    0

//测试数据开关  1 - 开 ，0 - 关
#define TestDataSwitch 0

#define WeakObj(o) autoreleasepool{} __weak typeof(o) weak##o = o
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = weak##o

//APP的主题橙色
//#define APPOrangeColor          UIColorFromHex(0xee7700)

#define AMOUNT_MAX_VALUE 1000000000



#pragma mark - 业务公共参数
//登录密码的长度
#define KPasswordMinLength                6
#define KPasswordMaxLength                16
//手机号的长度
#define KPhoneNumberLength                11
//验证码的长度
#define KVerifyCodeLength                  6
//用户名长度（由于历史版本存在任何可能性的字符，不能限制长度了）
#define KUserNameMinLength                4
#define KUserNameMaxLength                16

//个人中心相关字符长度限制
#define KPostCodeMaxLength                6
#define KPersonalNameMaxLength            10
#define KDetailAddrMaxLength              64

//wmpagecontroller的头部标题高度
#define KWMPageTitleHeight                44.0

//消除隐式调用selector的警告
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark -----公共类型-------------
//充值类型
typedef NS_ENUM(NSUInteger,KSRechargeType)
{
    KSRechargeTypeNormal=3,     //普通充值
    KSRechargeTypeBalance=4,    //差额充值
    KSRechargeTypeOther=5,      //另外的充值
};

typedef NS_ENUM(NSUInteger,KSWebSourceType)
{
    KSWebSourceTypeRegister=0,     //从注册入口来的
    KSWebSourceTypeAccount=1,      //从账户中心来的
    KSWebSourceTypeInvestDetail=2,  //从投资详情来的
    KSWebSourceTypeHome=3,          //从首页来的
    KSWebSourceTypeADStart=4,            //从启动广告来的
    KSWebSourceTypeADAfterCheck=5,       //检测安全后的启动
    KSWebSourceTypeAutoLoan=6,            //从自动投标来的
    KSWebSourceTypeAutoLoanSetting=7,       //从自动投标设置来的
//    KSWebSourceTypeOther=4,         //其他情况 从账户中心来的
};
//充值类型
typedef NS_ENUM(NSUInteger,KSRedPackageType)
{
    CASH=0,    //0:CASH-现金券
    REDBAG=1,     //1: REDBAG-红包
};

typedef NS_ENUM(NSUInteger, KSRedPackageStats) {
    KSNotActive = 1<<1, //2
    KSAlreadyExtracted = 1<<2, //4
    KSPartialUse = 1<<3, //8
    KSTypeEqualPrincipal = 1<<4, //16
    
    KSAlreadyPlayed = 1<<5, //32
    KSExpired = 1<<7, //128
};
#endif

