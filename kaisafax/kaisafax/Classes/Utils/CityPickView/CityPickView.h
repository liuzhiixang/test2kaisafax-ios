//
//  CityPickView.h
//  cityPickView
//
//  Created by jia on 16/10/20.
//  Copyright © 2016年 Jiajingwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^confirmBlock)(NSString *proVince,NSString *city,NSString *provinceCode,NSString *cityCode);
typedef void(^selectOver)(NSString *proVince,NSString *city);
typedef void(^cancelBlock)();

@interface CityPickView : UIView <UIPickerViewDelegate,UIPickerViewDataSource>

@property (copy,nonatomic) NSString *province;
@property (copy,nonatomic) NSString *city;
@property (copy,nonatomic) NSString *area;
@property (nonatomic,copy) NSString *provinceCode;
@property (nonatomic,copy) NSString *cityCode;
@property (copy,nonatomic) NSString *address;

@property (nonatomic,assign) BOOL toolshidden;


@property (copy,nonatomic) confirmBlock confirmblock;
@property (copy,nonatomic) cancelBlock cancelblock;
@property (copy,nonatomic) selectOver doneBlock;

- (instancetype)initWithFrame:(CGRect)frame array:(NSMutableArray*)cityArray;
@end
