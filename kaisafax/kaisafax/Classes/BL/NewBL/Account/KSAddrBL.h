//
//  KSAddrBL.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSAddrBL : KSRequestBL
- (NSInteger)doSetAddrWithName:(NSString*)receiverName mobile:(NSString*)receiverMobile province:(NSString*)province
                          city:(NSString*)city county:(NSString*)county address:(NSString*)address zipCode:(NSString*)zipCode;
@end
