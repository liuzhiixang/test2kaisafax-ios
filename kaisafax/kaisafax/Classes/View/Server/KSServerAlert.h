//
//  KSServerAlert.h
//  kaisafax
//
//  Created by semny on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSServerStatusView.h"

@interface KSServerAlert : NSObject

+ (KSServerAlert *)sharedInstance;

- (void)showServerPopupWindowWith:(NSString*)comment1 comment2:(NSString *)comment2 comment3:(NSString *)comment3 actionTitle:(NSString *)actionTitle delegate:(id<ServerStatusViewDelegate>)delegate;

- (void)hiddenServerPopupWindow;
@end
