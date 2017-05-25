//
//  JXEomtionEscape.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JXEmotionEscape : NSObject

+ (NSMutableAttributedString *)attributtedStringFromText:(NSString *)aInputText;

+ (NSAttributedString *)attStringFromTextForChatting:(NSString *)aInputText;

+ (NSAttributedString *)attStringFromTextForInputView:(NSString *)aInputText;

+ (NSMutableString *)mutableStringWithText:(NSString *)str;

+ (NSAttributedString *)attributedEmojiStringWithText:(NSString *)str;

+ (NSArray *)loadExpressions;

+ (NSArray *)loadDefaultEmoticon;

@end

@interface JXTextAttachment : NSTextAttachment

@property(nonatomic, strong) NSString *imageName;

@end
