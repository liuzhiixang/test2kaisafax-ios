//
//  KSMoreVC.m
//  kaisafax
//
//  Created by semny on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSMoreVC.h"
#import "KSWebVC.h"


@interface KSMoreVC ()

@property (strong, nonatomic) NSArray *listArray;

@end

@implementation KSMoreVC
-(NSArray *)listArray
{
    if (!_listArray)
    {
//        NSString *path  = [[NSBundle mainBundle]pathForResource:@"more" ofType:@"plist"];
        NSArray *array = [NSArray arrayWithContentsOfFile:PathForPlist(@"more")];
        self.listArray = array;
        
    }
    return _listArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"关于我们";

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return  ((KSMoreIDMax-1) / KSMoreIDQuestion + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger secNum = 0;
    if (section == 0)
    {
        secNum = KSMoreIDQuestion;
    }
    else
    {
        secNum = KSMoreIDMax-1-KSMoreIDQuestion;
    }
    
    return secNum;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    INFO(@"%@",self.listArray);
    
    NSInteger index = (indexPath.section == 0)?indexPath.row:(KSMoreIDQuestion+indexPath.row);
    NSDictionary *dict = self.listArray[index];
    //1.创建cell
    static NSString *identifier = @"more";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    //2.给cell赋值
    cell.textLabel.nuiClass = NUIAppNormalDarkGrayLabel;
    cell.detailTextLabel.nuiClass = NUIAppSmallLightGrayLabel;

    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = dict[@"description"];
    //else
    //{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //3.返回cell
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    if (indexPath.section == 0)
    {
        NSString *urlStr = @"";
        switch (indexPath.row+1) {
            case KSMoreIDAboutUS:
                urlStr = KAboutUSPage;
                break;
            case KSMoreIDSafety:
                urlStr = KSafetyPage;
                break;
            case KSMoreIDQuestion:
                urlStr = KQuestionPage;
                break;
                
            default:
                break;
        }
        
        if(![urlStr isEqualToString:@""])
            [KSWebVC pushInController:self.navigationController urlString:urlStr title:_listArray[indexPath.row+1][@"title"] type:KSWebSourceTypeAccount];
    }
    else
    {
//        NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel:%@",_listArray[KSMoreIDQuestion][@"description"]];
//        UIWebView * callWebview = [[UIWebView alloc] init];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//        [self.view addSubview:callWebview];
        
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_listArray[KSMoreIDQuestion][@"description"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0;
}



@end
