//
//  KSContactVC.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSContactVC.h"
#import "KSContactTFCell.h"
#import "KSContactPickCell.h"
#import "KSContactBL.h"
#import "KSAccountInfoVC.h"
#import "KSContactEntity.h"

#define kItemArrays   @[@"姓名",@"手机",@"关系"]
#define kItemPHArrays @[@"请填写紧急联系人姓名",@"请填写紧急联系人手机号",@"请选择与联系人关系"]
#define kRelationshipArrays  @{@1:@"父亲",@2:@"母亲",@3:@"哥哥",@4:@"姐姐",@5:@"同学",@6:@"同事",@7:@"其它"}
//#define kContactHeaderTitle  @"仅在紧急情况下联系不到您本人时使用"
#define kToolHeight   44
#define kMargin       15
#define kImgWidth     12

typedef NS_ENUM(NSInteger,KSContact)
{
    KSContactName = 0,            //名字
    KSContactPhone,               //手机号
    KSContactRelationship,        //关系
    
    KSContactMax,                 //最大枚举值;
};

@interface KSContactVC ()<UITableViewDataSource,UITableViewDelegate,KSContactTFCellDelegate,KSContactPickCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource,KSBLDelegate>
@property (weak, nonatomic) IBOutlet UITableView *conTabView;
//@property (nonatomic,copy) NSString *nameContent;
@property (nonatomic,assign) NSInteger relationIdx;
@property (nonatomic,copy) NSString *relationshipContent;
@property (weak, nonatomic) UIButton *relationBtn;
@property (weak, nonatomic) UIPickerView *picker;
@property (weak, nonatomic) UIButton *saveBtn;

@property (strong, nonatomic) KSContactBL *contactBL;
@property (assign, nonatomic) BOOL isFirst;


@property (weak, nonatomic) UITextField *nameTF;
@property (weak, nonatomic) UITextField *phoneTF;

@property (weak, nonatomic) UIView *tipsView;

@end

@implementation KSContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = KEmegencyContactTitle;
    _isFirst = YES;
    
    kRegisterCellNib(_conTabView,kScontactTFCell);
    kRegisterCellNib(_conTabView,kSContactPickCell);

    _conTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _conTabView.backgroundColor = UIColorFromHex(0xebebeb);
    
    [self configHeaderandFooterView];
    
    if(!_contactBL)
    {
        _contactBL = [[KSContactBL alloc]init];
        _contactBL.delegate = self;
    }
}

#pragma mark - load exist data
-(void)addObserver
{
    //手机号
    @WeakObj(self);
    RAC(self.phoneTF, text) = [self.phoneTF.rac_textSignal map:^id(NSString *value) {
        NSString *newValue = value;
        if (value.length > KPhoneNumberLength)
        {
            [weakself showToastWithTitle:KReachedInputMaxLength];
            newValue = [value substringToIndex:KPhoneNumberLength];
        }
        weakself.phoneTF.text = newValue;
        return newValue;
    }];
    
//    RAC(self.nameTF, text) = [self.nameTF.rac_textSignal map:^id(NSString *value) {
//        NSString *newValue = value;
//        if (value.length > KPersonalNameMaxLength)
//        {
//            [weakself showToastWithTitle:KReachedInputMaxLength];
//            newValue = [value substringToIndex:KPersonalNameMaxLength];
//        }
//        weakself.nameTF.text = newValue;
//        return newValue;
//    }];
    
    [[RACSignal combineLatest:@[_phoneTF.rac_textSignal,
                                _nameTF.rac_textSignal,
                                RACObserve(self, relationshipContent)
                                ]
                       reduce:^(NSString *name, NSString *phone, NSString *relationshipContent){
                           INFO(@"name:%@ phone:%@ relation:%@",name,phone,relationshipContent);
                           return @(name.length > 0 && phone.length > 0 && relationshipContent.length>0);
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

    flag = [NSString checkIsPhoneNumber:phone range:NSMakeRange(KPhoneNumberLength, KPhoneNumberLength)];
    return flag;
}

-(void)configHeaderandFooterView
{
    //headerview
    UIView *headerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, kMargin*2+13)];
    headerview.backgroundColor = ClearColor;
    UILabel *headerlabel =[[UILabel alloc]initWithFrame:CGRectMake(kMargin, kMargin,MAIN_BOUNDS_SCREEN_WIDTH, 13)];
    headerlabel.font =[UIFont systemFontOfSize:13.0];
    headerlabel.textColor = NUI_HELPER.appDarkGrayColor;
    headerlabel.text = KContactHeaderTitle;
    [headerview addSubview:headerlabel];
    _conTabView.tableHeaderView = headerview;
    
    //footerview
    UIView *footerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, 85)];
    footerview.backgroundColor = ClearColor;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 41, MAIN_BOUNDS_SCREEN_WIDTH-30, 44)];
    [btn setTitle:KSaveTitle forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(saveAction) forControlEvents:(UIControlEventTouchUpInside)];
    btn.nuiClass = NUIAppOrangeButton;
    [footerview addSubview:btn];
    
    //提示信息
    UIView *tipsView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, MAIN_BOUNDS_SCREEN_WIDTH, 16)];
    tipsView.backgroundColor = ClearColor;
    [footerview addSubview:tipsView];
    

    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, MAIN_BOUNDS_SCREEN_WIDTH-(15), kImgWidth)];
    tipLabel.text = KCorrectPhoneTitle;
    tipLabel.textColor = UIColorFromHex(0xE60012);
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    [tipsView addSubview:tipLabel];
    
    _tipsView= tipsView;
    _tipsView.hidden = YES;
    
    [btn setEnabled:NO];
    _saveBtn = btn;
    _conTabView.tableFooterView = footerview;
    
}

-(void)saveAction
{
    [self.view endEditing:YES];

    if (![self checkMobileBy:_phoneTF.text])
    {
        [self showToastWithTitle:KInputPhoneErrorText];
        _tipsView.hidden = NO;
        return;
    }
    
    if (self.nameTF.text.length>KPersonalNameMaxLength)
    {
        [self showToastWithTitle:KInputNameErrorText];
        return;
    }
    
    if (_contactBL)
    {
        NSInteger row = 0;
        row = self.relationIdx;
        
        if (row <= 0 || row > 7) return;
        [_contactBL doSetContactWithName:_nameTF.text mobile:_phoneTF.text
                                relation:row];

    }
}

#pragma mark - tableview datasource and delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return KSContactMax;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >=0 && row<KSContactMax)
    {
        if (row == KSContactName || row == KSContactPhone) {
            KSContactTFCell *cell = [tableView dequeueReusableCellWithIdentifier:kScontactTFCell];
            [cell updateItem:row str:kItemArrays[row]];
            cell.contentTF.placeholder = kItemPHArrays[row];
            if (_isFirst /*&& self.contactData*/) {
                
                if (row == KSContactName)
                {
                    _nameTF = cell.contentTF;
                    if (self.contactData && self.contactData.name)
                    {
                        cell.contentTF.text = self.contactData.name;
                    }

                }
                else if(row == KSContactPhone)
                {
                    _phoneTF = cell.contentTF;
                    //设置为数字键盘
                    cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                    if (self.contactData && self.contactData.mobile)
                    {
                        cell.contentTF.text = self.contactData.mobile;
                    }

                }

            }

            cell.delegate =self;
            return cell;
        }
        else if (row == KSContactRelationship)
        {
            KSContactPickCell *cell = [tableView dequeueReusableCellWithIdentifier:kSContactPickCell];
            [cell updateItem:kItemArrays[row]];
            cell.sepView.hidden = YES;
 
            if (_isFirst) {
                NSInteger relationIdx = self.contactData.relation;
                if (self.contactData && relationIdx>=1 && relationIdx <= 7) {
                    
                    NSString *value = @"";
                    value = [kRelationshipArrays objectForKey:[NSNumber numberWithInteger:relationIdx]];
                    [cell.selBtn setTitle:value forState:UIControlStateNormal];
                    [cell.selBtn setTitleColor:NUI_HELPER.appDarkGrayColor forState:(UIControlStateNormal)];

                    _relationshipContent = value;
                    self.relationIdx = relationIdx;
                }
                else
                {
                    relationIdx = 0;
                    self.relationIdx = 0;
                }

                if(relationIdx<=0 || relationIdx>7)
                {
                    [cell.selBtn setTitle:kItemPHArrays[row] forState:UIControlStateNormal];
                    [cell.selBtn setTitleColor:UIColorFromHex(0xceced3) forState:(UIControlStateNormal)];
                    
                }

                _isFirst = NO;
                [self addObserver];
            }
            cell.delegate =self;
            return cell;
        }
    }

    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
}

#pragma mark - cell delegate
-(void)contactPick:(UIButton*)btn
{
    [self.view endEditing:YES];
    self.relationBtn = btn;
    INFO(@"%@",NSStringFromCGRect(self.view.bounds));
    
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT)];
    [coverView setBackgroundColor:ClearColor];
    UIButton *coverBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT*2/3-kToolHeight)];
    [coverBtn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [coverBtn addTarget:self action:@selector(cancel) forControlEvents:(UIControlEventTouchUpInside)];
    [coverView addSubview:coverBtn];
    
    UIView *pickview = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_BOUNDS_SCREEN_HEIGHT*2/3-kToolHeight, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT/3+kToolHeight)];
    pickview.backgroundColor = WhiteColor;
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kToolHeight, MAIN_BOUNDS_SCREEN_WIDTH, MAIN_BOUNDS_SCREEN_HEIGHT/3)];
    picker.delegate = self;
    picker.dataSource = self;
    UIView *toolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BOUNDS_SCREEN_WIDTH, kToolHeight)];
    toolbar.backgroundColor = ClearColor;
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kToolHeight, kToolHeight)];
    [cancelBtn setImage:[UIImage imageNamed:@"ic_cancel_x"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cancelBtn];
    
    UIButton *cfmBtn = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_BOUNDS_SCREEN_WIDTH-kToolHeight, 0, kToolHeight, kToolHeight)];
    [cfmBtn setImage:[UIImage imageNamed:@"ic_right_gou"] forState:UIControlStateNormal];
    [cfmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cfmBtn];
    
    UIView *sepView = [[UIView alloc]initWithFrame:CGRectMake(0, kToolHeight-0.5, MAIN_BOUNDS_SCREEN_WIDTH, 0.5)];
    sepView.backgroundColor = UIColorFromHexA(0xa0a0a0, 0.5);
    [toolbar addSubview:sepView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [pickview addSubview:picker];
    [pickview addSubview:toolbar];
    [coverView addSubview:pickview];
    [window addSubview:coverView];
    
    _picker = picker;
}

#pragma 实现UIPickerViewDelegate的协议的方法

//返回的是 选择器的 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回的是每一列的个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //如果是第一列，就是显示首字母的那一列，返回的是存放首字母数组的个数
   return  kRelationshipArrays.count;

}


#pragma 实现UIPickerViewDataSource的协议的方法

//返回的是component列的行显示的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [kRelationshipArrays objectForKey:[NSNumber numberWithInteger:(row+1)]];
}

//如果选中某行，该执行的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    pickerLabel.numberOfLines=0;
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
    
}

#pragma mark - pick action
-(void)cancel
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.subviews.lastObject removeFromSuperview];
}

-(void)confirm
{
    NSInteger row = [_picker selectedRowInComponent:0];
    row+=1;
    
    if (row > kRelationshipArrays.count || row < 0) {
        return;
    }
    
    if (self.contactData)
    {
        self.contactData.relation = row;
    }

    self.relationIdx = row;
    
    
    
    NSString *title =[kRelationshipArrays objectForKey:[NSNumber numberWithInteger:row]];
    [self.relationBtn setTitle:title forState:(UIControlStateNormal)];
    [self.relationBtn setTitleColor:NUI_HELPER.appDarkGrayColor forState:(UIControlStateNormal)];

    self.relationshipContent = title;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.subviews.lastObject removeFromSuperview];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([result.tradeId isEqualToString:KModifyContactor])
        {
            
            if (result.errorCode == 0)
            {
                //提示信息
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
                [self showOperationHUDToJumpWithStr:@"修改成功" completion:comp];
                //通知去更新个人中心
                [NOTIFY_CENTER postNotificationName:KAccountInfoChangeNotificationKey object:nil userInfo:nil];

                INFO(@"保存成功");

            }
            
        }
    });
    

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
