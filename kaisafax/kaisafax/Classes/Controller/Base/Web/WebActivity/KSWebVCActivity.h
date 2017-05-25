
#import <UIKit/UIKit.h>

#ifndef KSNewWebVCLocalizedString
#define KSNewWebVCLocalizedString(key, comment) \
NSLocalizedStringFromTableInBundle(key, @"KSNewWebVC", [NSBundle bundleWithPath:[[[NSBundle bundleForClass:NSClassFromString(@"KSNewWebVC")] resourcePath] stringByAppendingPathComponent:@"KSNewWebVC.bundle"]], comment)
#endif

@interface KSWebVCActivity : UIActivity
/// URL to open.
@property (nonatomic, strong) NSURL *URL;
/// Scheme prefix value.
@property (nonatomic, strong) NSString *scheme;
@end
