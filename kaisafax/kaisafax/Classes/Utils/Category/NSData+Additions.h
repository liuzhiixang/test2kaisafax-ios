
#import <Foundation/Foundation.h>

@interface NSData (Additions)

//加密
- (NSData*)AES256EncryptWithKey:(NSString*)key;
//解密
- (NSData*)AES256DecryptWithKey:(NSString*)key;

/**
 * Calculate the md5 hash of this data using CC_MD5.
 *
 * @return md5 hash of this data
 */
@property (nonatomic, readonly) NSString* md5Hash;

@end


@interface NSData (SnapAdditions)

- (short)rw_int16AtOffset:(size_t)offset;
- (char)rw_int8AtOffset:(size_t)offset;
- (int)rw_int32AtOffset:(size_t)offset;
- (long long)rw_int64AtOffset:(size_t)offset;
- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;

@end

@interface NSMutableData (SnapAdditions)

- (void)rw_appendInt64:(long long)value;
- (void)rw_appendInt32:(int)value;
- (void)rw_appendInt16:(short)value;
- (void)rw_appendInt8:(char)value;
- (void)rw_appendString:(NSString *)string;

@end
