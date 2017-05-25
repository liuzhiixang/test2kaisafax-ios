//
//  NSString+AddBlank.m
//  kaisafax
//
//  Created by mac on 17/3/30.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "NSString+AddBlank.h"

@implementation NSString (AddBlank)
+ (NSString *)separatedBlankStringWithStr:(NSString *)digitString

{
    float count = 0.0;
    if (digitString.length%4) {
        count = digitString.length/4+1;
    } else {
        count = digitString.length/4;
    }
    
    float location=0;
    
    NSMutableArray *processArray = [NSMutableArray array];
    
    if (digitString.length <= 4) {
        
        return digitString;
        
    } else {
        
        NSMutableString *processString = [NSMutableString stringWithString:digitString];
        
        for (int i=0; i<count; i++) {
            
            NSString *t;
            
            if ((i==count-1)&&(digitString.length%4)) {
                t = [processString substringWithRange:NSMakeRange(location, digitString.length%4)];
            } else {
                t = [processString substringWithRange:NSMakeRange(location, 4)];
            }
            
            [processArray addObject:t];
            
            location +=4;
        }
        
    }
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    int k = 0;
    
    for (NSString *str in processArray)
        
    {
        
        k++;
        
        NSMutableString *tmp = [NSMutableString stringWithString:str];
        
        if (str.length > 0 && k < processArray.count )
            
        {
            
            [tmp insertString:@" " atIndex:4];
            
            [resultsArray addObject:tmp];
            
        } else {
            
            [resultsArray addObject:tmp];
            
        }
        
    }
    
    NSMutableString *resultString = [NSMutableString string];
    
    for (int  i = 0 ; i <= resultsArray.count - 1; i++)
        
    {
        
        NSString *tmp = [resultsArray objectAtIndex:i];
        
        [resultString appendString:tmp];
        
    }
    return resultString;
}
@end
