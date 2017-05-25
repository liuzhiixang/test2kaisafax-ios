
#import <Foundation/Foundation.h>
#import "KSRequestBL.h"
#import "KSVersionEntity.h"
@interface KSVersionMgr : KSRequestBL

//新版本信息
@property (nonatomic, strong) KSVersionEntity *versionData;
@property (nonatomic, copy) NSString *errorDescription;

/**
 *  获取单列
 *
 *  @return 单列对象
 */
+ (KSVersionMgr *)sharedInstance;

/**
 *  检查版本跟新
 */
- (NSInteger)doCheckUpdate;

/**
 *  @brief 获取应用版本名称
 *
 *  @return 应用版本名称
 */
- (NSString *)getVersionName;

/**
 *  获取应用版本数字编号
 *
 *  @return 应用版本数字编号
 */
- (int)getAppVersion;

/**
 *  @brief 获取应用名称
 *
 *  @return 应用名称
 */
- (NSString *)getAppName;




@end
