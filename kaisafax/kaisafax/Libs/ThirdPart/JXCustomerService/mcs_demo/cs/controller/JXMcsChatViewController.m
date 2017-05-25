//
//  JXMcsChatViewController.m
//

#import "JXMcsChatViewController.h"
#import "JXMsgBoxViewController.h"

#import "JXAppConfig+Extends.h"
#import "JXChatViewController+MessageSend.h"
#import "JXChatViewController+Toolbar.h"
#import "JXWebViewController.h"

#import "JXCommandView.h"
#import "JXEvalMessageCell.h"
#import "JXTipView.h"
#import "NSTimer+Category.h"

//#import "JXBadgeButton.h"
//#import "JXHistoricalVisitManager.h"
//#import "JXHistoryInfoView.h"
#import "JXMCSUserManager.h"

#import "MJRefresh.h"

#define transAgentTypeTag 100
#define resendMessageTag 101
#define transRobotTag 102
#define submitReviewTag 103
#define endSessionTag 104

#define extendData @"jiaxintest"

@interface JXMcsChatViewController ()<UIAlertViewDelegate, JXCommandViewDelegate,
JXChatViewControllerDelegate/*, JXHistoryInfoViewDelegate*/>

@property(nonatomic, strong) UIButton *changeCSBtn;
//@property(nonatomic, strong) JXBadgeButton *msgBoxBtn;
@property(nonatomic, strong) JXTipView *tipView;
@property(nonatomic, strong) UIImageView *onlineImage;
@property(nonatomic, strong) JXCommandView *commandView;

@property(nonatomic, assign) BOOL showTipView;
@property(nonatomic, assign) BOOL isRobot;
@property(nonatomic, assign) BOOL hasRobot;        // 判断是否有机器人变量
@property(nonatomic, assign) BOOL hasEvaluated;    // 是否已经评价过变量

@property(nonatomic, strong) JXWorkgroup *workgroup;
@property(nonatomic, strong) JXMessage *evaluationRequest;
@property(nonatomic, strong) JXMessage *resendMessage;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, copy) NSString *lastForeseeText;
@property(nonatomic, copy) NSString *serviceNickname;
@property(nonatomic, copy) dispatch_block_t submitReviewBlock;

@end

@implementation JXMcsChatViewController

- (instancetype)initWithWorkgroup:(JXWorkgroup *)workgroup {
    JXConversation *conversation =
    [sClient.chatManager conversationForChatter:workgroup.serviceID andType:JXChatTypeCS];
    if (self = [super initWithConversation:conversation]) {
        self.hidesBottomBarWhenPushed = YES;
        _workgroup = workgroup;
        self.allowVoiceChat = [JXAppConfig sharedInstance].userSendAudioFlag;
        self.allowEmojiChat = [JXAppConfig sharedInstance].userEmoticonFlag;
        self.title = workgroup.displayName;
        _isRobot = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRightItem];
    self.changeCSBtn.userInteractionEnabled = NO;
    self.delegate = self;
    
    [self setupTableViewRefreshHeader];
    [self loadAndRequire];
    // 监听消息箱未读数的变化
//    [[JXMCSUserManager sharedInstance] addObserver:self
//                                        forKeyPath:@"unreadMessageCount"
//                                           options:NSKeyValueObservingOptionNew
//                                           context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self showMsgBoxUnreadTip];
}

- (void)viewDidPop {
    [super viewDidPop];
    [sJXHUD hideHUD];
    if (_timer) {
        [self sendForeseeMessage:nil];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc {
    NSLog(@"******dealloc controller class:%@************", [self class]);
//    [[JXMCSUserManager sharedInstance] removeObserver:self forKeyPath:@"unreadMessageCount"];
}

#pragma mark - UI 定义区

#pragma mark 设置navigationBar相关方法

// 返回标题栏title
- (NSAttributedString *)titleStringWith:(NSString *)title andImage:(UIImage *)image {
    if (!image) {
        return [[NSMutableAttributedString alloc] initWithString:title];
    }
    NSString *text = [NSString stringWithFormat:@"  %@", title];
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:text];

    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    textAttachment.image = image;

    NSAttributedString *imageStr =
    [NSAttributedString attributedStringWithAttachment:textAttachment];
    [ret replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:imageStr];
    return ret;
}

/**
 *  设置标题栏
 *
 *  @param isInService 客服是否在线
 *  @param title  标题文本
 */
- (void)setupTitleViewWithOnlineStatus:(BOOL)isInService andTitle:(NSString *)title {
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (!label) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
    }
    if (!title) return;
    if (isInService) {
        label.attributedText = [self titleStringWith:title andImage:JXChatImage(@"online")];
    } else {
        label.attributedText = [self titleStringWith:title andImage:nil];
    }
    [label sizeToFit];
}

// 请求人工按钮
- (void)setupRightItem {
    _changeCSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeCSBtn addTarget:self
                     action:@selector(transferCustomerService)
           forControlEvents:UIControlEventTouchUpInside];
    [_changeCSBtn setImage:JXChatImage(@"changeCS") forState:UIControlStateNormal];

//    _msgBoxBtn = [JXBadgeButton buttonWithType:UIButtonTypeCustom];
//    [_msgBoxBtn addTarget:self
//                   action:@selector(openMsgBox)
//         forControlEvents:UIControlEventTouchUpInside];
//    [_msgBoxBtn setImage:JXChatImage(@"msgBox") forState:UIControlStateNormal];
//    _msgBoxBtn.badgeValue = [NSString
//                             stringWithFormat:@"%zd", [JXMCSUserManager sharedInstance].unreadMessageCount];

//    _msgBoxBtn.size = CGSizeMake(28, 28);
    _changeCSBtn.size = CGSizeMake(28, 28)/*_msgBoxBtn.size*/;

//    UIBarButtonItem *msgBoxItem = [[UIBarButtonItem alloc] initWithCustomView:_msgBoxBtn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_changeCSBtn];
    [self.navigationItem setRightBarButtonItems:@[ /*msgBoxItem, */rightItem ]];
}

// 设置右上角按钮样式
- (void)setupChangeCSBtnWithInService:(BOOL)isInService andIsHidden:(BOOL)hidden {
    if (!_changeCSBtn) return;
    _changeCSBtn.hidden = hidden;
    if (isInService) {
        [_changeCSBtn setImage:JXChatImage(@"quiteChat") forState:UIControlStateNormal];
        [_changeCSBtn addTarget:self
                         action:@selector(terminateSession)
               forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_changeCSBtn addTarget:self
                         action:@selector(transferCustomerService)
               forControlEvents:UIControlEventTouchUpInside];
        [_changeCSBtn setImage:JXChatImage(@"changeCS") forState:UIControlStateNormal];
    }
}

#pragma mark toolBar相关方法

//设置ChatToolbar中moreView的类型
- (void)setupToolbarItemsWithStatus:(JXMCSUserStatus)status {
    self.messageToolbar.moreView = nil;
    [self.messageToolbar endEditing:YES];
    self.messageToolbar.isHiddenRecordBtn = YES;
    self.messageToolbar.isHiddenEmojiBtn = YES;
    WEAKSELF;
    if ([[JXMCSUserManager sharedInstance] quickQuestions].count) {
        [self toolbarAddCustomItemWithTitle:@"快捷提问"
                                   andImage:JXChatImage(@"more_question")
                                  andAction:^(NSInteger index) {
                                      [weakSelf showCommandView:NO];
                                  }];
    }

    switch (status) {
        case JXMCSUserStatusInService: {
            // 判断是否开启访客主动满意度
            if ([JXAppConfig sharedInstance].visitorSatisfyFlag) {
                [self toolbarAddCustomItemWithTitle:@"满意度评价"
                                           andImage:JXChatImage(@"more_comment")
                                          andAction:^(NSInteger index) {
                                              [weakSelf showCommandView:YES];
                                          }];
            }
        }
        case JXMCSUserStatusAgentOffline:
        case JXMCSUserStatusWaiting: {
            self.messageToolbar.isHiddenRecordBtn = !self.allowVoiceChat;
            self.messageToolbar.isHiddenEmojiBtn = NO;
            [self toolbarAddCameraItemWithTitle:@"拍照" andImage:JXChatImage(@"more_photo")];
            [self toolBarAddPhotoItemWithTitle:@"相册" andImage:JXChatImage(@"more_image")];
//            if ([JXAppConfig sharedInstance].userSendVideoFlag) {
//                [self toolbarAddVideoItemWithTitle:@"小视频" andImage:JXChatImage(@"eye")];
//            }
            // FIXME: demo 最近浏览
//            [self toolbarAddCustomItemWithTitle:@"最近浏览"
//                                       andImage:JXImage(@"more_oldbrowse")
//                                      andAction:^(NSInteger index) {
//                                          [weakSelf showHistoryView];
//                                      }];
        } break;
        default:
            break;
    }
}

#pragma mark tipView相关方法

/**
 *  显示tipView
 *
 */
- (void)setShowTipView:(BOOL)showTipView {
    if (_showTipView == showTipView) {
        return;
    }
    _showTipView = showTipView;
    if (showTipView) {
        [self.view addSubview:self.tipView];
        [self.view bringSubviewToFront:self.tipView];
    } else {
        [self.tipView removeFromSuperview];
        self.tipView = nil;
    }
    self.messageToolbar.hidden = NO;
}

- (void)setIsRobot:(BOOL)isRobot {
    _isRobot = isRobot;
    [_changeCSBtn setHidden:!self.isRobot];
}

/**
 *  展示快捷提问或满意度评价view
 *
 *  @param isEval 是否为满意度评价
 */
- (void)showCommandView:(BOOL)isEval {
    [self.messageToolbar endEditing:YES];
    if (_commandView) [_commandView hideView];

    NSString *title;
    id model;
    if (isEval) {
        title = @"满意度评价";
        model = [[JXMCSUserManager sharedInstance] evaluation];
    } else {
        title = @"快捷提问";
        model = [[JXMCSUserManager sharedInstance] quickQuestions];
    }
    _commandView = [[JXCommandView alloc] initWithTtile:title delegate:self model:model];
    [self.messageToolbar resignFirstResponder];
    [_commandView showInView:self.view];
}

#pragma mark - UI内容控制

// 设置下拉刷新
- (void)setupTableViewRefreshHeader {
    // 从服务端加载更多消息
    WEAKSELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        JXMessage *firstMsg = self.dataSource.count ? self.dataSource[1] : nil;
        [sClient.mcsManager
         fetchChatLogForConversation:self.conversation
         withLimit:20
         fromMessage:firstMsg
         withCallBack:^(NSArray *historyMessages, JXError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.tableView.mj_header endRefreshing];
                 if (error) {
                     JXLog(@"%@", [error description]);
                 } else {
                     BOOL refresh = firstMsg ? NO : YES;
                     [weakSelf insertHistoryMessages:historyMessages
                                             refresh:refresh];
                 }
             });
         }];
    }];
}

// 加载消息并请求服务
- (void)loadAndRequire {
    WEAKSELF;
    [self loadMessagesBefore:nil];
    [weakSelf showMessageWithActivityIndicator:@"正在接入"];
    if (!self.dataSource.count && !self.conversation.messageIds.count) {
        [sClient.mcsManager
         fetchChatLogForConversation:self.conversation
         withLimit:20
         fromMessage:nil
         withCallBack:^(NSArray *historyMessages, JXError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error) {
                     JXLog(@"%@", [error description]);
                 } else {
                     [weakSelf insertHistoryMessages:historyMessages
                                             refresh:YES];
                 }
                 [sClient.mcsManager requestCustomerService:_workgroup];
             });
         }];
    } else {
        [sClient.mcsManager requestCustomerService:_workgroup];
    }
}

// 插入本地提示消息
- (void)addTipsMessage:(NSString *)content {
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setTipsContent:content];
    [self addMessage:message];
}

// 插入本地系统消息
- (void)addTempMessage:(NSString *)content {
    JXMessage *message = [[JXMessage alloc] initWithSender:@"系统消息" andType:JXChatTypeCS];
    [message setTextContent:content];
    message.extData[@"isSystem"] = @(1);
    [self addMessage:message];
}

// 请求人工客服
- (void)transferCustomerService {
    if (self.isRobot) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"切换客服类型"
                                                            message:@"切换到人工客服？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = transAgentTypeTag;
        [alertView show];
    }
}

// 关闭会话
- (void)terminateSession {
    if ([JXAppConfig sharedInstance].satisfyNotifyFlag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结束会话"
                                                            message:@"是否结束当前会话?"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = endSessionTag;
        [alertView show];
    }
}

// 在线留言
- (void)leaveMessageOnline {
    [[JXMCSUserManager sharedInstance] leaveMessageOnlineForUI:self workgroup:self.workgroup];
    [sClient.mcsManager cancelWait];
}

#if 0
// 显示未读消息通知
- (void)showMsgBoxUnreadTip {
    if (![JXMCSUserManager sharedInstance].unreadMessageCount) {
        self.showTipView = NO;
        return;
    } else if (self.showTipView) {
        return;
    }
    
    JXTipView *tipView = self.tipView;
    tipView.contentString = @"您有未读留言，请点击";
    
    NSDictionary *attDict =
    @{
      NSForegroundColorAttributeName : [UIColor grayColor],
       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
      };
    NSAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"查看"
                                                                        attributes:attDict];
    
    [tipView addAttributedString:attStr withTarget:self andAction:@selector(openMsgBox)];
    tipView.identify = @"msgbox";
    tipView.showCloseBtn = YES;
    self.showTipView = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.tipView.identify isEqualToString:@"msgbox"]) {
            self.showTipView = NO;
        }
    });
}

// 重写父类发送文本消息方法
- (void)sendTextMessage:(NSString *)text {
    // 发送文字消息前发送取消输入消息
    if (self.workgroup.status == JXMCSUserStatusInService &&
        [JXAppConfig sharedInstance].prepareFlag) {
        [self sendForeseeMessage:nil];
    }

    [super sendTextMessage:text];
}

// 打开消息盒子
- (void)openMsgBox {
    JXMsgBoxViewController *msgBoxVC = [[JXMsgBoxViewController alloc] init];
    [self.navigationController pushViewController:msgBoxVC animated:YES];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger count = [change[NSKeyValueChangeNewKey] integerValue];
        self.msgBoxBtn.badgeValue = [NSString stringWithFormat:@"%zd", count];
        
        [self showMsgBoxUnreadTip];
    });
}
#endif
#pragma mark - JXChatViewControllerDelegate

// 发送失败按钮点击事件
- (void)statusButtonSelcted:(JXMessage *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否重发该消息?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"是", nil];
    alertView.tag = resendMessageTag;
    self.resendMessage = message;
    [alertView show];
}

- (CGFloat)chatViewController:(JXChatViewController *)sender
             heightForMessage:(JXMessage *)message
                    withWidth:(CGFloat)cellWidth {
    if (message.type == JXMessageTypeEvaluation) {
        return [JXEvalMessageCell cellHeightForMessage:message];
    }
    return 0;
}

- (UITableViewCell *)chatViewController:(JXChatViewController *)sender
                         cellForMessage:(JXMessage *)message {
    if (message.type == JXMessageTypeEvaluation) {
        static NSString *evalCellID = @"JXEvalMessageCell";
        JXEvalMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:evalCellID];
        if (!cell) {
            cell = [[JXEvalMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:evalCellID
                                                    message:message];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.message = message;
        return cell;
    }
    return nil;
}

- (void)messageCellSelected:(JXMessage *)message {
    [super messageCellSelected:message];
    if ((NSInteger)message.type == JXMessageTypeEvaluation) {
        if (self.isRobot) {
            [sJXHUD showLongTextMessage:@"机器人无法接收文本以外的消息"
                               duration:1.0
                                 inView:self.view];
            return;
        }
        self.evaluationRequest = message;
        [self showCommandView:YES];
    }
}

// 自定义消息头像，昵称 等
- (void)chatViewController:(JXChatViewController *)sender loadingMessage:(JXMessage *)message {
    if (message.type == JXMessageTypeTips) return;
    if (message.isSender) {
        message.avatarImage = JXChatImage(@"head_sender");
    } else {
        message.avatarImage = JXChatImage(@"head_receiver");
        if (message.isRobot) {
            message.nickname = @"机器人";
        } else if (message.extData[@"isSystem"] || message.extData[@"type"]) {
            message.nickname = @"系统消息";
        } else {
            //            message.nickname = _workgroup.serviceNickname;
            message.nickname = message.sender;
        }
        JXAppConfig *appConfig = [JXAppConfig sharedInstance];
        message.avatarImage =
        appConfig.agentIconImage ? appConfig.agentIconImage : JXChatImage(@"head_receiver");
    }
}

#pragma mark - JXMCSManagerDelegate - JXClientDelegate

// 服务状态改变
- (void)didServiceStatusUpdated:(JXWorkgroup *)workgroup {
    JXMCSUserStatus status = workgroup.status;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUD];
        [self setupChangeCSBtnWithInService:NO andIsHidden:NO];
        [self setupToolbarItemsWithStatus:workgroup.status];

        self.changeCSBtn.userInteractionEnabled = YES;
        self.isRobot = NO;
        self.hasEvaluated = NO;

        BOOL showTip = NO;
        BOOL hideToolbar = NO;

        switch (status) {
            case JXMCSUserStatusInRobot: {
                hideToolbar = NO;
                self.isRobot = YES;
                self.hasRobot = YES;
                if (workgroup.serviceNickname) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:@"佳信机器人客服"];
                }
            } break;
            case JXMCSUserStatusAgentOffline: {
                hideToolbar = YES;
                [self setupChangeCSBtnWithInService:YES andIsHidden:NO];
                if ([JXMCSUserManager sharedInstance].isInService) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.displayName];
                }
                [JXMCSUserManager sharedInstance].isInService = NO;
                return;
            } break;
            case JXMCSUserStatusWaiting: {
                hideToolbar = NO;
                [_changeCSBtn setHidden:YES];
                if (![JXMCSUserManager sharedInstance].isInService) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.displayName];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                }
                [JXMCSUserManager sharedInstance].isInService = NO;
                return;
            } break;
            case JXMCSUserStatusInService: {
                hideToolbar = NO;
                // FIXME: 发送商品信息
//                [self sendItemInfoMessage];
                
                [self setupTitleViewWithOnlineStatus:YES andTitle:workgroup.serviceNickname];
                [self setupChangeCSBtnWithInService:YES andIsHidden:NO];
                if (![JXMCSUserManager sharedInstance].isInService && ![self.serviceNickname isEqualToString:workgroup.serviceNickname]) {
                    [self addTempMessage:[NSString stringWithFormat:
                                          @"您好，客服%@正在为您服务",
                                          workgroup.serviceNickname]];
                    self.serviceNickname = workgroup.serviceNickname;
                }
                [JXMCSUserManager sharedInstance].isInService = YES;

            } break;
            case JXMCSUserStatusInRecall: {
                hideToolbar = NO;
                [self.messageToolbar setHidden:NO];
            } break;
            case JXMCSUserStatusEnd: {
                hideToolbar = YES;
            } break;
            default:
                break;
        }

        self.showTipView = showTip;
        self.messageToolbar.hidden = hideToolbar;
    });
}

// 服务结束
- (void)didServiceEnd:(JXWorkgroup *)workgroup withError:(JXError *)error {
    //    WEAKSELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        JXErrorType type = error.errorCode;
        self.serviceNickname = workgroup.displayName;
        [JXMCSUserManager sharedInstance].isInService = NO;
        [self hideHUD];
        switch (type) {
            case JXErrorTypeMcsInvalidAccess:
            case JXErrorTypeMcsSkillsIdNotExist:
            case JXErrorTypeMcsNotInServiceWithLeave: {
                [sJXHUD showMessage:[error getLocalDescription] duration:1.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [self popSelf];
                               });

            } break;
            case JXErrorTypeMcsNotInService: {
                UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:@"不好意思，当前无客服在线"
                                          delegate:self
                                 cancelButtonTitle:@"退出"
                                 otherButtonTitles:@"在线留言", nil];
                alertView.tag = transRobotTag;
                [alertView show];
            } break;
            case JXErrorTypeMcsNotInServiceWithRobot: {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:@"不好意思，当前无客服在线"
                                          delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"在线留言", @"转机器人客服", nil];
                alertView.tag = transRobotTag;
                [alertView show];

            } break;
            case JXErrorTypeMcsChatTimeout: {
                [self setupChangeCSBtnWithInService:NO andIsHidden:YES];
            }
            case JXErrorTypeMcsDestorySessionSuccess: {
                [self addTipsMessage:@"会话已结束"];
                [self.messageToolbar setHidden:YES];
                [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                [self.view endEditing:YES];
            } break;
            case JXErrorTypeMcsCancelWait: {
                [sJXHUD showMessage:@"取消等待" duration:1.0 inView:self.view];
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            } break;
            case JXErrorTypeMcsLeaveQueue: {
                [sJXHUD showMessage:@"坐席繁忙" duration:1.0];
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    self.messageToolbar.hidden = YES;
                }

            } break;
            case JXErrorTypeMcsAgentOffWork: {
                JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
                [message setTextContent:error.errorDescription];
                message.extData[@"isSystem"] = @(1);
                message.direction = JXMessageDirectionReceive;
                [self addMessage:message];
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:@"不好意思，当前无客服在线"
                                          delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"在线留言", @"转机器人客服", nil];
                alertView.tag = transRobotTag;
                [alertView show];
                self.isRobot = YES;
            } break;
            case JXErrorTypeMcsRequestTimeout: {
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [self popSelf];
                                   });
                }
            } break;
            default:
                break;
        }
    });
}

// 等待队列的状态更新
- (void)didService:(JXWorkgroup *)workgroup positionChanged:(NSInteger)position {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUD];
        if (position < 1) {
            return;
        }

        NSString *content = [NSString
                             stringWithFormat:@"当前等待位置%ld 放弃接入请点击", (long)position];
        NSMutableAttributedString *cancelString =
        [[NSMutableAttributedString alloc] initWithString:@"取消"];
        NSMutableAttributedString *leaveString =
        [[NSMutableAttributedString alloc] initWithString:@"留言"];

        [cancelString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor grayColor]
                             range:NSMakeRange(0, cancelString.length)];
        [leaveString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor grayColor]
                            range:NSMakeRange(0, leaveString.length)];
        [cancelString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                             range:NSMakeRange(0, cancelString.length)];
        [leaveString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                            range:NSMakeRange(0, leaveString.length)];

        JXTipView *tipView = self.tipView;
        tipView.identify = @"service";
        tipView.showCloseBtn = NO;
        tipView.contentString = content;
        if (self.showTipView == NO) {
            [tipView addAttributedString:cancelString
                              withTarget:sClient.mcsManager
                               andAction:@selector(cancelWait)];
            [tipView addAttributedString:leaveString
                              withTarget:self
                               andAction:@selector(leaveMessageOnline)];
        }
        self.showTipView = YES;
    });
}

// 收到评价请求
- (void)didReceiveEvaluationRequest:(JXWorkgroup *)workgroup {
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    message.direction = JXMessageDirectionReceive;
    // 判断是否显示邀请语
    JXMcsEvaluation *evaluation = [JXMCSUserManager sharedInstance].evaluation;
    NSString *judgeText = evaluation.satisfyInviteFlag ? evaluation.title : @"满意度调查";

    [message setTextContent:judgeText];
    [message setCustomMessageType:JXMessageTypeEvaluation];
    message.extData[@"isSystem"] = @(1);

    [self addMessage:message];
}

#pragma mark - JXMessageToolbarDelegate

// 输入框内值改变
- (void)inputTextViewDidValueChange:(JXMessageTextView *)inputTextView {
    if ([JXAppConfig sharedInstance].prepareFlag == 0) return;
    if (self.workgroup.status != JXMCSUserStatusInService) return;

    if (inputTextView.text.length <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self sendForeseeMessage:nil];
    } else {
        [self.timer fire];
    }
}

#pragma mark - JXCommandViewDelegate

- (void)didfinishedCommandWithScore:(int)score {
    WEAKSELF;
    dispatch_block_t block = ^{
        [sJXHUD showMessageWithActivityIndicatorView:@"正在提交"];
        [sClient.mcsManager
         evaluateService:weakSelf.workgroup
         andScore:score
         andCallback:^(JXError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [sJXHUD hideHUD];
                 if (error) return;
                 if ([JXMCSUserManager sharedInstance].evaluation.satisfyThanksFlag) {
                     [weakSelf addTempMessage:[JXMCSUserManager sharedInstance]
                      .evaluation.thanksMsg];
                 }
                 [weakSelf.commandView hideView];
                 [weakSelf removeMessage:weakSelf.evaluationRequest];
                 weakSelf.hasEvaluated = YES;
             });
         }];
    };
    self.submitReviewBlock = block;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交评论"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认", nil];
    alertView.tag = submitReviewTag;
    [alertView show];
}

- (void)didSelectedQuestion:(NSString *)question {
    self.messageToolbar.inputTextView.text = question;
    [self.messageToolbar.inputTextView becomeFirstResponder];
    [_commandView hideView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == transAgentTypeTag) {
        if (buttonIndex == 1) {
            self.showTipView = NO;
            [sClient.mcsManager transferCustomerService];
            //            [sClient.mcsManager transferCustomerServiceWithExtendData:extendData];
        }
    } else if (alertView.tag == resendMessageTag) {
        if (buttonIndex == 1) {
            [self resendMessage:self.resendMessage];
        }
    } else if (alertView.tag == transRobotTag) {
        if (buttonIndex == 0) {
            [self popSelf];
        } else if (buttonIndex == 1) {
            [self leaveMessageOnline];
            if (!self.hasRobot) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    } else if (alertView.tag == submitReviewTag) {
        if (buttonIndex == 1) {
            self.submitReviewBlock();
        }
    } else if (alertView.tag == endSessionTag) {
        if (buttonIndex == 1) {
            [sClient.mcsManager leaveService];
            if ([JXAppConfig sharedInstance].endSessionSatisfyFlag && self.hasEvaluated == NO) {
                [self didReceiveEvaluationRequest:self.workgroup];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - getter

- (NSTimer *)timer {
    if (!_timer) {
        WEAKSELF;
        _timer = [NSTimer
                  scheduledTimerWithTimeInterval:1.f
                  block:^{
                      if (weakSelf.messageToolbar.text.length &&
                          ![weakSelf.messageToolbar.text
                            isEqualToString:
                            weakSelf.lastForeseeText]) {
                              weakSelf.lastForeseeText =
                              weakSelf.messageToolbar.text;
                              [weakSelf sendForeseeMessage:
                               weakSelf.lastForeseeText];
                          }
                  }
                  repeats:YES];
    }
    return _timer;
}

// 当前队列提示view
- (JXTipView *)tipView {
    if (_tipView == nil) {
        _tipView = [[JXTipView alloc] init];
        _tipView.frame = CGRectMake(0, 0, self.view.width, 30);
        WEAKSELF;
        [_tipView setClosedComplete:^(JXTipView *tipview) {
            weakSelf.showTipView = NO;
        }];
    }
    return _tipView;
}

#pragma mark
#pragma mark - demo (可删除或重写)

// demo 用于发送商品信息
//- (void)sendItemInfoMessage {
//    if ([JXHistoricalVisitManager sharedInstance].isSendItem && !self.isRobot) {
//        NSArray *items = [[JXHistoricalVisitManager sharedInstance] loadFakeHistoricalGoods];
//        JXItemModel *item = items.lastObject;
//        [self sendRichMessageWithImage:item.image
//                                 title:item.name
//                               content:item.info
//                                   url:@"http://www.jiaxincloud.com"];
//        [[JXHistoricalVisitManager sharedInstance] setIsSendItem:NO];
//    }
//}

// demo 用于展示最近浏览
//- (void)showHistoryView {
//    NSArray *goods = [[JXHistoricalVisitManager sharedInstance] loadFakeHistoricalGoods];
//    JXHistoryInfoView *hInfoView =
//    [[JXHistoryInfoView alloc] initWithTtile:@"最近浏览" delegate:self items:goods];
//
//    [self.view.window addSubview:hInfoView];
//}

//#pragma mark JXHistoryInfoViewDelegate
//
//// demo 最近浏览被点击
//- (void)didSelectedInfoWithItem:(JXItemModel *)item {
//    [self sendRichMessageWithImage:item.image
//                             title:item.name
//                           content:item.info
//                               url:@"http://www.jiaxincloud.com"];
//}

@end
