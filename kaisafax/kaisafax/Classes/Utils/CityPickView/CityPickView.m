//
//  CityPickView.m
//  cityPickView
//
//  Created by jia on 16/10/20.
//  Copyright © 2016年 Jiajingwei. All rights reserved.
//

#import "CityPickView.h"
#import "KSAreaEntity.h"
#import "KSCityEntity.h"
#import <objc/runtime.h>

#define kCityPickViewHeight  (MAIN_BOUNDS_SCREEN_HEIGHT/3+kTitleHeight)
#define kTitleHeight    44
#define kName          @"name"
#define kSonAreaList   @"sonAreaList"
#define kCode   @"code"

typedef NS_ENUM(NSInteger,KSPickType)
{
    KSPickTypeProvince = 0,            //省
    KSPickTypeCity,                    //市
    
    KSPickTypeMax,                     //最大枚举值;
};

@implementation CityPickView
{
    UIPickerView *_cityPickView;
    NSDictionary *_dicInfo; //存储的是整个dic
    NSDictionary *_provinceDic;//选中某个省后，从dicinfo里取出放在这个里面
    NSDictionary *_cityDic;     //选中某个市后，从provinceDic中取出放在这里;
    NSArray *_provinceNameArray;    //所有省市的名字数组
    NSArray *_cityNameArray;        //城市数组
    //    NSArray *_townNameArray;        //城镇array
    
    UIView *_toolsView; //上方的确定取消工具栏
    UIButton *_groundBtn;
}
//- (instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
//        _dicInfo = [NSDictionary dictionaryWithContentsOfFile:path];
//        NSMutableArray *temp = [[NSMutableArray alloc] init];
//        for (int i = 0; i < _dicInfo.allKeys.count; i++) {
//            NSDictionary *dic = [_dicInfo objectForKey:[@(i) stringValue]];
//
//            [temp addObject:dic.allKeys[0]];
//        }
//        _provinceNameArray = temp;//省份数组
//
//        //取第1个省,先取第1个，在用省份名字取
//        _provinceDic = [[_dicInfo objectForKey:[@(0) stringValue]] objectForKey:_provinceNameArray[0]];
//        _cityNameArray = [self getNameforProvince:0];//城市名字数组
//        _townNameArray = [[_provinceDic objectForKey:@"0"] objectForKey:_cityNameArray[0]];
//
//
//        _province = _provinceNameArray[0];
//        _city = _cityNameArray[0];
//       _area = _townNameArray[0];
//
//        _cityPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight+40,self.frame.size.width,kCityPickViewHeight-40)];
//        _cityPickView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        _cityPickView.layer.borderWidth = 0.0;
//        _cityPickView.delegate = self;
//        _cityPickView.dataSource = self;
//        [self addSubview:_cityPickView];
//
//
//        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0,MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight, self.frame.size.width, 40)];
//        _toolsView.layer.borderWidth = 0.5;
//        _toolsView.layer.borderColor = [UIColor grayColor].CGColor;
//        [self addSubview:_toolsView];
//
//        _groundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight)];
//        _groundBtn.backgroundColor = UIColorFromHexA(0, 0.7);
//        [_groundBtn addTarget:self action:@selector(cancelIt) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_groundBtn];
//
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-77, 0, 77, 40)];
//        //button.backgroundColor = [UIColor lightGrayColor];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setTitle:@"确定" forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(selectIt) forControlEvents:UIControlEventTouchUpInside];
//        [_toolsView addSubview:button];
//
//        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 77, 40)];
//        //button.backgroundColor = [UIColor lightGrayColor];
//        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button2 setTitle:@"取消" forState:UIControlStateNormal];
//        [button2 addTarget:self action:@selector(cancelIt) forControlEvents:UIControlEventTouchUpInside];
//        [_toolsView addSubview:button2];
//
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame array:(NSMutableArray*)cityArray{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.backgroundColor = WhiteColor;
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        NSMutableArray *temp2 = [[NSMutableArray alloc] init];
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([KSAreaEntity class], &propertyCount);
        
        for (int i = 0; i < cityArray.count; i++)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSDictionary *dict1 = nil;
            NSMutableArray *temp1 = [[NSMutableArray alloc] init];
            
            KSAreaEntity *area = cityArray[i];
            
            for (int j=0; j < propertyCount; j++ )
            {
                objc_property_t *thisProperty = propertyList + j;
                const char* propertyName = property_getName(*thisProperty);
                NSString *key = [NSString stringWithFormat:@"%s",propertyName];
                id value = [area valueForKey:key];
                
                if(strcmp(propertyName,"sonAreaList")!=0 && value)
                {
                    [dict setObject:value forKey:key];
                }
                else
                {
                    NSArray *array = (NSArray*)value;
                    for (KSCityEntity *entity in array) {
                        dict1 = [entity properties_aps];
                        [temp1 addObject:dict1];
                    }
                }
                //                NSLog(@"Person has a property: '%s'", propertyName);
            }
            [temp addObject:dict];
            [temp2 addObject:temp1];
        }
        
        free(propertyList);
        
        _provinceNameArray = temp;//省份数组
        _cityNameArray = temp2;//城市名字数组
        
        
        _provinceDic = _provinceNameArray[0];
        _cityDic = _cityNameArray[0][0];
        
        _province = [_provinceDic objectForKey:kName];
        _provinceCode = [_provinceDic objectForKey:kCode];
        _city = [_cityDic objectForKey:kName];
        _cityCode = [_cityDic objectForKey:kCode];
        
        //        _area = _townNameArray[0];
        
        _cityPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight+kTitleHeight,self.frame.size.width,kCityPickViewHeight-kTitleHeight)];
        //        _cityPickView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _cityPickView.layer.borderWidth = 0.0;
        _cityPickView.backgroundColor = WhiteColor;
        _cityPickView.delegate = self;
        _cityPickView.dataSource = self;
        [self addSubview:_cityPickView];
        
        
        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0,MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight, self.frame.size.width, kTitleHeight)];
        _toolsView.backgroundColor = WhiteColor;
        _toolsView.layer.borderWidth = 0.5;
        _toolsView.layer.borderColor = UIColorFromHex(0xebebeb).CGColor;
        [self addSubview:_toolsView];
        
        _groundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, MAIN_BOUNDS_SCREEN_HEIGHT-kCityPickViewHeight)];
        _groundBtn.backgroundColor = UIColorFromHexA(0, 0.7);
        [_groundBtn addTarget:self action:@selector(cancelIt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_groundBtn];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-kTitleHeight, 0, kTitleHeight, kTitleHeight)];
        //button.backgroundColor = [UIColor lightGrayColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ic_right_gou"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectIt) forControlEvents:UIControlEventTouchUpInside];
        [_toolsView addSubview:button];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kTitleHeight, kTitleHeight)];
        //button.backgroundColor = [UIColor lightGrayColor];
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [button2 setTitle:@"取消" forState:UIControlStateNormal];
        [button2 setImage:[UIImage imageNamed:@"ic_cancel_x"] forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(cancelIt) forControlEvents:UIControlEventTouchUpInside];
        [_toolsView addSubview:button2];
        
    }
    return self;
}
- (void)selectIt{
    self.confirmblock(_province,_city,_provinceCode,_cityCode);
    //    self.doneBlock(_province,_city,_area);
}
- (void)cancelIt{
    self.cancelblock();
}

- (void)setToolshidden:(BOOL)toolshidden{
    _toolshidden = toolshidden;
    if (_toolshidden) {
        _toolsView.hidden = YES;
    }
}

#pragma mark pickView-delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return _provinceNameArray.count;
    }
    else if (component == 1){
        NSInteger provinceIndex = [self searchIndexWithType:KSPickTypeProvince]; //获取在第几个
        if (provinceIndex >= 0 && provinceIndex < _provinceNameArray.count)
        {
            NSArray *array = _cityNameArray[provinceIndex];
            return array.count;
        }
        else
        {
            return 0;
        }
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row

          forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
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



//返回的是component列的行显示的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)//如果是首字母的那一列
    {
        if (row < 0 && row >= _provinceNameArray.count )
            return nil;
        return [_provinceNameArray[row] objectForKey:kName];
    }
    else//如果选择的是城市那一列
    {
        NSInteger provinceIndex = [self searchIndexWithType:KSPickTypeProvince]; //获取在第几个
        if (provinceIndex < 0 && provinceIndex >= _provinceNameArray.count  ) return nil;
        
        NSArray *cityArray = _cityNameArray[provinceIndex];
        
        if (row < 0 && row >= cityArray.count  ) return nil;
        //返回的是城市那一列的第row的那一行的显示的内容
        return [_cityNameArray[provinceIndex][row] objectForKey:kName];
    }
}

//三级联动从这里开始
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //这里是选中了省-然后根据省获取城市--在根据城市
    if (component == 0 ) {
        
        if(!_provinceNameArray || !_cityNameArray)  return;
        
        if (row < 0 || row >= _provinceNameArray.count) return;
        
        if (_provinceNameArray && _provinceNameArray[row])
        {
            _province = [_provinceNameArray[row] objectForKey:kName];
            _provinceCode =  [_provinceNameArray[row] objectForKey:kCode];
        }

        NSArray *cityArray = _cityNameArray[row];
        if (cityArray.count == 0)
        {
            _city = @"";
            _cityCode =  @"";
            [_cityPickView reloadComponent:1];
            [_cityPickView selectRow:0 inComponent:1 animated:YES];
            return;
        }
        
        if(_cityNameArray && _cityNameArray[row] && _cityNameArray[row][0])
        {
            _city = [_cityNameArray[row][0] objectForKey:kName];
            _cityCode =  [_cityNameArray[row][0] objectForKey:kCode];
            
        }
        
        [_cityPickView reloadComponent:1];
        [_cityPickView selectRow:0 inComponent:1 animated:YES];
        //        _area = _townNameArray[0];
    }else if (component == 1){  //这里是选中市的时候发生的变化
        
        NSInteger provinceIndex = [self searchIndexWithType:KSPickTypeProvince]; //获取在第几个
        if(provinceIndex < 0 || provinceIndex >= _provinceNameArray.count) return;
        
        NSArray *cityArray = _cityNameArray[provinceIndex];
        if(row < 0 || row >= cityArray.count) return;

        _city = [_cityNameArray[provinceIndex][row] objectForKey:kName];
        _cityCode =  [_cityNameArray[provinceIndex][row] objectForKey:kCode];;
        
    }
    
    //    self.confirmblock(_province,_city,_area);
}



- (void)setAddress:(NSString *)address{
    if (address) {
        NSArray *array = [address componentsSeparatedByString:@"-"];
        _province = array[0];
        _city = array[1];
        
        if (!_province) return;
        
        
        
        NSInteger provinceIndex = [self searchIndexWithType:KSPickTypeProvince]; //获取在第几个
        if (provinceIndex >= 0 && provinceIndex < _provinceNameArray.count)
        {
            [_cityPickView reloadComponent:0];
            [_cityPickView selectRow:provinceIndex inComponent:0 animated:YES];
            _provinceDic = _provinceNameArray[provinceIndex];
            _provinceCode = [_provinceDic objectForKey:kCode];
            
            if (!_city || [_city isEqualToString:@"(null)"] || [_city isEqualToString:@""])
            {
                [_cityPickView selectRow:0 inComponent:1 animated:YES];
                [_cityPickView reloadComponent:1];
                return;
            }
            
            NSInteger cityIndex = [self searchIndexWithType:KSPickTypeCity];
            if (cityIndex >= 0 && cityIndex < _provinceNameArray.count)
            {
                [_cityPickView selectRow:cityIndex inComponent:1 animated:YES];
                [_cityPickView reloadComponent:1];
                _cityDic = _cityNameArray[provinceIndex][cityIndex];
                _cityCode = [_cityDic objectForKey:kCode];
                
            }
        }
        
//        _province = [_provinceNameArray[provinceIndex] objectForKey:kName];
//        _city = [_cityNameArray[provinceIndex][0] objectForKey:kName];
    }
}

-(NSInteger)searchIndexWithType:(NSInteger)type
{
    //根据省份查找在第几个，
    int i = 0;
    if(type == KSPickTypeProvince)
    {
        for (i=0 ;i< _provinceNameArray.count; i++)
        {
            NSString *name = [_provinceNameArray[i] objectForKey:kName];
            if([_province isEqualToString:name])
                break;
        }
    }
    else
    {
        NSInteger provinceIndex = [self searchIndexWithType:KSPickTypeProvince]; //获取在第几个
        
        if (provinceIndex >= 0 && provinceIndex < _provinceNameArray.count)
        {
            NSArray *cityArray = _cityNameArray[provinceIndex];
            
            for (i = 0 ;i< cityArray.count; i++)
            {
                NSDictionary *city = cityArray[i];
                NSString *name = [city objectForKey:kName];
                if([_city isEqualToString:name])
                    break;
            }
        }
        else
        {
            return 0;
        }
    }
    NSInteger provinceIndex = i; //获取在第几个
    return provinceIndex;
}

@end
