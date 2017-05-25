//
//  KSJDCardActionBL.h
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//京东卡的一些操作(获取卡密，验证码)
@interface KSJDCardActionBL : KSRequestBL

//获取卡密(挂卡)
- (NSInteger)doGetJDCardPasswordWithCardId:(long long)cardId;

//获取卡密(发送短信,默认制卡的手机号)
- (NSInteger)doSendMobileCaptchaForJDCard;

//获取卡密(验证短信)
- (NSInteger)doGetJDCardPasswordWithCaptcha:(NSString*)Captcha cardId:(long long)cardId;

@end
