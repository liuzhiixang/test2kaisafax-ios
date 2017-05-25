//
//  KSFaceToFaceVC.m
//  kaisafax
//
//  Created by semny on 16/8/30.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSFaceToFaceVC.h"
#import "SQScanWrapper.h"
#import "KSCacheMgr.h"

//320下的qrcode尺寸
#define KQRCodeWH       105.0f

@interface KSFaceToFaceVC ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
//顶部间距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeTopConstraint;
//二维码图片的长宽比
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeWHRatioConstraint;
//二维码和父视图长宽比
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrSuperWWRatioConstraint;

//链接URL
@property (copy, nonatomic) NSString *linkURL;
//二维码尺寸
@property (assign, nonatomic) CGFloat qrcodeW;
@property (assign, nonatomic) CGFloat qrcodeH;
//320屏幕宽度下的二维码顶部位置
@property (assign, nonatomic) CGFloat qrcodeTop;
//320屏幕宽度下的二维码中心点位置
@property (assign, nonatomic) CGFloat qrcodeCenterY;
@end

@implementation KSFaceToFaceVC
/**
 *  @author semny
 *
 *  根据链接url创建面对面扫码VC
 *
 *  @param linkURL 链接URL
 *
 *  @return 面对面扫码VC
 */
- (instancetype)initWithLinkURL:(NSString *)linkURL
{
    self = [super init];
    if (self)
    {
        _linkURL = linkURL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //nav相关
    [self configNav];
    
    //获取基础配置信息
    [self getQRCodeConstraintInfo];
    
    //创建并填充二维码
    [self createQRCodeWith:CGSizeMake(_qrcodeW, _qrcodeH) string:_linkURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configQRCode];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 加载视图
- (void)configNav
{
    self.title = KMyQRCodeTitle;
    
    //设置返回按钮
    [self setNavLeftButtonByImage:@"white_left" selectedImageName:@"white_left" navBtnAction:@selector(backAction:)];
}

- (void)getQRCodeConstraintInfo
{
    //长宽比例
    CGFloat qrWHRatio = _qrcodeWHRatioConstraint.multiplier;
    //qrcode与父视图的宽比例
    CGFloat qrSuperWWRatio = _qrSuperWWRatioConstraint.multiplier;
    //顶部间距
    CGFloat qrTop = _qrcodeTopConstraint.constant;
    
    //中心点Y值
    CGFloat qrcodeCenterY = MAIN_BOUNDS_SCREEN_WIDTH/320.0f*(KQRCodeWH/2+qrTop);
    CGFloat qrCodeHCurrent = 0;
    CGFloat qrCodeWCurrent = 0;
    if (qrWHRatio != 0)
    {
        qrCodeWCurrent = MAIN_BOUNDS_SCREEN_WIDTH*qrSuperWWRatio;
        qrCodeHCurrent = qrCodeWCurrent/qrWHRatio;
    }
    //尺寸
    _qrcodeH = qrCodeHCurrent;
    _qrcodeW = qrCodeWCurrent;
    //位置
    _qrcodeTop = qrTop;
    _qrcodeCenterY = qrcodeCenterY;
}

- (void)configQRCode
{
    //顶部间距
    _qrcodeTopConstraint.constant = _qrcodeCenterY - _qrcodeH/2.0f;
}

//创建二维码
- (void)createQRCodeWith:(CGSize)size string:(NSString *)str
{
    if (str && str.length > 0 && size.width > 0 && size.height > 0)
    {
        //异步线程操作
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //查找缓存数据
            NSURL *tempURL = [NSURL URLWithString:str];
            UIImage *image = [KSCacheMgr getCacheImageByURL:tempURL];
            //缓存数据为空
            if (!image || !(size.width > 0 && size.height > 0))
            {
                //生成二维码
                image = [SQScanWrapper createQRWithString:str size:size];
                //缓存新数据
                [KSCacheMgr storeImage:image forURL:tempURL];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置二维码图片
                _qrcodeImageView.image = image;
            });
        });
    }
}

#pragma mark - 
- (void)backAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
