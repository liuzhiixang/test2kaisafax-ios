//
//  KSUpdateAlertView.h
//  kaisafax
//
//  Created by semny on 16/8/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSUpdateView.h"

@interface KSUpdateAlert : NSObject

+ (KSUpdateAlert *)sharedInstance;

- (void)showUpdatePopupWindowWithVersion:(NSString*)version title:(NSString *)title description:(NSString *)description actionTitle:(NSString *)actionTitle close:(BOOL)showClose delegate:(id<UpdateViewDelegate>)delegate;

- (void)hiddenUpdatePopupWindow;
@end
