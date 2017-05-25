

#import <Foundation/Foundation.h>


@interface NSString (Hashing)

- (NSString *)MD5Hash;

+(NSString*)fileMD5:(NSString*)path;

+(NSString*)dataMD5:(NSData*)data;
+(NSData *)dataMD5ToData:(NSData*)data;
@end
