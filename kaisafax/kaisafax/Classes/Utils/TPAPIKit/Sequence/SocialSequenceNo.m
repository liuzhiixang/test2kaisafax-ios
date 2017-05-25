//
//  KSSequenceNo.m
//  kaisafax
//
//  Created by Semny on 15/5/5.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import "SocialSequenceNo.h"
//#import <libkern/OSBase.h>

@interface SocialSequenceNo()

@property (nonatomic, assign) NSInteger SequenceNum;


@end

@implementation SocialSequenceNo

@synthesize sequenceNo =_sequenceNo;

+ (instancetype)sharedInstance
{
    static SocialSequenceNo *seqObj = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        if (!seqObj)
        {
            seqObj = [[SocialSequenceNo alloc] init];
        }
    });
    return seqObj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _SequenceNum = NSNotFound;
        [self getSequenceNum];
    }
    return self;
}

- (NSInteger)getSequenceNo
{
    [self getSequenceNum];
    return _sequenceNo;
}

- (void)getSequenceNum
{
    if (_SequenceNum == NSNotFound)
    {
        NSDate *date = [NSDate date];
        NSInteger time = [date timeIntervalSince1970];
        _SequenceNum = (int)RandomNumber(1, 100);
        _SequenceNum += time;
    }
    _sequenceNo = _SequenceNum;
    _SequenceNum++;
}
@end
