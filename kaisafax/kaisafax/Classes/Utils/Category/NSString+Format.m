//
//  NSString+Format.m
//  
//
//  Created by MacbookPro-PC on 14-4-24.
//
//

#import "NSString+Format.h"

//匹配手机的正则
#define REGEX_MOBILE(max)           [NSString stringWithFormat:@"^1[34578]\\d{%lu}$", max]
//#define MAX_LENGTH_MOBILE           11

//至少6-16位且包括字母,数字,字符中的两种
//#define REGEX_PASSWORD(min,max)   [NSString stringWithFormat:@"(?=.*?\\d)(?=.*?[A-Za-z])[0-9A-Za-z]{%lu,%lu}", min, max]
//特殊字符
//#define REGEX_SPECIAL_STRING   @"?=.*?" //老版本
#define REGEX_SPECIAL_STRING   @"[-=\\\[\\];',./~!@#\\$%^&*\\(\\)_+|{}:\"<>?]+"

////
//至少6-16位且包括字母,数字,字符中的两种
#define REGEX_PASSWORD(min,max)   [NSString stringWithFormat:@"^(%@\\d)(%@[A-Za-z])[0-9A-Za-z]{%lu,%lu}$"/*,REGEX_SPECIAL_STRING*/,REGEX_SPECIAL_STRING,REGEX_SPECIAL_STRING, min, max]

//#define MAX_LENGTH_PASSWORD         16
//#define MIN_LENGTH_PASSWORD         6

//至少6-16位且包括字母数字
#define REGEX_VERIFY_CODE(max)          [NSString stringWithFormat:@"\\d{%lu}", max]
//#define MAX_LENGTH_VERIFY_CODE          6

@implementation NSString (Format)

- (NSString*)trim
{
    NSCharacterSet *whiteAndNewLineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:whiteAndNewLineSet];
    return trimmed;
}

- (NSString*)replaceWithespaceCharacter
{
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:whitespaceSet];
    return trimmed;
}

- (NSString*)replaceNewLineCharacter
{
    NSCharacterSet *newlineSet = [NSCharacterSet newlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:newlineSet];
    return trimmed;
}

- (NSMutableArray *)enumerateLines
{
    NSMutableArray *altitudes = [NSMutableArray array];
    [self enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) {
        float value = [line floatValue];
        [altitudes addObject: [NSNumber numberWithFloat: value]];
    }];
    return altitudes;
}

- (BOOL)isWhitespaceAndNewlines
{
	NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![whitespace characterIsMember:c]) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)isEmptyOrWhitespace
{
	return !self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (CGRect)getTextRectBoundingSize:(CGSize)size andFont:(UIFont *)font
{
    if (self.length <= 0 || !font || size.width<= 0 || size.height <= 0)
    {
        return CGRectZero;
    }
    
    CGSize boundingSize = size;
    NSDictionary * dic = @{NSFontAttributeName:font};
    
    CGRect rect = [self boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:dic context:nil];
    return rect;
}

/**
 *  添加横线处理
 *
 *  @param srcStr 源字符串
 *
 *  @return 带有Underline的富文本
 */
+ (NSMutableAttributedString*)addUnderline:(NSString*)srcStr
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:srcStr];
    [attrStr addAttributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]} range:NSMakeRange(0, attrStr.length)];
    return attrStr;
}

/**
 *  将数值型距离转换成对应的文本
 *
 *  @param distance 距离，以米为单位
 *
 */
+ (NSString*)convertDistance:(int32_t)distance
{
    NSString *distanceStr = nil;
    if (distance < 1000) {
        distanceStr = [NSString stringWithFormat:@"%dm", distance];
    } else {
        //整数部分
        int32_t kmInt = distance / 1000;
        //小数部分
        int32_t decimals = distance % 1000 / 100;
        distanceStr = [NSString stringWithFormat:@"%d.%dkm", kmInt, decimals];
    }
    return distanceStr;
}

#pragma mark -
#pragma mark ----------------格式判断-------------------
- (BOOL) isEmail
{
    
//    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$";
    NSString *emailRegex = @"^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
    
}
//
//- (BOOL)isNumeric
//{
//    NSString *tmpStr = [self trim];
//    if ([tmpStr length] ==0)
//    {
//        return NO;
//    }
//    for (int i=0; i<[tmpStr length]; i++)
//    {
//        unichar c = [tmpStr characterAtIndex:i];
//        
//        if (c < '0' || c > '9')
//        {
//            return NO;
//        }
//    }
//    return YES;
//}
//
//- (BOOL)isPhoneNumber
//{
//    if (self.length == 11)
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_MOBILE];
//        if ([predicate evaluateWithObject:self]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//
//- (BOOL)isValidPassword
//{
//    if (self.length > 6 && self.length <= 12)
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_PASSWORD];
//        if ([predicate evaluateWithObject:self]) {
//            return YES;
//        }
//    }
//    return NO;
//}

+ (BOOL)checkIsPhoneNumber:(NSString *)phoneNumber range:(NSRange)range
{
    if (!phoneNumber)
    {
        return NO;
    }
    
    NSUInteger length = range.length;
    if (phoneNumber.length == length)
    {
        NSUInteger max = length - 2;
        //[NSString stringWithFormat:@"^1[34578]\\d{%d}$", max];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_MOBILE(max)];
        if ([predicate evaluateWithObject:phoneNumber]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkIsValidPassword:(NSString *)password range:(NSRange)range
{
    if (!password)
    {
        return NO;
    }
    
    NSUInteger start = range.location;
    NSUInteger end = range.length;
    if (password.length >= start && password.length <= end)
    {
//        NSString *regexStr = REGEX_PASSWORD(start,end);
        
        //字母 数字 特殊
        NSString *regexStr1 = @"(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?])[a-zA-Z0-9-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]";
        NSString *passWordRegex1 = [NSString stringWithFormat: @"^%@{%lu,%lu}$",regexStr1, start, end];
        //字母 数字
        NSString *regexStr2 = @"(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]";
        NSString *passWordRegex2 = [NSString stringWithFormat: @"^%@{%lu,%lu}$",regexStr2, start, end];
        //字母 特殊
        NSString *regexStr3 = @"(?=.*[a-zA-Z])(?=.*[-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?])[a-zA-Z-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]";
        NSString *passWordRegex3 = [NSString stringWithFormat: @"^%@{%lu,%lu}$",regexStr3, start, end];
        //数字 特殊
        NSString *regexStr5 = @"(?=.*[0-9])(?=.*[-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?])[0-9-=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]";
        NSString *passWordRegex5 = [NSString stringWithFormat: @"^%@{%lu,%lu}$",regexStr5, start, end];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex1];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex2];
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex3];
        NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex5];
        if ([predicate1 evaluateWithObject:password] || [predicate2 evaluateWithObject:password] || [predicate3 evaluateWithObject:password] || [predicate5 evaluateWithObject:password])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)validatePassword:(NSString *)password
{
    // 特殊字符包含`、-、=、\、[、]、;、'、,、.、/、~、!、@、#、$、%、^、&、*、(、)、_、+、|、?、>、<、"、:、{、}
    // 必须包含数字和字母，可以包含上述特殊字符。
    // 依次为（如果包含特殊字符）
    // 数字 字母 特殊
    // 字母 数字 特殊
    // 数字 特殊 字母
    // 字母 特殊 数字
    // 特殊 数字 字母
    // 特殊 字母 数字
    NSString *passWordRegex = @"(\\d+[a-zA-Z]+[-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*)|([a-zA-Z]+\\d+[-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*)|(\\d+[-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*[a-zA-Z]+)|([a-zA-Z]+[-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*\\d+)|([-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*\\d+[a-zA-Z]+)|([-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]*[a-zA-Z]+\\d+)";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex];
    return [passWordPredicate evaluateWithObject:password];
}

+ (BOOL)checkIsVerifyCode:(NSString *)verifyCode range:(NSRange)range
{
    if (!verifyCode)
    {
        return NO;
    }
    
    NSUInteger length = range.length;
    if (verifyCode.length == length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_VERIFY_CODE(length)];
        if ([predicate evaluateWithObject:verifyCode]) {
            return YES;
        }
    }
    return NO;
}

//
//- (BOOL)isUrl
//{
//    NSString *		regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
//	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//	
//	return [pred evaluateWithObject:self];
//}
//
//- (BOOL)isTelephone
//{
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
//    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
//    
//    return  [regextestmobile evaluateWithObject:self]   ||
//    [regextestphs evaluateWithObject:self]      ||
//    [regextestct evaluateWithObject:self]       ||
//    [regextestcu evaluateWithObject:self]       ||
//    [regextestcm evaluateWithObject:self];
//}
//
//判断字符串是否合法
- (BOOL)isValid{
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkIfAlphabetical:(NSString *)string
{
    if (string == nil)
        return NO;
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == string.length;
}

+ (BOOL)checkIfAlphaNumeric:(NSString *)string
{
    if (string == nil)
        return NO;
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == string.length;
}

+ (BOOL)checkIfAlphaNumeric:(NSString *)string range:(NSRange)range
{
    if (string == nil)
        return NO;
    
    //    NSError *error             = NULL;
    //    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:0 error:&error];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSError *error             = NULL;
    NSString *regexString      = [NSString stringWithFormat:@"^[a-zA-Z0-9]{%lu,%lu}$", (unsigned long)range.location, (unsigned long)range.length];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSLog(@"match number:%lu, orginal number:%lu", (unsigned long)numberOfMatches, (unsigned long)string.length);
    return numberOfMatches > 0;
}

+ (BOOL)checkIfEmailId:(NSString *)string
{
    if (string == nil)
        string = [NSString string];
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == 1;
}

+ (BOOL)checkNumeric:(NSString *)string
{
    if (string == nil)
        return NO;
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == string.length;
}

+ (BOOL)checkNumeric:(NSString *)string range:(NSRange)range
{
    if (string == nil)
        return NO;
    
    NSError *error             = NULL;
    
    NSString *regexString      = [NSString stringWithFormat:@"^[0-9]{%lu,%lu}$", (unsigned long)range.location, (unsigned long)range.length];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches > 0;
}

+ (BOOL)checkPostCodeUK:(NSString *)string
{
    if (string == nil)
        string = @"";
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\\ 0[Aa][Aa])|([Ss][Aa][Nn]\\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\\ {0,1}([Cc]\\/[Oo]\\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\\ {0,1}1[Zz][Zz]))$" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return numberOfMatches     == 1;
}

+ (BOOL)checkIfInRange:(NSString *)string WithRange:(NSRange)_range
{
    if (_range.location == 0
        && _range.length == 0)
        return YES;
    
    if (string == nil)
        string = [NSString string];
    
    NSError *error             = NULL;
    NSString *regexString      = [NSString stringWithFormat:@"^.{%lu,%lu}$", (unsigned long)_range.location, (unsigned long)_range.length];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == 1;
}

+ (BOOL)checkIfURL:(NSString *)string
{
    if (string == nil)
    {
        return NO;
    }
    
    NSDataDetector *detector         = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult *firstMatch = [detector firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return [firstMatch.URL isKindOfClass:[NSURL class]]
    && ![firstMatch.URL.scheme isEqualToString:@"mailto"]
    && ![firstMatch.URL.scheme isEqualToString:@"ftp"];
}

+ (BOOL)checkIfShorthandURL:(NSString *)string
{
    if (string == nil)
    {
        return NO;
    }
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^((https?)://)?[a-z0-9-]+(\\.[a-z0-9-]+)+([/?].*)?$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return numberOfMatches     == 1;
}

+ (BOOL)checkIfChineseAlphaNumericUnderline:(NSString *)string range:(NSRange)range {
    if (string == nil)
        return NO;
    
    NSError *error             = NULL;
    NSString *regexString      = [NSString stringWithFormat:@"^[0-9A-Za-z_\u4e00-\u9fa5]{%lu,%lu}$", (unsigned long)range.location, (unsigned long)range.length];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSLog(@"match number:%lu, orginal number:%lu", (unsigned long)numberOfMatches, (unsigned long)string.length);
    return numberOfMatches > 0;
}

- (BOOL)containsString:(NSString *)string
{
    
    return [self rangeOfString:string].location == NSNotFound ? NO : YES;
    
}

- (NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end
{
    
    NSRange startRange       = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length   = [self length] - targetRange.location;
        NSRange endRange     = [self rangeOfString:end options:0 range:targetRange];
        
        if (endRange.location != NSNotFound) {
            
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}

-(NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace
{
    NSString *unreserved = @"*-._";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet                                     alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    if (plusForSpace) {
        [allowed addCharactersInString:@" "];
    }
    NSString *encoded = [self stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    if (plusForSpace) {
        encoded = [encoded stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    return encoded;
}
@end
