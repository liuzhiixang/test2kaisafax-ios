
#import "NSData+Additions.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

//自定义64长整形字节序转义方法
#define lhtonll(x) __DARWIN_OSSwapInt64(x)
#define lntohll(x) __DARWIN_OSSwapInt64(x)

@implementation NSData (Additions)

- (NSData*)AES256EncryptWithKey:(NSString*)key 
{ 
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise 
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused) 
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding) 
    
    // fetch key data 
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding]; 
    
    NSUInteger dataLength = [self length]; 
    
    //See the doc: For block ciphers, the output size will always be less than or 
    //equal to the input size plus the size of one block. 
    //That's why we need to add the size of one block here 
    size_t bufferSize = dataLength + kCCBlockSizeAES128; 
    void* buffer = malloc(bufferSize); 
    
    size_t numBytesEncrypted = 0; 
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding|kCCOptionECBMode, 
                                          keyPtr, kCCKeySizeAES256, 
                                          NULL /* initialization vector (optional) */, 
                                          [self bytes], dataLength, /* input */ 
                                          buffer, bufferSize, /* output */ 
                                          &numBytesEncrypted); 
    
    if (cryptStatus == kCCSuccess) 
    { 
        //the returned NSData takes ownership of the buffer and will free it on deallocation 
        return [NSMutableData dataWithBytesNoCopy:buffer length:numBytesEncrypted]; 
    } 
    
    free(buffer); //free the buffer; 
    return nil; 
} 

- (NSData*)AES256DecryptWithKey:(NSString*)key 
{ 
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise 
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused) 
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding) 
    
    // fetch key data 
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding]; 
    
    NSUInteger dataLength = [self length]; 
    
    //See the doc: For block ciphers, the output size will always be less than or 
    //equal to the input size plus the size of one block. 
    //That's why we need to add the size of one block here 
    size_t bufferSize = dataLength + kCCBlockSizeAES128; 
    void* buffer = malloc(bufferSize); 
    
    size_t numBytesDecrypted = 0; 
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding|kCCOptionECBMode, 
                                          keyPtr, kCCKeySizeAES256, 
                                          NULL /* initialization vector (optional) */, 
                                          [self bytes], dataLength, /* input */ 
                                          buffer, bufferSize, /* output */ 
                                          &numBytesDecrypted); 
    
    if (cryptStatus == kCCSuccess) 
    { 
        //the returned NSData takes ownership of the buffer and will free it on deallocation 
        return [NSMutableData dataWithBytesNoCopy:buffer length:numBytesDecrypted]; 
    } 
    
    free(buffer); //free the buffer; 
    return nil; 
} 

- (NSString*)md5Hash {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

@end

@implementation NSData (SnapAdditions)

- (long long)rw_int64AtOffset:(size_t)offset
{
    const long long *longlongbytes = (const long long *)[self bytes];
    return lntohll(longlongbytes[offset / 8]);
}

- (int)rw_int32AtOffset:(size_t)offset
{
    const int *intBytes = (const int *)[self bytes];
    return ntohl(intBytes[offset / 4]);
}

- (short)rw_int16AtOffset:(size_t)offset
{
    const short *shortBytes = (const short *)[self bytes];
    return ntohs(shortBytes[offset / 2]);
}

- (char)rw_int8AtOffset:(size_t)offset {
    const char * charBytes = (const char *)[self bytes];
    return charBytes[offset];
}

- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount{
    const char *charBytes = (const char *)[self bytes];
    NSString  * string =  [NSString stringWithUTF8String:charBytes + offset];
    *amount = strlen(charBytes + offset) +1;
    return string;
}

@end

@implementation NSMutableData (SnapAdditions)

- (void)rw_appendInt64:(long long)value
{
    value = lhtonll(value);
    [self appendBytes:&value length:8];
}

- (void)rw_appendInt32:(int)value
{
    value = htonl(value);
    [self appendBytes:&value length:4];
}

- (void)rw_appendInt16:(short)value
{
    value = htons(value);
    [self appendBytes:&value length:2];
}

- (void)rw_appendInt8:(char)value
{
    [self appendBytes:&value length:1];
}

- (void)rw_appendString:(NSString *)string
{
    
    const char * cString = [string UTF8String];
    [self appendBytes:cString length:strlen(cString) + 1];
}

@end
