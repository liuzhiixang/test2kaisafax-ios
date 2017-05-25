//
//  KSADStartLayout.m
//  kaisafax
//
//  Created by semny on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADStartLayout.h"

@implementation KSADStartLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        CGFloat mainHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
        self.itemSize = CGSizeMake(mainWidth, mainHeight);
        self.minimumLineSpacing = 0.0f;
        self.minimumInteritemSpacing = 0.0f;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
