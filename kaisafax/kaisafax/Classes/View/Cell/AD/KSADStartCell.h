//
//  KSADStartCell.h
//  kaisafax
//
//  Created by semny on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KADStartReusedID @"ADStartReusedID"

@class KSADStartCell;

@protocol KSADStartDelegate<NSObject>

@optional

- (void)startAction:(KSADStartCell *)cell;

@end


@interface KSADStartCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) id<KSADStartDelegate> delegate;

@end
