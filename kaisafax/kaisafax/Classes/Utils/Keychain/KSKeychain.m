//
//  KSKeychain.m
//  kaisafax
//
//  Created by Semny on 11/7/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import "KSKeychain.h"
#import <Security/Security.h>
#import "AESCrypt.h"

static NSString *KServiceName = SX_SERVER_ADDRESS;
//证书没有创建AccessGroup的话，保存或者其他操作带上了自定义的AccessGroup的话会操作不成功，有待考察
static NSString *KAccessGroup = nil;//@"VX8S5F7QT6.com.kaisafax.appgroups";
//密码加密秘钥
static NSString *KPasswordSecurityKey = @"F05F94CA1B1459C236C2C35A4BCA72ED";

//手势密码存储的时候手机账号带上的后缀
#define KGesturePasswordAccountKey @"GesturePasswordAccount"

//系统版本
#define KC_SystemVersion ([UIDevice currentDevice].systemVersion.floatValue)
#define KC_IOS7_AND_LATER (KC_SystemVersion >= 7.0)

#pragma mark - static method
static KeychainErrorCode KeychainErrorCodeFromOSStatus(OSStatus status)
{
    switch (status)
    {
        case errSecUnimplemented: return KeychainErrorUnimplemented;
        case errSecIO: return KeychainErrorIO;
        case errSecOpWr: return KeychainErrorOpWr;
        case errSecParam: return KeychainErrorParam;
        case errSecAllocate: return KeychainErrorAllocate;
        case errSecUserCanceled: return KeychainErrorUserCancelled;
        case errSecBadReq: return KeychainErrorBadReq;
        case errSecInternalComponent: return KeychainErrorInternalComponent;
        case errSecNotAvailable: return KeychainErrorNotAvailable;
        case errSecDuplicateItem: return KeychainErrorDuplicateItem;
        case errSecItemNotFound: return KeychainErrorItemNotFound;
        case errSecInteractionNotAllowed: return KeychainErrorInteractionNotAllowed;
        case errSecDecode: return KeychainErrorDecode;
        case errSecAuthFailed: return KeychainErrorAuthFailed;
        default: return 0;
    }
}

static NSString *KeychainErrorDesc(KeychainErrorCode code)
{
    switch (code)
    {
        case KeychainErrorUnimplemented:
            return @"Function or operation not implemented.";
        case KeychainErrorIO:
            return @"I/O error (bummers)";
        case KeychainErrorOpWr:
            return @"ile already open with write permission.";
        case KeychainErrorParam:
            return @"One or more parameters passed to a function where not valid.";
        case KeychainErrorAllocate:
            return @"Failed to allocate memory.";
        case KeychainErrorUserCancelled:
            return @"User canceled the operation.";
        case KeychainErrorBadReq:
            return @"Bad parameter or invalid state for operation.";
        case KeychainErrorInternalComponent:
            return @"Inrernal Component";
        case KeychainErrorNotAvailable:
            return @"No keychain is available. You may need to restart your computer.";
        case KeychainErrorDuplicateItem:
            return @"The specified item already exists in the keychain.";
        case KeychainErrorItemNotFound:
            return @"The specified item could not be found in the keychain.";
        case KeychainErrorInteractionNotAllowed:
            return @"User interaction is not allowed.";
        case KeychainErrorDecode:
            return @"Unable to decode the provided data.";
        case KeychainErrorAuthFailed:
            return @"The user name or passphrase you entered is not";
        default:
            break;
    }
    return nil;
}

static id KeychainQuerySynchonizationID(KeychainQuerySynchronizationMode mode)
{
    switch (mode)
    {
        case KeychainQuerySynchronizationModeAny:
            return (__bridge id)(kSecAttrSynchronizableAny);
        case KeychainQuerySynchronizationModeNo:
            return (__bridge id)kCFBooleanFalse;
        case KeychainQuerySynchronizationModeYes:
            return (__bridge id)kCFBooleanTrue;
        default:
            return (__bridge id)(kSecAttrSynchronizableAny);
    }
}

static NSString *KeychainAccessibleString(KeychainAccessible e)
{
    switch (e)
    {
        case KeychainAccessibleWhenUnlocked:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlocked);
        case KeychainAccessibleAfterFirstUnlock:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlock);
        case KeychainAccessibleAlways:
            return (__bridge NSString *)(kSecAttrAccessibleAlways);
        case KeychainAccessibleWhenPasscodeSetThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
        case KeychainAccessibleWhenUnlockedThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlockedThisDeviceOnly);
        case KeychainAccessibleAfterFirstUnlockThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly);
        case KeychainAccessibleAlwaysThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAlwaysThisDeviceOnly);
        default:
            return nil;
    }
}

static KeychainAccessible KeychainAccessibleEnum(NSString *s)
{
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlocked])
        return KeychainAccessibleWhenUnlocked;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlock])
        return KeychainAccessibleAfterFirstUnlock;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlways])
        return KeychainAccessibleAlways;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly])
        return KeychainAccessibleWhenPasscodeSetThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
        return KeychainAccessibleWhenUnlockedThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly])
        return KeychainAccessibleAfterFirstUnlockThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlwaysThisDeviceOnly])
        return KeychainAccessibleAlwaysThisDeviceOnly;
    return KeychainAccessibleNone;
}

static KeychainQuerySynchronizationMode KeychainQuerySynchonizationEnum(NSNumber *num)
{
    if ([num isEqualToNumber:@NO]) return KeychainQuerySynchronizationModeNo;
    if ([num isEqualToNumber:@YES]) return KeychainQuerySynchronizationModeYes;
    return KeychainQuerySynchronizationModeAny;
}


#pragma mark - keychain Attribute
@interface KSKeychainAttribute ()
@property (nonatomic, readwrite, strong) NSDate *modificationDate;
@property (nonatomic, readwrite, strong) NSDate *creationDate;
@end

@implementation KSKeychainAttribute


- (void)setPasswordObject:(id <NSCoding> )object
{
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}

- (id <NSCoding> )passwordObject
{
    if ([self.passwordData length])
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}

- (void)setPassword:(NSString *)password
{
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)password
{
    if ([self.passwordData length])
    {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSMutableDictionary *)queryDict
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    CFStringRef secClass = (__bridge CFStringRef)(self.secClass);
    if (!secClass || secClass == NULL)
    {
        return dic;
    }
    
    if (secClass == kSecClassGenericPassword)
    {
        //本地密钥
        if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    }
    else if (secClass == kSecClassInternetPassword)
    {
        //网络密钥
        if (self.service) dic[(__bridge id)kSecAttrServer] = self.service;
        if (self.protocol) dic[(__bridge id)kSecAttrProtocol] = self.protocol;
        if (self.authenticationType) dic[(__bridge id)kSecAttrAuthenticationType] = self.authenticationType;
    }
    
    dic[(__bridge id)kSecClass] = (__bridge id)secClass;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    //if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    
    if (!TARGET_OS_SIMULATOR)
    {
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (KC_IOS7_AND_LATER)
    {
        dic[(__bridge id)kSecAttrSynchronizable] = KeychainQuerySynchonizationID(self.synchronizable);
    }
    
    return dic;
}

- (NSMutableDictionary *)dict
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    CFStringRef secClass = (__bridge CFStringRef)(self.secClass);
    if (!secClass || secClass == NULL)
    {
        return dic;
    }
    
    if (secClass == kSecClassGenericPassword)
    {
        //本地密钥
        if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    }
    else if (secClass == kSecClassInternetPassword)
    {
        //网络密钥
        if (self.service) dic[(__bridge id)kSecAttrServer] = self.service;
        if (self.protocol) dic[(__bridge id)kSecAttrProtocol] = self.protocol;
        if (self.authenticationType) dic[(__bridge id)kSecAttrAuthenticationType] = self.authenticationType;
    }
    //class类型
    dic[(__bridge id)kSecClass] = (__bridge id)secClass;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    if (self.label) dic[(__bridge id)kSecAttrLabel] = self.label;
    
    if (!TARGET_IPHONE_SIMULATOR)
    {
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (KC_IOS7_AND_LATER)
    {
        dic[(__bridge id)kSecAttrSynchronizable] = KeychainQuerySynchonizationID(self.synchronizable);
    }
    
    if (self.accessible) dic[(__bridge id)kSecAttrAccessible] = KeychainAccessibleString(self.accessible);
    if (self.passwordData) dic[(__bridge id)kSecValueData] = self.passwordData;
    if (self.type) dic[(__bridge id)kSecAttrType] = self.type;
    if (self.creater) dic[(__bridge id)kSecAttrCreator] = self.creater;
    if (self.comment) dic[(__bridge id)kSecAttrComment] = self.comment;
    if (self.descr) dic[(__bridge id)kSecAttrDescription] = self.descr;
    
    return dic;
}

- (instancetype)initWithDict:(NSDictionary *)dic
{
    if (dic.count == 0) return nil;
    self = self.init;
    self.secClass = dic[(__bridge id)kSecClass];
    self.service = dic[(__bridge id)kSecAttrService];
    self.account = dic[(__bridge id)kSecAttrAccount];
    self.passwordData = dic[(__bridge id)kSecValueData];
    self.label = dic[(__bridge id)kSecAttrLabel];
    self.type = dic[(__bridge id)kSecAttrType];
    self.creater = dic[(__bridge id)kSecAttrCreator];
    self.comment = dic[(__bridge id)kSecAttrComment];
    self.descr = dic[(__bridge id)kSecAttrDescription];
    self.modificationDate = dic[(__bridge id)kSecAttrModificationDate];
    self.creationDate = dic[(__bridge id)kSecAttrCreationDate];
    self.accessGroup = dic[(__bridge id)kSecAttrAccessGroup];
    self.accessible = KeychainAccessibleEnum(dic[(__bridge id)kSecAttrAccessible]);
    self.synchronizable = KeychainQuerySynchonizationEnum(dic[(__bridge id)kSecAttrSynchronizable]);
    
    //Internet password
    self.protocol = dic[(__bridge id)kSecAttrProtocol];
    self.authenticationType = dic[(__bridge id)kSecAttrAuthenticationType];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    KSKeychainAttribute *item =[[KSKeychainAttribute alloc] init];
    item.secClass = self.secClass;
    item.service = self.service;
    item.account = self.account;
    item.passwordData = self.passwordData;
    item.label = self.label;
    item.type = self.type;
    item.creater = self.creater;
    item.comment = self.comment;
    item.descr = self.descr;
    item.modificationDate = self.modificationDate;
    item.creationDate = self.creationDate;
    item.accessGroup = self.accessGroup;
    item.accessible = self.accessible;
    item.synchronizable = self.synchronizable;
    //Internet password
    item.protocol = self.protocol;
    item.authenticationType = self.authenticationType;
    return item;
}

@end


#pragma mark - keychain option

@implementation KSKeychain
#pragma mark - Internet password method
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!serviceName || !account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return nil;
    }
    
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassInternetPassword;
    item.service = serviceName;
    item.account = account;
    KSKeychainAttribute *result = [self findOneItem:item error:error];
    NSString *password = result.password;
    return password;
}

+ (nullable NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account
{
    return [self passwordForService:serviceName account:account error:NULL];
}

//当前服务器server
+ (NSString *)passwordForAccount:(NSString *)account
{
    return [self passwordForService:KServiceName account:account error:NULL];
}

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!password || !serviceName || !account) {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassInternetPassword;
    item.service = serviceName;
    item.account = account;
    KSKeychainAttribute *result = [self findOneItem:item error:NULL];
    result.secClass = item.secClass;
    result.service = item.service;
    //加密
    password = [AESCrypt encrypt:password password:KPasswordSecurityKey];
    if (result)
    {
        result.password = password;
        return [self updateItem:result error:error];
    } else {
        item.password = password;
        return [self insertItem:item error:error];
    }
}

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account
{
    return [self setPassword:password forService:serviceName account:account error:NULL];
}

//当前服务器server
+ (BOOL)setPassword:(NSString *)password account:(NSString *)account
{
    return [self setPassword:password forService:KServiceName account:account error:NULL];
}

+ (NSArray<KSKeychainAttribute*> *)findAccounts
{
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassInternetPassword;
    item.service = KServiceName;
    return [self findItems:item];
}

+ (KSKeychainAttribute*)findOneAccount
{
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassInternetPassword;
    item.service = KServiceName;
    
    if (!item.service)
    {
        return nil;
    }
    
    NSArray *items = [self findItems:item];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO];
    items = [items sortedArrayUsingDescriptors:@[sort]];
    
    return [items firstObject];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!serviceName || !account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassInternetPassword;
    item.service = serviceName;
    item.account = account;
    return [self deleteItem:item error:error];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account
{
    return [self deletePasswordForService:serviceName account:account error:NULL];
}

//当前服务器server
+ (BOOL)deletePasswordForAccount:(NSString *)account
{
    return [self deletePasswordForService:KServiceName account:account error:NULL];
}

#pragma mark - Gennric Gesture method
/**
 Returns the gesture for a given account and service, or `nil` if not found or an error occurs.
 */
+ (NSString *)gestureForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!serviceName || !account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return nil;
    }
    
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassGenericPassword;
    item.service = serviceName;
    //账户
    NSString *accountStr = [NSString stringWithFormat:@"%@_%@", account, KGesturePasswordAccountKey];
    item.account = accountStr;
    KSKeychainAttribute *result = [self findOneItem:item error:error];
    NSString *password = result.password;
    return password;
}

+ (NSString *)gestureForService:(NSString *)serviceName account:(NSString *)account
{
    return [self gestureForService:serviceName account:account error:NULL];
}

//当前服务器server
+ (NSString *)gestureForAccount:(NSString *)account
{
    return [self gestureForService:KServiceName account:account error:NULL];
}

/**
 Deletes a Gesture from the Keychain.
 */
+ (BOOL)deleteGestureForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!serviceName || !account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassGenericPassword;
    item.service = serviceName;
    //账户
    NSString *accountStr = [NSString stringWithFormat:@"%@_%@", account, KGesturePasswordAccountKey];
    item.account = accountStr;
    return [self deleteItem:item error:error];
}

+ (BOOL)deleteGestureForService:(NSString *)serviceName account:(NSString *)account
{
    return [self deleteGestureForService:serviceName account:account error:NULL];
}

//当前服务器server
+ (BOOL)deleteGestureForAccount:(NSString *)account
{
    return [self deleteGestureForService:KServiceName account:account error:NULL];
}

/**
 Insert or update the Gesture for a given account and service.
 */
+ (BOOL)setGesture:(NSString *)gesture forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    if (!gesture || !serviceName || !account) {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassGenericPassword;
    item.service = serviceName;
    //账户
    NSString *accountStr = [NSString stringWithFormat:@"%@_%@", account, KGesturePasswordAccountKey];
    item.account = accountStr;
    KSKeychainAttribute *result = [self findOneItem:item error:NULL];
    result.secClass = item.secClass;
    result.service = item.service;
    //加密
    gesture = [AESCrypt encrypt:gesture password:KPasswordSecurityKey];
    if (result)
    {
        result.password = gesture;
        return [self updateItem:result error:error];
    } else {
        item.password = gesture;
        return [self insertItem:item error:error];
    }
}

+ (BOOL)setGesture:(NSString *)gesture forService:(NSString *)serviceName account:(NSString *)account
{
    return [self setGesture:gesture forService:serviceName account:account error:NULL];
}

//当前服务器server
+ (BOOL)setGesture:(NSString *)gesture account:(NSString *)account
{
    return [self setGesture:gesture forService:KServiceName account:account error:NULL];
}

//本机上的手势密码信息
+ (KSKeychainAttribute*)findGestureForAccount:(NSString*)account
{
    KSKeychainAttribute *item = [[KSKeychainAttribute alloc] init];
    item.secClass = (__bridge id)kSecClassGenericPassword;
    item.service = KServiceName;
    //账户
    NSString *accountStr = [NSString stringWithFormat:@"%@_%@", account, KGesturePasswordAccountKey];
    item.account = accountStr;
    if (!item.service)
    {
        return nil;
    }
    
    KSKeychainAttribute *result = [self findOneItem:item];
    return result;
}

#pragma mark -------delete方法------------
+ (void)deleteAllKeychain
{
    //OSStatus result = noErr;
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
    [self deleteAllKeysForSecClass:kSecClassIdentity];
//    if (result == noErr || result == errSecItemNotFound)
    {
//        NSLog(@"Error deleting keychain data (%ld)", (long)result);
    }
    
//    NSLog(@"Error deleting keychain data (%ld)", (long)result);
    //模拟器会抛异常
    //NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%ld)", (long)result);
}

+ (OSStatus)deleteAllKeysForSecClass:(CFTypeRef)secClass
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)secClass forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    return result;
}

#pragma mark - normal item method
+ (BOOL)insertItem:(KSKeychainAttribute *)item error:(NSError **)error
{
    if (!item.service || !item.account || !item.passwordData)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item dict];
    OSStatus status = status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess) {
        if (error) *error = [self errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)insertItem:(KSKeychainAttribute *)item
{
    return [self insertItem:item error:NULL];
}

+ (BOOL)updateItem:(KSKeychainAttribute *)item error:(NSError **)error
{
    if (!item.service || !item.account || !item.passwordData)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item queryDict];
    NSMutableDictionary *update = [item dict];
    [update removeObjectForKey:(__bridge id)kSecClass];
    if (!query || !update) return NO;
    OSStatus status = status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    if (status != errSecSuccess)
    {
        if (error) *error = [self errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)updateItem:(KSKeychainAttribute *)item
{
    return [self updateItem:item error:NULL];
}

+ (BOOL)deleteItem:(KSKeychainAttribute *)item error:(NSError **)error
{
    if (!item.service || !item.account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item dict];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess)
    {
        if (error) *error = [self errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)deleteItem:(KSKeychainAttribute *)item
{
    return [self deleteItem:item error:NULL];
}

+ (KSKeychainAttribute *)findOneItem:(KSKeychainAttribute *)item error:(NSError **)error
{
    if (!item.service || !item.account)
    {
        if (error) *error = [self errorWithCode:errSecParam];
        return nil;
    }
    
    NSMutableDictionary *query = [item dict];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess)
    {
        if (error) *error = [[self class] errorWithCode:status];
        return nil;
    }
    if (!result) return nil;
    
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID()) {
        dic = (__bridge NSDictionary *)(result);
    } else if (CFGetTypeID(result) == CFArrayGetTypeID()){
        dic = [(__bridge NSArray *)(result) firstObject];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    if (!dic.count) return nil;
    //结果
    KSKeychainAttribute *resultItem = [[KSKeychainAttribute alloc] initWithDict:dic];
    //解密
    NSString *password = resultItem.password;
    resultItem.password = [AESCrypt decrypt:password password:KPasswordSecurityKey];
    return resultItem;
}

+ (KSKeychainAttribute *)findOneItem:(KSKeychainAttribute *)item
{
    return [self findOneItem:item error:NULL];
}

+ (NSArray *)findItems:(KSKeychainAttribute *)item error:(NSError **)error
{
    NSMutableDictionary *query = [item dict];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL)
    {
        *error = [[self class] errorWithCode:status];
        return nil;
    }
    
    //判断数据
    if (!result) return nil;
    
    NSMutableArray *res = [[NSMutableArray alloc] init];
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID())
    {
        dic = (__bridge NSDictionary *)(result);
        //结果
        KSKeychainAttribute *resultItem = [[KSKeychainAttribute alloc] initWithDict:dic];
        //解密
        NSString *password = resultItem.password;
        resultItem.password = [AESCrypt decrypt:password password:KPasswordSecurityKey];
        if (resultItem) [res addObject:resultItem];
    }
    else if (CFGetTypeID(result) == CFArrayGetTypeID())
    {
        for (NSDictionary *dic in (__bridge NSArray *)(result))
        {
            //结果
            KSKeychainAttribute *resultItem = [[KSKeychainAttribute alloc] initWithDict:dic];
            //解密
            NSString *password = resultItem.password;
            resultItem.password = [AESCrypt decrypt:password password:KPasswordSecurityKey];
            if (resultItem) [res addObject:resultItem];
        }
    }
    
    return res;
}

+ (NSArray *)findItems:(KSKeychainAttribute *)item
{
    return [self findItems:item error:NULL];
}

#pragma mark - inner method
+ (NSError *)errorWithCode:(OSStatus)osCode
{
    KeychainErrorCode code = KeychainErrorCodeFromOSStatus(osCode);
    NSString *desc = KeychainErrorDesc(code);
    NSDictionary *userInfo = desc ? @{ NSLocalizedDescriptionKey : desc } : nil;
    return [NSError errorWithDomain:@"keychain_error" code:code userInfo:userInfo];
}

@end


