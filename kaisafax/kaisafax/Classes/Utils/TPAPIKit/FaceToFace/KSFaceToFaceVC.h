//
//  KSFaceToFaceVC.h
//  kaisafax
//
//  Created by semny on 16/8/30.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBaseVC.h"

@interface KSFaceToFaceVC : KSNVBaseVC

/**
 *  @author semny
 *
 *  根据链接url创建面对面扫码VC
 *
 *  @param linkURL 链接URL
 *
 *  @return 面对面扫码VC
 */
- (instancetype)initWithLinkURL:(NSString *)linkURL;

@end
