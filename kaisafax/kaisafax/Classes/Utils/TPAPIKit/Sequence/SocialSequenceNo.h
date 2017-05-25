//
//  KSSequenceNo.h
//  kaisafax
//
//  Created by Semny on 15/5/5.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialSequenceNo : NSObject

@property (nonatomic, assign, readonly, getter=getSequenceNo) NSInteger sequenceNo;

+ (instancetype)sharedInstance;

@end
