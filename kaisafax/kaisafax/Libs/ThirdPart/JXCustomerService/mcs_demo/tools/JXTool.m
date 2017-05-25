//
//  JXTool.m
//

#import "JXTool.h"

@implementation JXTool

+ (NSString *)getDateStringFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDateFormatter *fommatter = [[NSDateFormatter alloc] init];
    [fommatter setDateFormat:@"MM月dd日 HH:mm"];
    return [fommatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}


+ (UIImage *)getSuitableImageWithName:(NSString *)name {
    NSString *imageName = nil;
    iPhoneType type = [UIDevice getCurrentIPhoneType];
    switch (type) {
        case iPhone5:
            imageName = [name stringByAppendingString:@"_5.png"];
            break;
        case iPhone6:
            imageName = [name stringByAppendingString:@"_6.png"];
            break;
        case iPhone6Plus:
            imageName = [name stringByAppendingString:@"_6p.png"];
            break;
        default:
            break;
    }
    UIImage *ret = JXImage(imageName);
    if (!ret) {
        ret= JXImage([name stringByAppendingString:@"_4.png"]);
    }
    return ret;
}

@end


@implementation NSString (SimpleJson)

- (id)objectFromJsonString {
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

@end

@implementation UIDevice (Type)

+ (iPhoneType)getCurrentIPhoneType {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    // get current interface Orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    // unknown
    if (UIInterfaceOrientationUnknown == orientation) {
        return UnKnown;
    }
    // portrait
    if (UIInterfaceOrientationPortrait == orientation) {
        if (width == 320.0f) {
            if (height == 480.0f) {
                return iPhone4;
            } else {
                return iPhone5;
            }
        } else if (width == 375.0f) {
            return iPhone6;
        } else if (width == 414.0f) {
            return iPhone6Plus;
        }
    } else if (UIInterfaceOrientationLandscapeLeft == orientation ||
               UIInterfaceOrientationLandscapeRight == orientation) {    // landscape
        if (height == 320.0) {
            if (width == 480.0f) {
                return iPhone4;
            } else {
                return iPhone5;
            }
        } else if (height == 375.0f) {
            return iPhone6;
        } else if (height == 414.0f) {
            return iPhone6Plus;
        }
    }

    return UnKnown;
}

@end

@implementation NSString (TextSize)

- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes =
            @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy};
    expectedLabelSize = [self boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil]
                                .size;
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

@end
