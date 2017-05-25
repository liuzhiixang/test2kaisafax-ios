//
//  KSAddrVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAddrVC.h"
#import "KSContactTFCell.h"
#import "KSContactPickCell.h"
#import "CityPickView.h"
#import "KSAddrBL.h"
#import "KSAreaBL.h"
#import "KSAccountInfoVC.h"
#import "UIView+Toast.h"
#import "KSAddrEntity.h"
#import "KSAreaArrayEntity.h"


#define kItemArrays   @[@"收货人",@"手机号码",@"地区信息",@"详细信息",@"邮政编码"]
#define kItemPHArrays @[@"请填写收货人姓名",@"请填写收货人手机号",@"请选择地区",@"街道门牌信息",@"邮政编码"]
#define kNullStr   @"(null)"


#define kImgWidth     12
#define kMargin       15


typedef NS_ENUM(NSInteger,KSAddress)
{
    KSAddressPerson = 0,          //名字
    KSAddressPhone,               //手机号
    KSAddressDistrict,            //地区
    KSAddressDetail,              //详细地址
    KSAddressZip,                 //邮编
    KSAddressMax,                 //最大枚举值;
};

@interface KSAddrVC ()<UITableViewDataSource,UITableViewDelegate,KSContactTFCellDelegate,KSContactPickCellDelegate,KSBLDelegate>
@property (weak, nonatomic) IBOutlet UITableView *addrTableView;
@property (weak, nonatomic) UIButton *saveBtn;
@property (nonatomic,copy) NSString *personContent;
@property (nonatomic,copy) NSString *phoneContent;
@property (nonatomic,copy) NSString *disContent;
@property (nonatomic,copy) NSString *detailContent;
@property (nonatomic,copy) NSString *zipContent;
@property (nonatomic,copy) NSString *provinceCode;
@property (nonatomic,copy) NSString *cityCode;

@property (strong, nonatomic) CityPickView *cityPicker;
@property (weak, nonatomic) UIButton *cityBtn;

@property (strong, nonatomic) KSAddrBL *addrBL;
@property (strong, nonatomic) KSAreaBL *areaBL;
@property (strong, nonatomic) NSMutableArray *areaArray;

@property (assign, nonatomic) BOOL isFirst;


//textfield
@property (weak, nonatomic) UITextField *personTF;
@property (weak, nonatomic) UITextField *phoneTF;
//@property (weak, nonatomic) UITextField *disTF;
@property (weak, nonatomic) UITextField *detailTF;
@property (weak, nonatomic) UITextField *zipTF;

@property (weak, nonatomic) UIView *tipsView;

@property (assign, nonatomic) CGFloat reasonableW;

@end

@implementation KSAddrVC
#pragma mark - 懒加载
-(NSMutableArray*)areaArray
{
    if (!_areaArray) {
        _areaArray = [NSMutableArray array];
    }
    return _areaArray;
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = KAddrAddTitle;
    
    _isFirst = YES;
    
    kRegisterCellNib(_addrTableView,kScontactTFCell);
    kRegisterCellNib(_addrTableView,kSContactPickCell);
    
    _addrTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _addrTableView.backgroundColor = UIColorFromHex(0xebebeb);

    [self configHeaderandFooterView];

    if(!_addrBL)
    {
        _addrBL = [[KSAddrBL alloc]init];
        _addrBL.delegate = self;
    }
    
    if(!_areaBL)
    {
        _areaBL = [[KSAreaBL alloc]init];
        _areaBL.delegate = self;
    }
    
    //比较前面标题的长度，用于保持前面label的长度一致
    self.reasonableW =  [self caluatorCellTitleWidth];
    
    if(self.addrData)
    {
        self.provinceCode = self.addrData.provinceCode;
        if (self.addrData.cityCode && ![self.addrData.cityCode isEqualToString:kNullStr])
        {
            self.cityCode = self.addrData.cityCode;
        }
    }
    
    [_areaBL doGetArea];
    
    [_addrTableView reloadData];
}

#pragma mark -
-(CGFloat)caluatorCellTitleWidth
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    
    NSString *temStr = kItemArrays[0];
    CGFloat maxW = [temStr sizeWithAttributes:attrs].width;
    
    for (int i=0; i<kItemArrays.count; i++) {
        NSString *pickStr = kItemArrays[i];
        
        CGFloat pickW = [pickStr sizeWithAttributes:attrs].width;
        NSLog(@"%d %.2f",i,pickW);
        if (pickW>maxW) {
            maxW = pickW;
        }
    }
    NSLog(@"max %.2f",maxW);
    
    //    CGSize size=[temStr sizeWithAttributes:attrs];
    return maxW+2;
}

#pragma mark - 添加tableview的头部文字和尾部按钮
-(void)configHeaderandFooterView
{
    //headerview
    UIView *headerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, kMargin+kMargin+13)];
    headerview.backgroundColor = ClearColor;
    UILabel *headerlabel =[[UILabel alloc]initWithFrame:CGRectMake(kMargin, kMargin,MAIN_BOUNDS_SCREEN_WIDTH, 13)];
    headerlabel.font =[UIFont systemFontOfSize:13.0];
    headerlabel.textColor = NUI_HELPER.appDarkGrayColor;
    headerlabel.text = kAddrHeaderTitle;
    [headerview addSubview:headerlabel];
    _addrTableView.tableHeaderView = headerview;
    
    
    //footerview
    UIView *footerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 85)];
    footerview.backgroundColor = ClearColor;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 41, MAIN_BOUNDS_SCREEN_WIDTH-30, 44)];
//    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
//    [btn setTitleColor:WhiteColor forState:(UIControlStateNormal)];
    [btn setTitle:KSaveTitle forState:UIControlStateNormal];
//    [btn setBackgroundColor:NUI_HELPER.appDisableColor];
    
    [btn addTarget:self action:@selector(saveAction) forControlEvents:(UIControlEventTouchUpInside)];
    [footerview addSubview:btn];
    //    btn.layer.cornerRadius = 5.0;
    //    [btn setEnabled:NO];
    btn.nuiClass = NUIAppOrangeButton;
    
    //提示信息
    UIView *tipsView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, MAIN_BOUNDS_SCREEN_WIDTH, 16)];
    tipsView.backgroundColor = ClearColor;
    [footerview addSubview:tipsView];
    
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, MAIN_BOUNDS_SCREEN_WIDTH-15, kImgWidth)];
    tipLabel.text = KCorrectPhoneTitle;
    tipLabel.textColor = UIColorFromHex(0xE60012);
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    [tipsView addSubview:tipLabel];
    _tipsView = tipsView;
    tipsView.hidden = YES;
    
    _saveBtn = btn;
    _addrTableView.tableFooterView = footerview;
    
    
}

#pragma mark - 保存地址信息
-(void)saveAction
{
    [self.view endEditing:YES];
    
    if (![self checkMobileBy:_phoneTF.text])
    {
        [self showToastWithTitle:KInputPhoneErrorText];
        _tipsView.hidden = NO;
        
        return;
    }
    
    if(self.zipTF.text.length<KPostCodeMaxLength)
    {
        [self showToastWithTitle:KInputPostcodeErrorText];
        return;
    }
    
    if(self.detailTF.text.length>KDetailAddrMaxLength)
    {
        [self showToastWithTitle:KInputDetailInfoErrorText];
        return;
    }
    
    if(self.personTF.text.length>KPersonalNameMaxLength)
    {
        [self showToastWithTitle:KInputNameErrorText];
        return;
    }
    
    [_addrBL doSetAddrWithName:_personTF.text mobile:_phoneTF.text province:self.provinceCode city:self.cityCode county:nil address:_detailTF.text zipCode:_zipTF.text];
}

#pragma mark -
-(void)addObserver
{
    //手机号
    @WeakObj(self);
    RAC(self.phoneTF, text) = [self.phoneTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPhoneNumberLength)
        {
//            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPhoneNumberLength];
        }
//        weakself.phoneTF.text = newValue;
        return newValue;
    }];
    
//    RAC(self.personTF, text) = [self.personTF.rac_textSignal map:^id(NSString *value) {
//        NSString *newValue = value;
//        if (value.length > KPersonalNameMaxLength)
//        {
//            [weakself showToastWithTitle:KReachedInputMaxLength];
//            newValue = [value substringToIndex:KPersonalNameMaxLength];
//        }
////        weakself.personTF.text = newValue;
//        return newValue;
//    }];
    
//    RAC(self.detailTF, text) = [self.detailTF.rac_textSignal map:^id(NSString *value) {
//        NSString *newValue = value;
//        if (value.length > KDetailAddrMaxLength)
//        {
//            [weakself showToastWithTitle:KReachedInputMaxLength];
//            newValue = [value substringToIndex:KDetailAddrMaxLength];
//        }
////        weakself.detailTF.text = newValue;
//        return newValue;
//    }];
    
    RAC(self.zipTF, text) = [self.zipTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPostCodeMaxLength)
        {
//            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPostCodeMaxLength];
        }
//        weakself.zipTF.text = newValue;
        return newValue;
    }];
    
    [[RACSignal combineLatest:@[_personTF.rac_textSignal,
                                _phoneTF.rac_textSignal,
                                RACObserve(self, disContent),
                                _detailTF.rac_textSignal,
                                _zipTF.rac_textSignal
                                ]
                       reduce:^(NSString *person, NSString *phone, NSString *dis,NSString *detail,NSString *zip){
                           return @(person.length > 0 && phone.length > 0 && dis.length>0 && detail.length>0 && zip.length>0);
                       }]
     subscribeNext:^(NSNumber *res){
         {
             _saveBtn.enabled = [res boolValue];

         }
     }];
    return;
}

- (BOOL)checkMobileBy:(NSString *)phone
{
    BOOL flag = YES;
    //判断字符格式和长度
    //flag = [NSString checkIfAlphaNumeric:username range:NSMakeRange(KUserNameMinLength, KUserNameMaxLength)];
    flag = [NSString checkIsPhoneNumber:phone range:NSMakeRange(KPhoneNumberLength, KPhoneNumberLength)];
    return flag;
}

#pragma mark
-(void)setupCityPicker
{
    
    @WeakObj(self);
    if (!self.areaArray || self.areaArray.count == 0)
    {
        return;
    }
    
    self.cityPicker = [[CityPickView alloc]initWithFrame:[UIScreen mainScreen].bounds array:self.areaArray];
    
    if (self.addrData)
    {
        [self.cityPicker setAddress:[NSString stringWithFormat:@"%@-%@",self.addrData.provinceName,self.addrData.cityName]];
    }
    else
    {
        [self.cityPicker setAddress:@"广东省-深圳市"];
    }
    self.cityPicker.toolshidden = NO;
    
    
    //
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.cityPicker];
    
    self.cityPicker.confirmblock = ^(NSString *proVince,NSString *city,NSString *provinceCode,NSString *cityCode)
    {
        NSString *cityStr  = @"";
        if ([city isEqualToString:kNullStr] || !city || [city isEqualToString:@""])
        {
            cityStr= [NSString stringWithFormat:@"%@",proVince];
        }
        else
        {
            cityStr = [NSString stringWithFormat:@"%@%@",proVince,city];
        }
        [weakself.cityBtn setTitle:cityStr forState:(UIControlStateNormal)];
        [weakself.cityBtn setTitleColor:NUI_HELPER.appDarkGrayColor forState:(UIControlStateNormal)];
        [weakself.cityPicker removeFromSuperview];
        weakself.disContent = cityStr;
        
        if (![cityCode isEqualToString:kNullStr] && cityCode && ![cityCode isEqualToString:@""])
        {
            weakself.cityCode = cityCode;
        }
        else
        {
            weakself.cityCode = nil;
        }
        
        weakself.provinceCode = provinceCode;
    };
    //点击取消按钮回调
    self.cityPicker.cancelblock = ^(){
        [weakself.cityPicker removeFromSuperview];
    };
}


#pragma mark - tableview datasource and delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return KSAddressMax;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    if (row >=0 && row<KSAddressMax)
    {
        if (row == KSAddressDistrict) {
            KSContactPickCell *cell = [tableView dequeueReusableCellWithIdentifier:kSContactPickCell];
            if(_isFirst)
            {
                cell.titleConstraintW.constant = self.reasonableW;
                if(self.addrData && self.addrData.provinceName)
                {
                    NSString *districtStr = @"";
                    NSString *cityName = self.addrData.cityName;
                    NSString *provinceName = self.addrData.provinceName;
                    if (!cityName || [cityName isEqualToString:kNullStr] || [cityName isEqualToString:@""])
                    {
                        districtStr  = [NSString stringWithFormat:@"%@",provinceName];
                    }
                    else
                    {
                        districtStr  = [NSString stringWithFormat:@"%@%@",provinceName,cityName];
                    }
                    [cell.selBtn setTitle:districtStr forState:(UIControlStateNormal)];
                    [cell.selBtn setTitleColor:NUI_HELPER.appDarkGrayColor forState:(UIControlStateNormal)];
                    
                    self.disContent = districtStr;
                }
                
                if (!self.addrData)
                {
                    [cell.selBtn setTitle:kItemPHArrays[row] forState:(UIControlStateNormal)];
                    //                    cell.selBtn.titleLabel.textColor = NUI_HELPER.appLightGrayColor;
                    [cell.selBtn setTitleColor:UIColorFromHex(0xceced3) forState:(UIControlStateNormal)];
                    
                }
            }
            [cell updateItem:kItemArrays[row]];
            cell.delegate =self;
            return cell;
        }
        else
        {
            
            KSContactTFCell *cell = [tableView dequeueReusableCellWithIdentifier:kScontactTFCell];
            cell.contentTF.placeholder = kItemPHArrays[row];
            if(_isFirst)
            {
                cell.titleConstraintW.constant = self.reasonableW;
                
                if(row == KSAddressPerson)
                {
                    _personTF = cell.contentTF;
                    if (self.addrData && self.addrData.receiverName)
                    {
                        cell.contentTF.text = self.addrData.receiverName;
                    }
                }
                else if (row == KSAddressPhone)
                {
                    //设置为数字键盘
                    cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                    _phoneTF = cell.contentTF;
                    if (self.addrData && self.addrData.receiverMobile)
                    {
                        cell.contentTF.text = self.addrData.receiverMobile;
                    }
                    
                }
                else if (row == KSAddressDetail)
                {
                    _detailTF= cell.contentTF;
                    if (self.addrData && self.addrData.address)
                    {
                        cell.contentTF.text = self.addrData.address;
                    }
                    
                }
                else if (row == KSAddressZip)
                {
                    _zipTF = cell.contentTF;
                    if (self.addrData && self.addrData.zipCode)
                    {
                        cell.contentTF.text = self.addrData.zipCode;
                    }
                    cell.sepView.hidden = YES;
                    _isFirst = NO;
                    [self addObserver];
                }
                
            }
            
            [cell updateItem:row str:kItemArrays[row]];
            cell.delegate =self;
            return cell;
        }
    }
    
    return nil;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
}

#pragma mark - cell delegate
-(void)contactPick:(UIButton*)btn
{
    [self.view endEditing:YES];
    self.cityBtn = btn;
    [self setupCityPicker];
}

#pragma mark - request delegate
-(void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    INFO(@"%@ %@",blEntity,result);
    
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏菊花
        //        [weakself hideProgressHUD];
        if (result.errorCode != 0 && result.errorDescription)
        {
            [weakself.view makeToast:result.errorDescription duration:3.0 position:CSToastPositionCenter];
        }
        
    });
}

-(void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    
    INFO(@"%@ %@",blEntity,result.body);
    
    if ([result.tradeId isEqualToString:KGetArea])
    {
        if (result.body) {
            KSAreaArrayEntity *areaArray = result.body;
            if (areaArray) {
                self.areaArray = areaArray.result;
            }
        }
        
    }
    else if ([result.tradeId isEqualToString:KModifyAddr])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            {
                
                if (result.errorCode == 0)
                {
                    //提示信息
                    //                [self showOperationHUDWithStr:@"修改成功"];
                    void (^comp)() = ^{
                        //跳转到个人中心
                        NSArray *childArray = self.navigationController.childViewControllers;
                        int i;
                        for (i=0; i<childArray.count; i++)
                        {
                            if([childArray[i] isKindOfClass:[KSAccountInfoVC class]])
                                break;
                        }
                        if (i!=childArray.count) {
                            [self.navigationController popToViewController:childArray[i] animated:YES];
                        }
                        
                    };
                    [self showOperationHUDToJumpWithStr:@"修改成功" completion:comp];                //通知去更新个人中心
                    [NOTIFY_CENTER postNotificationName:KAccountInfoChangeNotificationKey object:nil userInfo:nil];
                    
                    INFO(@"保存成功");
                    
                }
                
            }
        });
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity*)result
{
    INFO(@"%@ %@",blEntity,result);
    @WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.view makeToast:KRequestNetworkErrorMessage duration:3.0 position:CSToastPositionCenter];
    });
}
@end
