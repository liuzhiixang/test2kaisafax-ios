//
//  JXTool.h
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"

#define selfViewHeight self.view.height
#define selfViewWidth self.view.width
#define sTabBarHeight self.tabBarController.tabBar.height
#define sNavBarHeight self.navigationController.navigationBar.height

#define kJXCachedAppKey @"kJXCachedAppKey"
#define JXGetSuitableImage(a) [JXTool getSuitableImageWithName:a]

@interface JXTool : NSObject

+ (NSString *)getDateStringFromTimeInterval:(NSTimeInterval)timeInterval;

+ (UIImage *)getSuitableImageWithName:(NSString *)name;

@end

@interface NSString (SimpleJson)

- (id)objectFromJsonString;

@end

typedef NS_ENUM(char, iPhoneType){//0~3
         iPhone4,//320*480
         iPhone5,//320*568
         iPhone6,//375*667
         iPhone6Plus,//414*736
         UnKnown
};

@interface UIDevice (Type)

+ (iPhoneType)getCurrentIPhoneType;

@end

@interface NSString (TextSize)

- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font;

@end
