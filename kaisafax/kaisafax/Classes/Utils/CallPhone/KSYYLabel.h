//
//  KSYYLabel.h
//  kaisafax
//
//  Created by philipyu on 16/9/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <YYText/YYText.h>
#import <YYText/YYTextAttribute.h>

#define KCustomerServicePhone   @"400-889-6099"
@interface KSYYLabel : YYLabel
-(void)customerServiceRichText:(NSString *)custStr;
@end
