//
//  ConversationViewController.m
//  hiChat
//
//  Created by Polly polly on 14/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ConversationViewController.h"
#import "PrivateSettingViewController.h"
#import "GroupSettingViewController.h"
#import "ContactDetailViewController.h"
#import "UIView+VI.h"
#import "GroupMemberSelectViewController.h"
#import "ConversationSettingDataSource.h"
#import "MessageForwardViewController.h"
#import "StaffMessageForwardViewController.h"
#import "UIImage+HiChat.h"
#import <UIImage+GIF.h>
#import "PhotoViewer.h"
#import <UIImage+MultiFormat.h>
#import "MessageSendManager.h"

#define MentionAllString @"所有人 "
#define RecallString     @"撤回"

typedef enum : NSUInteger {
    GroupRoleLord,
    GroupRoleAdmin,
    GroupRoleMember,
} GroupRole;

@interface ConversationViewController () < VIDataSourceDelegate, GroupMemberSelectDelegate, RCTextViewDelegate, RCChatSessionInputBarControlDelegate >

@property (nonatomic, strong)   ConversationSettingData *setting;
@property (nonatomic, strong)   RCMessageModel          *messageModel;

@property (nonatomic, weak)     GroupDataSource         *dataSource;
@property (nonatomic, copy)     NSString                *dataKey;

@property (nonatomic, strong)   RCMentionedInfo         *mentionedAll;
@property (nonatomic, strong)   NSMutableDictionary     *gifImages;
@property (nonatomic, strong)   NSMutableSet            *trashMessages;

@property (nonatomic, strong)   UIMenuItem              *copyyItem;
@property (nonatomic, strong)   UIMenuItem              *forwardItem;
@property (nonatomic, strong)   UIMenuItem              *recallItem;
@property (nonatomic, strong)   UIMenuItem              *deleteItem;

@property (nonatomic, copy)     void (^selectedBlock)(RCUserInfo *);

@end

@implementation ConversationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self addObservers];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.enableNewComingMessageIcon = YES;
    
    self.enableUnreadMessageIcon = YES;
    
    self.displayConversationTypeArray = @[@(ConversationType_GROUP),
                                          @(ConversationType_PRIVATE)];
    
    [self notifyUpdateUnreadMessageCount];
    
    self.chatSessionInputBarControl.delegate = self;
    
//    self.gifImages = [NSMutableDictionary dictionary];
    
    self.trashMessages = [NSMutableSet set];
    
    [self refreshSettingData];
    
    [self refreshRightBtn];
    
    // 检查会话能力
    [self checkMessageAbility];
    
    // 检查当前会话有效性
    if(self.conversationType == ConversationType_PRIVATE) {
        [self checkFriendRelation];
    } else if(self.conversationType == ConversationType_GROUP) {
        [self checkGroupExist];
    }
    
    // 会话页面强制刷新个人和群组信息缓存
    if(self.conversationType == ConversationType_PRIVATE) {
        [[UserManager manager] refreshRCUserInfoCacheWithUserid:self.targetId
                                                       userInfo:nil
                                                     completion:nil];
    } else if(self.conversationType == ConversationType_GROUP) {
        [[GroupManager manager] refreshRCGroupInfoCacheWithGroupid:self.targetId];
    }
    
    // 刷新下当前用户信息
    [[UserManager manager] refreshCurrentUserInfo];
    
    // 群组成员信息只能这里更新，融云不会主动强刷用户信息缓存，这里我们急需用户信息数据刷新消息每条cell
    if(self.conversationType == ConversationType_GROUP) {
        [self registerDataBase];
        [[GroupManager manager] requesGroupMembersWithGroupId:self.targetId
                                                   completion:nil];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMessage:)
                                                 name:CONVERSATION_CLEAR_MESSAGE_NOTIFIACTION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBlackListNotification:)
                                                 name:CONTACT_UPDATE_BLACKLIST_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFriendNotification:)
                                                 name:CONTACT_UPDATE_FRIEND_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupBlackNotification:)
                                                 name:GROUP_UPDATE_BLACKLIST_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDisplaynameNotification:)
                                                 name:CONTACT_UPDATE_DISPALYNAME_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupMembersNotification:)
                                                 name:GROUP_UPDATE_MEMBERSLIST_NOTIFICATION
                                               object:nil];
    
    
    [self.navigationItem addObserver:self
                          forKeyPath:@"rightBarButtonItems"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSArray *array = [change valueForKey:NSKeyValueChangeNewKey];
    if([array isKindOfClass:[NSNull class]] || !array.count) {
        [self refreshRightBtn];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 数据库初始化消息能力配置
    [self refreshSettingData];
}

- (UIMenuItem *)copyyItem {
    if(!_copyyItem) {
        _copyyItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                action:@selector(touchCopy)];
    }
    return _copyyItem;
}

- (UIMenuItem *)forwardItem {
    if(!_forwardItem) {
        _forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发"
                                                  action:@selector(touchForward)];
    }
    return _forwardItem;
}

- (UIMenuItem *)deleteItem {
    if(!_deleteItem) {
        _deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除"
                                                 action:@selector(touchDelete)];
    }
    return _deleteItem;
}

- (UIMenuItem *)recallItem {
    if(!_recallItem) {
        _recallItem  = [[UIMenuItem alloc] initWithTitle:@"撤回"
                                                  action:@selector(touchRecall)];
    }
    return _recallItem;
}

- (void)refreshSettingData {
    self.setting = [ConversationSettingData conversationSettingWithType:self.conversationType
                                                               targetId:self.targetId];
}

- (void)registerDataBase {
    self.dataSource = [GroupDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[GroupMemberEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"groupid == %@", self.targetId]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"groupRole" ascending:NO],
                                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                   sectionNameKeyPath:nil
                                  key:self.dataKey];
}

- (GroupRole)groupRoleForUserid:(NSString *)userid {
    GroupMemberData *member = [[GroupDataSource sharedClient] groupMemberWithUserd:userid
                                                                           groupid:self.targetId];
    if(member.isLord) {
        return GroupRoleLord;
    } else if(member.isAdmin) {
        return GroupRoleAdmin;
    } else {
        return GroupRoleMember;
    }
}

- (void)updateDisplaynameNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *userid = [userInfo valueForKey:@"userid"];
    NSString *displayName = [userInfo valueForKey:@"displayName"];
    
    if([userid isEqualToString:self.targetId] &&
       (self.conversationType == ConversationType_PRIVATE)) {
        self.title = displayName;
    }
}

- (void)updateGroupBlackNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *groupid = [userInfo valueForKey:@"groupid"];
    NSArray *userids = [userInfo valueForKey:@"userids"];
    if(self.conversationType == ConversationType_GROUP &&
       [self.targetId isEqualToString:groupid]) {
        for(NSString *userid in userids) {
            if([userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
                [self checkMessageAbility];
            }
        }
    }
}

- (void)updateBlackListNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *userid = [userInfo valueForKey:@"userid"];
    
    // 拉黑人和被拉黑人都要检查会话能力
    if(([self.targetId isEqualToString:userid] ||
        [YUCLOUD_ACCOUNT_USERID isEqualToString:userid]) &&
       self.conversationType == ConversationType_PRIVATE) {
        [self checkMessageAbility];
    }
}

- (void)updateFriendNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *userid = [userInfo valueForKey:@"userid"];
    
    if([self.targetId isEqualToString:userid] &&
       self.conversationType == ConversationType_PRIVATE) {
        [self checkFriendRelation];
    }
}

- (void)updateGroupMembersNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *groupid = [userInfo valueForKey:@"groupId"];
    
    if([self.targetId isEqualToString:groupid] &&
       self.conversationType == ConversationType_GROUP) {
        [[GroupManager manager] requesGroupMembersWithGroupId:groupid
                                                   completion:nil];
    }
}

- (void)checkMessageAbility {
    [[ContactsManager manager] checkMessageAbilityForConversation:self.conversationType
                                                           target:self.targetId
                                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           NSNumber *code = [info valueForKey:@"code"];
                                                           if(success) {
                                                               self.setting.canMessage = YES;
                                                           } else if([code isEqual:@1019]) {
                                                               self.setting.canMessage = NO;
                                                           }
                                                           
                                                           // 没有网络不作处理
                                                           if(success || [code isEqual:@1019]) {
                                                               self.setting.messageError = [info msg];
                                                               [[ConversationSettingDataSource sharedClient] addObject:self.setting
                                                                                                            entityName:[ConversationSettingEntity entityName]];
                                                           }
                                                       }];
}

- (void)checkGroupExist {
    [[GroupManager manager] requesGroupInfoWithGroupId:self.targetId
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                NSString *reason = YUCLOUD_VALIDATE_STRING([info valueForKey:@"reason"]);
                                                if(!success && [reason isEqualToString:@"notExist"]) {
                                                    [YuAlertViewController showAlertWithTitle:nil
                                                                                      message:[info msg]
                                                                               viewController:self
                                                                                      okTitle:YUCLOUD_STRING_OK
                                                                                     okAction:^(UIAlertAction * _Nonnull action) {
                                                                                         [[RCManager manager] removeConversation:ConversationType_GROUP
                                                                                                                        targetId:self.targetId];
                                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                                     }
                                                                                  cancelTitle:nil
                                                                                 cancelAction:nil
                                                                                   completion:nil];
                                                }
                                            }];
}

- (void)checkFriendRelation {
    ContactsManager *manager = [ContactsManager manager];
    [manager checkFriendRelationBetweenUser:self.targetId
                                 completion:^(BOOL success, NSDictionary * _Nullable info) {
                                     NSString *reason = YUCLOUD_VALIDATE_STRING([info valueForKey:@"reason"]);
                                     if(!success && [reason isEqualToString:@"noRelation"]) {
                                         // 确定好友关系不存在，先从本地数据库删除，然后刷新融云用户信息缓存（因为融云的用户信息缓存是优先使用的好友信息）
                                         ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:self.targetId];
                                         if(contact) {
                                             [[ContactsDataSource sharedClient] deleteObject:contact];
                                         }
                                         [[UserManager manager] refreshRCUserInfoCacheWithUserid:self.targetId
                                                                                        userInfo:nil
                                                                                      completion:nil];
                                         [[RCManager manager] removeConversation:ConversationType_PRIVATE
                                                                        targetId:self.targetId];
                                         
                                         [YuAlertViewController showAlertWithTitle:nil
                                                                           message:@"对方已不是您的好友"
                                                                    viewController:self
                                                                           okTitle:YUCLOUD_STRING_OK
                                                                          okAction:^(UIAlertAction * _Nonnull action) {
                                                                              [self.navigationController popViewControllerAnimated:YES];
                                                                          }
                                                                       cancelTitle:nil
                                                                      cancelAction:nil
                                                                        completion:nil];
                                     } else if(!success && [reason isEqualToString:@"onlyYouRelation"]) {
                                         [YuAlertViewController showAlertWithTitle:nil
                                                                           message:info[@"msg"]
                                                                    viewController:self
                                                                           okTitle:YUCLOUD_STRING_OK
                                                                          okAction:^(UIAlertAction * _Nonnull action) {
                                                                              [self.navigationController popViewControllerAnimated:YES];
                                                                          }
                                                                       cancelTitle:nil
                                                                      cancelAction:nil
                                                                        completion:nil];
                                     }
                                 }];
}

- (void)refreshRightBtn {
    NSString *setImageStr = self.conversationType == ConversationType_PRIVATE ? @"ic_private_set" : @"ic_group_set";
    UIImage *privateImage = [[UIImage imageNamed:setImageStr] imageResized:24];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:privateImage
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(touchSet)]];
}

- (void)touchSet {
    if(self.conversationType == ConversationType_PRIVATE) {
        PrivateSettingViewController *privateVC = [[PrivateSettingViewController alloc] initWithUserId:self.targetId];
        [self.navigationController pushViewController:privateVC animated:YES];
    } else {
        GroupSettingViewController *groupVC = [[GroupSettingViewController alloc] initWithGroupId:self.targetId];
        [self.navigationController pushViewController:groupVC animated:YES];
    }
}

- (void)clearHistoryMessage:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationDataRepository removeAllObjects];
        [self.conversationMessageCollectionView reloadData];
    });
}

- (void)touchCopy {
    RCTextMessage *textMessage = (RCTextMessage *)self.messageModel.content;
    [UIPasteboard generalPasteboard].string = textMessage.content;
    [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                        withResult:YES
                         labelText:@"已复制至剪切板"
                         delayHide:YES
                        completion:nil];
}

- (void)touchDelete {
    if(self.messageModel && self.messageModel.messageId) {
        [self deleteMessage:self.messageModel];
    }
}

- (void)touchRecall {
    if(self.messageModel && self.messageModel.messageId) {
        [self recallMessage:self.messageModel.messageId];
    }
}

- (void)touchForward {
    RCMessageContent *message = self.messageModel.content;
    
    UIViewController *vc = nil;
    if([AccountManager manager].isSpecialOrStaff) {
        StaffMessageForwardViewController *staffForward = [[StaffMessageForwardViewController alloc] init];
        staffForward.message = message;
        vc = staffForward;
    } else {
        MessageForwardViewController *forward = [[MessageForwardViewController alloc] init];
        forward.message = message;
        vc = forward;
    }
    
    [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:vc]
                       animated:YES
                     completion:nil];
}

- (NSString *)formatStrForTime:(long long)sendTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE HH:mm";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sendTime];
    
    return [formatter stringFromDate:date];
}

- (void)dealloc {
    if(self.trashMessages.count) {
        BOOL result = [[RCIMClient sharedRCIMClient] deleteMessages:self.trashMessages.allObjects];
        
        if(!result) {
            NSLog(@"垃圾消息删除失败！！！");
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.navigationItem.observationInfo) {
        [self.navigationItem removeObserver:self
                                 forKeyPath:@"rightBarButtonItems"];
    }
}

#pragma mark - 会话页面相关

- (void)sendMessage:(RCMessageContent *)messageContent
        pushContent:(NSString *)pushContent {
    if([[MessageSendManager manager] checkMessageFrequencyOverrun:FrequencyOverrunSend] ||
       [[MessageSendManager manager] checkDuplicatedMessage:messageContent]) {
        return;
    }
    else if([messageContent isKindOfClass:[RCImageMessage class]]) {
        [self sendMediaMessage:messageContent
                   pushContent:nil
                     appUpload:YES];
        
        return;
    }
    
    [super sendMessage:messageContent pushContent:pushContent];
}

- (void)uploadMedia:(RCMessage *)message
     uploadListener:(RCUploadMediaStatusListener *)uploadListener {
    RCImageMessage *imageMsg = (RCImageMessage *)message.content;
    
    NSData *uploadData = nil;
    NSString *imageExt = @"jpg";
//    if(imageMsg.extra.length) {
//        uploadData = [self.gifImages valueForKey:imageMsg.extra];
//        imageExt = @"gif";
//    }
//    else {
        UIImage *image = [UIImage imageWithData:imageMsg.originalImageData];
        // 纠正图片方向
        image = [image normalizedImage];
        // 压缩尺寸
        image = [image imageResized:2048];
        // 压缩质量
        uploadData = UIImageJPEGRepresentation(image, .75);
//    }
    
    [[UploadManager manager] uploadData:uploadData
                                fileExt:imageExt
                               progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                                   uploadListener.updateBlock((CGFloat)completedBytes/totalBytes*100);
                               }
                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                 if(success) {
                                     RCImageMessage *content = (RCImageMessage *)uploadListener.currentMessage.content;
                                     content.imageUrl = info[@"url"];
                                     uploadListener.successBlock(content);
                                     
                                     NSLog(@"%@", info[@"url"]);
                                 } else {
                                     uploadListener.errorBlock(-1);
                                 }
                             }];
}

- (void)didTapCellPortrait:(NSString *)userId {
    if([userId isEqualToString:YUCLOUD_ACCOUNT_USERID]) return;
    
    NSString *groupid = nil;
    if(self.conversationType == ConversationType_GROUP) {
        groupid = self.targetId;
    }
    ContactDetailViewController *detail = [[ContactDetailViewController alloc] initWithUserid:userId
                                                                                         user:nil
                                                                                      groupid:groupid];
    [self.navigationController pushViewController:detail animated:YES];
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    if(!self.setting.canMessage) {
        [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                            withResult:NO
                             labelText:self.setting.messageError?:@"您不能发送消息"
                             delayHide:YES
                            completion:nil];
    }
    else if(self.mentionedAll) {
        messageContent.mentionedInfo = self.mentionedAll;
    }
    else if(messageContent.mentionedInfo &&
            [messageContent isKindOfClass:[RCTextMessage class]] &&
            (self.conversationType == ConversationType_GROUP)) {
        RCTextMessage *textMessage = (RCTextMessage *)messageContent;
        // 替换@的用户显示信息: 备注->昵称
        NSString *content = textMessage.content;
        for(NSString *userid in messageContent.mentionedInfo.userIdList) {
            ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:userid];
            if(contact.displayName) {
                content = [content stringByReplacingOccurrencesOfString:contact.displayName
                                                             withString:contact.nickname];
            }
        }
        
        textMessage.content = content;
    }
    
    return self.setting.canMessage?messageContent:nil;
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {
    if(self.mentionedAll) {
        self.mentionedAll = nil;
    }
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell
                   atIndexPath:(NSIndexPath *)indexPath {
    if([cell isKindOfClass:[RCTipMessageCell class]]) {
        RCTipMessageCell *tipCell = (RCTipMessageCell *)cell;
        // 撤回通知消息类
        // 1. 任何用户自己主动撤回自己消息的小灰条，自己和其他群成员都要可见
        // 2. 管理员撤回其他群成员消息的小灰条，所有管理员要可见，普通群成员不可见
        if([cell.model.content isKindOfClass:[RCRecallNotificationMessage class]]) {
            RCRecallNotificationMessage *recallMessage = (RCRecallNotificationMessage *)cell.model.content;
            if(![recallMessage.operatorId isEqualToString:YUCLOUD_ACCOUNT_USERID] &&
               ([self groupRoleForUserid:YUCLOUD_ACCOUNT_USERID] == GroupRoleMember) &&
               ![recallMessage.operatorId isEqualToString:cell.model.senderUserId]) {
                tipCell.tipMessageLabel.text = [self formatStrForTime:cell.model.sentTime];
                [self.trashMessages addObject:@(cell.model.messageId)];

                return;
            }
        }
        // 兼容旧版的群组通知小灰条
        else if([cell.model.content isKindOfClass:[RCInformationNotificationMessage class]]) {
            RCInformationNotificationMessage *notiMessage = (RCInformationNotificationMessage *)cell.model.content;
            if([notiMessage.message containsString:RecallString] &&
               ![cell.model.senderUserId isEqualToString:YUCLOUD_ACCOUNT_USERID] &&
               ([self groupRoleForUserid:YUCLOUD_ACCOUNT_USERID] == GroupRoleMember)) {
                tipCell.tipMessageLabel.text = [self formatStrForTime:cell.model.sentTime];
                [self.trashMessages addObject:@(cell.model.messageId)];

                return;
            }
        }
    }
    // 添加GIF图片支持
//    if([cell isKindOfClass:[RCImageMessageCell class]]) {
//        RCImageMessage *imageMessage = (RCImageMessage *)cell.model.content;
//        NSString *imageUrl = imageMessage.imageUrl;
//        if([imageUrl hasSuffix:@".gif"]) {
//            UIImageView *pictureView = [cell valueForKey:@"_pictureView"];
//            if(pictureView) {
//                // 优先取缩略图，提升加载速度
//                __block NSData *data = nil;
//                NSString *base64 = [imageMessage valueForKey:@"_thumbnailBase64String"];
//
//                // 由于SDK默认针对GIF图片的处理是和普通图片一样，结果就是只取第一帧
//                // 所以extra这里设计用来当做桥梁，避开SDK的默认处理，负责传递自定义的GIF缩略图转base64结果
//                if(imageMessage.extra.length) {
//                    data = [[NSData alloc] initWithBase64EncodedString:imageMessage.extra
//                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                    pictureView.image = [UIImage sd_imageWithGIFData:data];
//                }
//                else if(base64.length) {
//                    data = [[NSData alloc] initWithBase64EncodedString:base64
//                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                    pictureView.image = [UIImage sd_imageWithGIFData:data];
//                }
//                else {
//                    // 兼容意外情况，如果gif不携带缩略图的问题
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:imageUrl];
//                        if(!cacheImage) {
//                            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//                            cacheImage = [UIImage sd_imageWithGIFData:data];
//                            [[SDImageCache sharedImageCache] storeImage:cacheImage
//                                                                 forKey:imageUrl
//                                                             completion:nil];
//                        }
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            pictureView.image = cacheImage;
//                        });
//                    });
//                }
//            }
//        }
//    }
    
    if(cell.model.conversationType == ConversationType_GROUP) {
        // 消息cell
        if([cell isKindOfClass:[RCMessageCell class]]) {
            RCMessageCell *messageCell = (RCMessageCell *)cell;
            // 群主管理员变色
            GroupRole groupRole = [self groupRoleForUserid:cell.model.senderUserId];
            if(groupRole == GroupRoleLord) {
                messageCell.nicknameLabel.textColor = [UIColor redColor];
            } else if(groupRole == GroupRoleAdmin) {
                messageCell.nicknameLabel.textColor = [UIColor orangeColor];
            } else {
                messageCell.nicknameLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
}

- (void)didTapMessageCell:(RCMessageModel *)model {
    if([model.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)model.content;
        [PhotoViewer showImage:imageMessage.imageUrl];
        
        return;
    }
    
    [super didTapMessageCell:model];
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    self.messageModel = model;
    
    NSMutableArray *mulArr = [NSMutableArray array];
    
    if([model.content isKindOfClass:[RCTextMessage class]]) {
        [mulArr addObject:self.copyyItem];
    }
    [mulArr addObject:self.deleteItem];
    
    // 暂时文本和图片消息提供转发功能
    if([model.content isKindOfClass:[RCTextMessage class]] ||
       [model.content isKindOfClass:[RCImageMessage class]]) {
        [mulArr addObject:self.forwardItem];
    }
    
    if(model.conversationType == ConversationType_PRIVATE &&
       [model.senderUserId isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        // 私聊消息2分钟内可以撤回
        NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 - model.sentTime/1000;
        AccountInfo *info = [AccountManager manager].accountInfo;
        if([info.role isSpecialUser] && timeInterval < 60 * 2) {
            [mulArr addObject:self.recallItem];
        }
    }
    else if(model.conversationType == ConversationType_GROUP) {
        GroupRole curGroupRole = [self groupRoleForUserid:YUCLOUD_ACCOUNT_USERID];
        
        // 当前用户为管理员或者群主
        if(curGroupRole != GroupRoleMember) {
            [mulArr addObject:self.recallItem];
        }
        // 自己
        else if([model.senderUserId isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
            // 自己发的群组消息2分钟内可以撤回
            NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 - model.sentTime/1000;
            AccountInfo *info = [AccountManager manager].accountInfo;
            if([info.role isSpecialUser] && timeInterval < 60 * 2) {
                [mulArr addObject:self.recallItem];
            }
        }
    }
    
    return mulArr;
}

- (void)showChooseUserViewController:(void (^)(RCUserInfo *))selectedBlock
                              cancel:(void (^)(void))cancelBlock {
    if(self.conversationType == ConversationType_GROUP) {
        [self.view endEditing:YES];
        
        GroupMemberSelectViewController *select = [[GroupMemberSelectViewController alloc] initWithGroupid:self.targetId];
        select.delegate = self;
        select.allowMulSelect = NO;
        select.purpose = ContactSelectPurposeMentionSomebody;
        
        [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:select]
                           animated:YES
                         completion:nil];
        
        self.selectedBlock = selectedBlock;
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.conversationMessageCollectionView reloadData];
}

#pragma mark - GroupMemberSelectDelegate

- (void)selectWithMembers:(NSArray *)contacts {
    if(contacts) {
        GroupMemberData *data = [[GroupDataSource sharedClient] groupMemberWithUserd:contacts.firstObject
                                                                             groupid:self.targetId];
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:data.userid
                                                             name:data.nickname
                                                         portrait:data.portraitUri];
        self.selectedBlock(userInfo);
    }
    else {
        NSMutableString *mulText = [NSMutableString stringWithString:self.chatSessionInputBarControl.inputTextView.text];
        [mulText appendString:MentionAllString];
        self.chatSessionInputBarControl.inputTextView.text = mulText;
        
        self.mentionedAll = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All
                                                                userIdList:nil
                                                          mentionedContent:nil];
        
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    }
}

- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if(self.mentionedAll && ![inputTextView.text containsString:MentionAllString]) {
        self.mentionedAll = nil;
    }
    
    [super inputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - RCChatSessionInputBarControlDelegate

- (void)presentViewController:(UIViewController *)viewController functionTag:(NSInteger)functionTag {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)imageDataDidSelect:(NSArray *)selectedImages fullImageRequired:(BOOL)full {
    for(NSData *data in selectedImages) {
        RCImageMessage *imageMessage = [RCImageMessage messageWithImageData:data];
        
        if([[MessageSendManager manager] detectQRImage:[UIImage imageWithData:data]]) {
            [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                withResult:NO
                                 labelText:@"图片发送失败"
                                 delayHide:YES
                                completion:nil];
            
            continue;
        }
//        else if([[UIImage imageWithData:data] sd_imageFormat] == SDImageFormatGIF) {
//            NSData *compressionData = [UIImage compressGIFWithData:data
//                                                          cropSize:CGSizeMake(100, 100)
//                                                     maxImageCount:8
//                                                           quality:.7];
//            NSString *base64 = [compressionData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//            imageMessage.extra = base64;
//            imageMessage.imageUrl = @".gif";
//            [self.gifImages setObject:data forKey:base64];
//        }
        
        [self sendMessage:imageMessage pushContent:nil];
    }
}

@end
