

#import "KSWebVCActivitySafari.h"

@implementation KSWebVCActivitySafari
- (NSString *)activityTitle {
    return KSNewWebVCLocalizedString(@"OpenInSafari", @"Open in Safari");
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    return NO;
}

- (void)performActivity {
    BOOL completed = [[UIApplication sharedApplication] openURL:self.URL];
    [self activityDidFinish:completed];
}
@end
