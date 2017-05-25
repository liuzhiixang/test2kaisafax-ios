//
//  NSString+Format.h
//  
//
//  Created by MacbookPro-PC on 14-4-24.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *  @brief 增加格式化相关的扩展字符串类功能
 */
@interface NSString (Format)

/**
 *  @brief 过滤字符串的空串和换行
 *
 *  @return 过滤字符串的空串和换行后的新字符串
 */
- (NSString*)trim;

/**
 *  @brief 过滤字符串的空串
 *
 *  @return 过滤字符串的空串后的新字符串
 */
- (NSString*)replaceWithespaceCharacter;

/**
 *  @brief 过滤字符串的换行
 *
 *  @return 过滤字符串的换行后的新字符串
 */
- (NSString*)replaceNewLineCharacter;

/**
 * @brief 字符串分行处理的方法.
 *
 * @return 字符串处理后返回的每行字符串数据的数组.
 */
- (NSMutableArray*)enumerateLines;

/**
 *  @brief 判断字符串是不是只有空格和换行字符串
 *
 *  @return YES:只有空格和换行;NO:不全是空格和换行;
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 *  @brief 判断是不是为空串或者空格符
 *
 *  @return YES:是空串或者空格符；NO:不是空串或者空格符；
 */
- (BOOL)isEmptyOrWhitespace;

#pragma mark -
#pragma mark ----------------格式判断-------------------
///**
// *  @brief 判断是否为Email地址
// *
// *  @return YES:是Email地址；NO:不是；
// */
- (BOOL)isEmail;
//
///**
// *  @brief 判断是否为数字
// *
// *  @return YES:是数字；NO:不是；
// */
//- (BOOL)isNumeric;
//
///**
// *  @brief 判断是否为手机号码（主要判断是不是11位和是不是都是数字）
// *
// *  @return YES:是手机号码；NO:不是；
// */
//- (BOOL)isPhoneNumber;
//
//
///**
// *  判断是否6-12位且包括字母数字的密码
// *
// *  @return  YES, 有效, NO....
// */
//- (BOOL)isValidPassword;

//
///**
// *  @brief 比较严格的国内手机号格式判断
// *
// *  @return YES:是手机号码；NO:不是；
// */
//- (BOOL)isTelephone;
//
///**
// *  @brief 判断是不是url
// *
// *  @return YES:是URL地址；NO:不是；
// */
//- (BOOL)isUrl;


/**
 *  @brief 判断字符串是否合法
 *
 *  @return YES:合法字符串；NO:不合法字符串
 */
- (BOOL)isValid;

//手机号
+ (BOOL)checkIsPhoneNumber:(NSString *)phoneNumber range:(NSRange)range;

//密码
+ (BOOL)checkIsValidPassword:(NSString *)password range:(NSRange)range;

//验证码
+ (BOOL)checkIsVerifyCode:(NSString *)verifyCode range:(NSRange)range;


+ (BOOL)checkIfAlphaNumeric:(NSString *)string;
+ (BOOL)checkIfAlphaNumeric:(NSString *)string range:(NSRange)range;
+ (BOOL)checkIfAlphabetical:(NSString *)string;
+ (BOOL)checkIfEmailId:(NSString *)string;
+ (BOOL)checkNumeric:(NSString *)string;
+ (BOOL)checkNumeric:(NSString *)string range:(NSRange)range;
+ (BOOL)checkPostCodeUK:(NSString *)string;
+ (BOOL)checkIfURL:(NSString *)string;
+ (BOOL)checkIfShorthandURL:(NSString *)string;
+ (BOOL)checkIfInRange:(NSString *)string WithRange:(NSRange)_range;
+ (BOOL)checkIfChineseAlphaNumericUnderline:(NSString *)string range:(NSRange)range;
- (BOOL)containsString:(NSString *)string;
- (NSString *)stringBetweenString:(NSString *)start andString:(NSString*)end;

#pragma mark -
/**
 *  @size 文本内容所在的容器框尺寸
 *
 *  @font 文本内容的当前字体
 */
- (CGRect)getTextRectBoundingSize:(CGSize)size andFont:(UIFont *)font;

/**
 *  转换货币值 (由整型转换成字符串)
 *
 *  @param price 整形货币值，以分为单位
 *
 *  @return 格式化后的货币字符串值，精确到毛
 */
//+ (NSString*)convertPrice:(int32_t)price;

/**
 *  添加横线处理
 *
 *  @param srcStr 源字符串
 *
 *  @return 带有Underline的富文本
 */
+ (NSMutableAttributedString*)addUnderline:(NSString*)srcStr;

/**
 *  将数值型距离转换成对应的文本
 *
 *  @param distance 距离，以米为单位
 *
 */
+ (NSString*)convertDistance:(int32_t)distance;

/**
 *  将url字符串百分化
 *
 *  @param plusForSpace 是否加空格
 *
 */
-(NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace;

@end
