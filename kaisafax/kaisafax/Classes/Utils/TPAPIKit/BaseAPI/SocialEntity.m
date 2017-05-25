//
//  SocialEntity.m
//  kaisafax
//
//  Created by semny on 16/8/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SocialEntity.h"
#import "SocialSequenceNo.h"

@implementation SocialEntity

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _identifier = [self composeIdentifier];
    }
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [self init];
    if (self)
    {
        if (identifier && identifier.length > 0)
        {
            _identifier = [self composeIdentifierWith:identifier];
        }
    }
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier withTitle:(NSString *)title
{
    self = [self initWithIdentifier:identifier];
    if (self)
    {
        _title = title;
    }
    return self;
}

#pragma mark -
- (NSString *)composeIdentifier
{
    NSString *temp = [self composeIdentifierWith:nil];
    return temp;
}

- (NSString *)composeIdentifierWith:(NSString *)key
{
    if (!key || key.length <= 0)
    {
        key = @"SECONTENT";
    }
    NSString *temp = [NSString stringWithFormat:@"%@_%lld", key,(long long)[SocialSequenceNo sharedInstance].sequenceNo];
    return temp;
}
@end
