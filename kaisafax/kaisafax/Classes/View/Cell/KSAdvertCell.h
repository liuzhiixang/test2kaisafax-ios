//
//  KSAdvertCell.h
//  kaisafax
//
//  Created by Jjyo on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseCell.h"

#define kAdvertCell @"KSAdvertCell"

@class JKPageView;
@interface KSAdvertCell : KSBaseCell

@property (weak, nonatomic) IBOutlet JKPageView *pageView;


@end
