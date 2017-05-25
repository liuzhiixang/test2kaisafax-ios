//
//  WebParseManager.h
//  kaisafax
//
//  Created by philipyu on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>


#define  kiOS        @"ios"
#define  kResult     @"result"
#define  kAmount     @"amount"
#define  kAction     @"action"
#define  kActionFlag @"actionFlag"
#define  kTab        @"tab"
#define  kName       @"name"
#define  kCode       @"code"
#define  kLogin      @"login"
#define  kcashchl    @"cashChl"
#define  kData       @"data"

#define  kActionAdd  @"充值"
#define  kActionGet  @"提现"
#define  kActionBid  @"投标"

@interface WebParseManager : NSObject

@property (nonatomic,strong) NSDictionary *parseDict;
+ (instancetype)sharedInstance;


-(NSDictionary *)parse:(NSString*)jsonString;
@end
