//
//  JXError+LocalDescription.h
//

#import "JXError.h"

@interface JXError (LocalDescription)

- (NSString *)getLocalDescription;

+ (NSString *)getLocalDescriptionForErrorType:(JXErrorType)error;

@end
