//
//  SQScanResult.m
//  kaisafax
//
//  Created by semny on 16/9/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQScanResult.h"

@implementation SQScanResult

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type
{
    if (self = [super init]) {
        
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }
    
    return self;
}

@end
