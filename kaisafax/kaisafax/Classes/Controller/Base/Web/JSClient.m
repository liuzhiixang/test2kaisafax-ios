//
//  JSClient.m
//  kaisafax
//
//  Created by Jjyo on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "JSClient.h"

@implementation JSClient
- (instancetype)initWithDelegate:(id<JSClientDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)share:(NSString *)jsonString
{
    INFO(@"share:%@", jsonString);
    if(_delegate && [_delegate respondsToSelector:@selector(share:)])
    {
        [_delegate share:jsonString];
    }
}

- (void)startPage:(NSString *)jsonString
{
    INFO(@"startPage:%@", jsonString);
    if(_delegate && [_delegate respondsToSelector:@selector(startPage:)])
    {
        [_delegate startPage:jsonString];
    }
}

//-(void)syncSession:(NSString *)sessionString
//{
//    INFO(@"syncSession:%@", sessionString);
//    if(_delegate && [_delegate respondsToSelector:@selector(syncSession:)])
//    {
//        [_delegate syncSession:sessionString];
//    }
//}
@end
