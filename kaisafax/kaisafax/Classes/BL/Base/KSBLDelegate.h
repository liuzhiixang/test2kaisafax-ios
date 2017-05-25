#import <Foundation/Foundation.h>

@class KSBaseBL;
@class KSResponseEntity;

/**
 *  业务类委托协议
 */
@protocol KSBLDelegate <NSObject>

@optional

/**
 *  即将处理业务逻辑
 *
 *  @param blEntiy   业务对象
 */
- (void)willHandle:(KSBaseBL *)blEntity;

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result;

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result;

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result;

@end
