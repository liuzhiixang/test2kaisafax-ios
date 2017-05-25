//
//  JXError+LocalDescription.m
//

#import "JXError+LocalDescription.h"

@implementation JXError (LocalDescription)

- (NSString *)getLocalDescription {
    return [JXError getLocalDescriptionForErrorType:self.errorCode];
}

+ (NSString *)getLocalDescriptionForErrorType:(JXErrorType)error {
    NSString *desctipStr = nil;
    switch (error) {
        case JXErrorTypeSuccess:
            desctipStr = @"操作成功";
            break;
        case JXErrorTypeOther:
            desctipStr = @"未知错误";
            break;
        case JXErrorTypeNetworkDisconnected:
            desctipStr = @"无网络连接";
            break;
        case JXErrorTypeNetworkTimeout:
            desctipStr = @"网络连接超时";
            break;
        case JXErrorTypeSDKInternal:
            desctipStr = @"SDK内部错误";
            break;
        case JXErrorTypeLoginConflict:
            desctipStr = @"账号在别处被登录";
            break;
        case JXErrorTypeServerInternal:
            desctipStr = @"服务器内部错误";
            break;
        case JXErrorTypeServerShutdown:
            desctipStr = @"服务器被关闭";
            break;
        case JXErrorTypePasswordModified:
            desctipStr = @"密码被修改";
            break;
        case JXErrorTypeUserRemoved:
            desctipStr = @"您的账号已被管理员移除";
            break;
        case JXErrorTypeNoConnection:
            desctipStr = @"与服务端连接未建立";
            break;
        case JXErrorTypeConnectionDisConnection:
            desctipStr = @"与服务端连接已断开";
            break;
        case JXErrorTypeUsernameExist:
            desctipStr = @"用户已存在";
            break;
        case JXErrorTypeUsernameIllegalCharacter:
            desctipStr = @"用户名只能输入字母或数字";
            break;
        case JXErrorTypeUsernameLengthInvalid:
            desctipStr = @"用户名不能超过20字符";
            break;
        case JXErrorTypeAppKeyNotExist:
            desctipStr = @"APPKEY不存在";
            break;
        case JXErrorTypeOrgnameNotExist:
            desctipStr = @"企业ID不存在";
            break;
        case JXErrorTypeRequestParameterInvalid:
            desctipStr = @"请求参数错误";
            break;
        case JXErrorTypeNotRegisterSDK:
            desctipStr = @"没有注册SDK";
            break;
        case JXErrorTypeRegisterSDKFailed:
            desctipStr = @"注册SDK失败";
            break;
        case JXErrorTypeRegisterSDKParameterInvalid:
            desctipStr = @"注册SDK参数错误";
            break;
        case JXErrorTypeOrgnameIllegalCharacter:
            desctipStr = @"公司名含非法字符";
            break;
        case JXErrorTypeAppnameIllegalCharacter:
            desctipStr = @"app名称含非法字符";
            break;
        case JXErrorTypeOrgnameAndAppnameIllegalCharacter:
            desctipStr = @"公司名和app名称含非法字符";
            break;
        case JXErrorTypeAppnameLengthInvalid:
            desctipStr = @"app名称长度超过20字符";
        case JXErrorTypeLoginUserNameEmpty:
            desctipStr = @"用户名为空";
            break;
        case JXErrorTypeLoginPasswordEmpty:
            desctipStr = @"密码为空";
            break;
        case JXErrorTypeLoginUserNameNotExist:
            desctipStr = @"用户名不存在";
            break;
        case JXErrorTypeLoginPasswordError:
            desctipStr = @"密码错误";
            break;
        case JXErrorTypeLoginInvalidUsernameOrPassword:
            desctipStr = @"用户名或密码错误";
            break;
        case JXErrorTypeLoginEmailEmpty:
            desctipStr = @"Email为空";
            break;
        case JXErrorTypeAgentOnlineLimited:
            desctipStr = @"已登录坐席超过既定数量，请联系管理员";
            break;

        //联系人
        case JXErrorTypeContactAddFriendConflict:
            desctipStr = @"已添加为联系人";
            break;
        case JXErrorTypeContactNotYourFriend:
            desctipStr = @"未添加为联系人";
            break;
        case JXErrorTypeBacklistConflict:
            desctipStr = @"联系人已被加入到黑名单";
            break;
        case JXErrorTypeBlockContactFailed:
            desctipStr = @"加入黑名单失败";
            break;
        case JXErrorTypeContactInfoMissing:
            desctipStr = @"联系人信息不全";
            break;

            //消息
        case JXErrorTypeMessageTypeNotDefined:
            desctipStr = @"消息类型未定义";
            break;
        case JXErrorTypeMessageChatTypeNotDefined:
            desctipStr = @"聊天类型未定义";
            break;
        case JXErrorTypeMessageChatTypeNotAllowed:
            desctipStr = @"聊天类型暂不支持";
            break;
        case JXErrorTypeMessageSendFailed:
            desctipStr = @"消息发送失败";
            break;
        case JXErrorTypeMessageObjectMismatch:
            desctipStr = @"消息类型与实体不对应";
            break;
        case JXErrorTypeMessageTitleEmpty:
            desctipStr = @"图文消息标题为空";
            break;
        case JXErrorTypeMessageTextEmpty:
            desctipStr = @"文本消息内容为空";
            break;
        case JXErrorTypeMessageFileNotExist:
            desctipStr = @"文件不存在";
            break;
        case JXErrorTypeMessageFileEmpty:
            desctipStr = @"文件为空";
            break;
        case JXErrorTypeMessageFileTypeMismatch:
            desctipStr = @"文件类型不合法";
            break;
        case JXErrorTypeMessageFileSizeExceeded:
            desctipStr = @"文件大小超出限制";
            break;
        case JXErrorTypeMessageRecordDurationExceeded:
            desctipStr = @"文件时长超出限制";
            break;
        case JXErrorTypeMessageThumbNotExist:
            desctipStr = @"缩略图文件不存在";
            break;
        case JXErrorTypeMessageThumbEmpty:
            desctipStr = @"缩略图文件为空";
            break;
        case JXErrorTypeMessagethumbFailed:
            desctipStr = @"缩略图文件生成失败";
            break;
        case JXErrorTypeConversationNotFound:
            desctipStr = @"缩略图文件生成失败";
            break;
        case JXErrorTypeMessageUploadFailed:
            desctipStr = @"文件上传失败";
            break;
        case JXErrorTypeMessageDownloadFailed:
            desctipStr = @"下载文件失败";
            break;
        case JXErrorTypeMessageReceiverRejected:
            desctipStr = @"对方拒收消息";
            break;
        case JXErrorTypeMessageNotAllowed:
            desctipStr = @"服务端拒绝该消息";
            break;

            //群聊
        case JXErrorTypeGroupChatBlockOperationFailed:
            desctipStr = @"拉入黑名单失败";
            break;
        case JXErrorTypeGroupChatForbidden:
            desctipStr = @"无权限操作群聊";
            break;
        case JXErrorTypeGroupChatUserNotExistInRoom:
            desctipStr = @"用户不在群聊中";
            break;
        case JXErrorTypeGroupChatGetInfoFailed:
            desctipStr = @"获取群信息失败";
            break;
        case JXErrorTypeGroupChatSubjectIllegalCharacter:
            desctipStr = @"群聊主题包含非法字符";
            break;
        case JXErrorTypeGroupChatNicknameIllegalCharacter:
            desctipStr = @"群昵称包含非法字符";
            break;
        case JXErrorTypeGroupChatSubjectForbidden:
            desctipStr = @"禁止修改群名称";
            break;
        case JXErrorTypeGroupChatSameNickname:
            desctipStr = @"群聊中存在相同名称的用户";
            break;
        case JXErrorTypeGroupChatPrivateGroupBanApply:
            desctipStr = @"私有群禁止发送群申请";
            break;
        case JXErrorTypeGroupChatRoomNotExist:
            desctipStr = @"群聊已经不存在";
            break;
        case JXErrorTypeChatroomForbidden:
            desctipStr = @"聊天室成员已达上限";
            break;
        case JXErrorTypeChatroomNotAllowed:
            desctipStr = @"聊天室已被删除或无权限";
            break;
        case JXErrorTypeGroupChatAccessPermissionOwner:
            desctipStr = @"只有群主才有此权限";
            break;
        case JXErrorTypeGroupChatCreatFailed:
            desctipStr = @"创建群聊失败";
            break;
        case JXErrorTypeGroupChatInviteBlockMember:
            desctipStr = @"被邀请成员在黑名单中";
            break;
        //通话
        case JXErrorTypeCallCalleeOffline:
            desctipStr = @"被叫不在线";
            break;
        case JXErrorTypeCallCalleeDeclined:
            desctipStr = @"未接通，被叫拒接";
            break;
        case JXErrorTypeCallHangup:
            desctipStr = @"接通后，正常结束通话";
            break;
        case JXErrorTypeCallCallerCancel:
            desctipStr = @"未接通前，主叫取消呼叫";
            break;
        case JXErrorTypeCallTimeout:
            desctipStr = @"未接通前，被叫无应答，主叫呼叫超时";
            break;
        case JXErrorTypeCallDisconnection:
            desctipStr = @"连接断开";
            break;

            //移动客服
        case JXErrorTypeMcsAccountDisabled:
            desctipStr = @"已登录坐席超过既定数量，请联系管理员";
            break;
        case JXErrorTypeMcsNotInService:
            desctipStr = @"暂无客服人员在线";
            break;
        case JXErrorTypeMcsSkillsIdNotExist:
            desctipStr = @"技能组不存在";
            break;
        case JXErrorTypeMcsHasEvaluation:
            desctipStr = @"邀请已发送不能重复邀请";
            break;
        case JXErrorTypeMcsOverMaxAccess:
            desctipStr = @"最大接入数超出限制";
            break;
        case JXErrorTypeMcsInvalidAccess:
            desctipStr = @"操作失败";
            break;
        case JXErrorTypeMcsSkillsIdEmpty:
            desctipStr = @"技能组ID为空";
            break;
        case JXErrorTypeMcsUserOfflineCantRecall:
            desctipStr = @"无法回呼离线用户";
            break;
        case JXErrorTypeMcsUserInitSuccess:
            desctipStr = @"用户端初始化成功";
            break;
        case JXErrorTypeMcsEnterGroupInOther:
            desctipStr = @"客服已在其他终端进入技能组";
            break;
        case JXErrorTypeMcsRecallReject:
            desctipStr = @"回呼被拒绝";
            break;
        case JXErrorTypeMcsRecallFailedReasonOffline:
            desctipStr = @"用户不在线，回呼失败";
            break;
        case JXErrorTypeMcsRecallFailedReasonBusy:
            desctipStr = @"用户正在通话，回呼失败";
            break;
        case JXErrorTypeMcsRecallFailedReasonQueuing:
            desctipStr = @"用户已在等待队列中";
            break;
        case JXErrorTypeMcsRecallFailedReasonUnknow:
            desctipStr = @"未知错误，回呼失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonOffline:
            desctipStr = @"坐席不在线，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonBusy:
            desctipStr = @"坐席繁忙，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonReject:
            desctipStr = @"会话被拒绝，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonUnknow:
            desctipStr = @"未知错误，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonWorkGroupEmpty:
            desctipStr = @"技能组无客服在线，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonWorkGroupBusy:
            desctipStr = @"技能组繁忙，转接失败";
            break;
        case JXErrorTypeMcsRemarkIsTooLong:
            desctipStr = @"备注过长(140)";
            break;
        case JXErrorTypeMcsVistorMobileExist:
            desctipStr = @"该手机号码已存在";
            break;
        default:
            break;
    }
    return desctipStr;
}

@end
