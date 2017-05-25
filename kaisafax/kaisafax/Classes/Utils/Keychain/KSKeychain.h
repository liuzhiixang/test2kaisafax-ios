//
//  KSKeychain.h
//  kaisafax
//
//  Created by Semny on 11/7/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Error code in Keychain API.
 */
typedef NS_ENUM (NSUInteger, KeychainErrorCode)
{
    KeychainErrorUnimplemented = 1, ///< Function or operation not implemented.
    KeychainErrorIO, ///< I/O error (bummers)
    KeychainErrorOpWr, ///< File already open with write permission.
    KeychainErrorParam, ///< One or more parameters passed to a function where not valid.
    KeychainErrorAllocate, ///< Failed to allocate memory.
    KeychainErrorUserCancelled, ///< User cancelled the operation.
    KeychainErrorBadReq, ///< Bad parameter or invalid state for operation.
    KeychainErrorInternalComponent, ///< Internal...
    KeychainErrorNotAvailable, ///< No keychain is available. You may need to restart your computer.
    KeychainErrorDuplicateItem, ///< The specified item already exists in the keychain.
    KeychainErrorItemNotFound, ///< The specified item could not be found in the keychain.
    KeychainErrorInteractionNotAllowed, ///< User interaction is not allowed.
    KeychainErrorDecode, ///< Unable to decode the provided data.
    KeychainErrorAuthFailed, ///< The user name or passphrase you entered is not.
};

/**
 When query to return the item's data, the error
 errSecInteractionNotAllowed will be returned if the item's data is not
 available until a device unlock occurs.
 */
typedef NS_ENUM (NSUInteger, KeychainAccessible) {
    KeychainAccessibleNone = 0, ///< no value
    
    KeychainAccessibleWhenUnlocked,
    
    KeychainAccessibleAfterFirstUnlock,
    
    KeychainAccessibleAlways,
    
    KeychainAccessibleWhenPasscodeSetThisDeviceOnly,
    
    KeychainAccessibleWhenUnlockedThisDeviceOnly,
    
    KeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    
    KeychainAccessibleAlwaysThisDeviceOnly,
};

/**
 Whether the item in question can be synchronized.
 */
typedef NS_ENUM (NSUInteger, KeychainQuerySynchronizationMode) {
    
    /** Default, Don't care for synchronization  */
    KeychainQuerySynchronizationModeAny = 0,
    
    /** Is not synchronized */
    KeychainQuerySynchronizationModeNo,
    
    /** To add a new item which can be synced to other devices, or to obtain
     synchronized results from a query*/
    KeychainQuerySynchronizationModeYes,
} NS_AVAILABLE_IOS (7_0);

@class KSKeychainAttribute;

@interface KSKeychain : NSObject
#pragma mark - Internet password method
/**
 Returns the password for a given account and service, or `nil` if not found or
 an error occurs.
 */
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (NSString *)passwordForAccount:(NSString *)account;

/**
 Deletes a password from the Keychain.
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (BOOL)deletePasswordForAccount:(NSString *)account;

/**
 Insert or update the password for a given account and service.
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (BOOL)setPassword:(NSString *)password account:(NSString *)account;
//服务器上的帐号信息
+ (NSArray<KSKeychainAttribute*> *)findAccounts;
+ (KSKeychainAttribute*)findOneAccount;

#pragma mark - Gennric Gesture method
/**
 Returns the password for a given account and service, or `nil` if not found or an error occurs.
 */
+ (NSString *)gestureForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (NSString *)gestureForService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (NSString *)gestureForAccount:(NSString *)account;

/**
 Deletes a Gesture from the Keychain.
 */
+ (BOOL)deleteGestureForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)deleteGestureForService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (BOOL)deleteGestureForAccount:(NSString *)account;

#pragma mark -------delete方法------------
+ (void)deleteAllKeychain;

/**
 Insert or update the Gesture for a given account and service.
 */
+ (BOOL)setGesture:(NSString *)Gesture forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)setGesture:(NSString *)Gesture forService:(NSString *)serviceName account:(NSString *)account;
//当前服务器server
+ (BOOL)setGesture:(NSString *)Gesture account:(NSString *)account;

//本机上的手势密码信息
+ (KSKeychainAttribute*)findGestureForAccount:(NSString*)account;

#pragma mark - Full query for keychain (SQL-like)
/**
 Insert an item into keychain.
 */
+ (BOOL)insertItem:(KSKeychainAttribute *)item error:(NSError **)error;
+ (BOOL)insertItem:(KSKeychainAttribute *)item;

/**
 Update item in keychain.
 */
+ (BOOL)updateItem:(KSKeychainAttribute *)item error:(NSError **)error;
+ (BOOL)updateItem:(KSKeychainAttribute *)item;

/**
 Delete items from keychain.
 */
+ (BOOL)deleteItem:(KSKeychainAttribute *)item error:(NSError **)error;
+ (BOOL)deleteItem:(KSKeychainAttribute *)item;

/**
 Find an item from keychain.
 */
+ (KSKeychainAttribute *)findOneItem:(KSKeychainAttribute *)item error:(NSError **)error;
+ (KSKeychainAttribute *)findOneItem:(KSKeychainAttribute *)item;

/**
 Find all items matches the query.
 */
+ (NSArray<KSKeychainAttribute *> *)findItems:(KSKeychainAttribute *)item error:(NSError **)error;
+ (NSArray<KSKeychainAttribute *> *)findItems:(KSKeychainAttribute *)item;

@end

#pragma mark - keychain Attribute
@interface KSKeychainAttribute : NSObject
@property (nonatomic, copy) NSString *secClass; //kSecClass
@property (nonatomic, copy) NSString *service; ///< kSecAttrService 或 kSecAttrServer(kSecClassInternetPassword)
@property (nonatomic, copy) NSString *account; ///< kSecAttrAccount
@property (nonatomic, copy) NSData *passwordData; ///< kSecValueData
@property (nonatomic, copy) NSString *password; ///< shortcut for `passwordData`
@property (nonatomic, copy) id <NSCoding> passwordObject; ///< shortcut for `passwordData`

//kSecClassInternetPassword
@property (nonatomic, copy) NSString *protocol; ///< kSecAttrProtocol
@property (nonatomic, copy) NSString *authenticationType; ///< kSecAttrAuthenticationType

@property (nonatomic, copy) NSString *label; ///< kSecAttrLabel
@property (nonatomic, copy) NSNumber *type; ///< kSecAttrType (FourCC)
@property (nonatomic, copy) NSNumber *creater; ///< kSecAttrCreator (FourCC)
@property (nonatomic, copy) NSString *comment; ///< kSecAttrComment
@property (nonatomic, copy) NSString *descr; ///< kSecAttrDescription
@property (nonatomic, readonly, strong) NSDate *modificationDate; ///< kSecAttrModificationDate
@property (nonatomic, readonly, strong) NSDate *creationDate; ///< kSecAttrCreationDate
@property (nonatomic, copy) NSString *accessGroup; ///< kSecAttrAccessGroup

@property (nonatomic) KeychainAccessible accessible; ///< kSecAttrAccessible
@property (nonatomic) KeychainQuerySynchronizationMode synchronizable NS_AVAILABLE_IOS(7_0); ///< kSecAttrSynchronizable
@end
