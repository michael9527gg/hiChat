//
//  HistorySearchCell.m
//  hiChat
//
//  Created by Polly polly on 28/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "HistorySearchCell.h"

@interface HistorySearchCell()

@end

@implementation HistorySearchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style
                   reuseIdentifier:reuseIdentifier]) {
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.backgroundColor = [UIColor lightGrayColor];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconView);
            make.left.equalTo(self.iconView.mas_right).offset(8);
        }];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.textColor = [UIColor lightGrayColor];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        [CONTENT_VIEW addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
            make.left.equalTo(self.nameLabel);
        }];
    }
    
    return self;
}

- (void)setData:(id)data {
    _data = data;
    
    NSString *portrait = nil;
    NSString *name = nil;
    
    if([data isKindOfClass:[RCSearchConversationResult class]]) {
        RCSearchConversationResult *result = (RCSearchConversationResult *)data;
        RCConversation *conversation = result.conversation;
        if(conversation.conversationType == ConversationType_PRIVATE) {
            ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:conversation.targetId];
            portrait = contact.portraitUri;
            name = contact.name;
        } else if(conversation.conversationType == ConversationType_GROUP) {
            GroupData *group = [[GroupDataSource sharedInstance] groupWithGroupid:conversation.targetId];
            portrait = group.portrait;
            name = group.name;
        }
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:nil
                                completed:nil];
        
        self.nameLabel.text = name;
        self.detailLabel.text = [NSString stringWithFormat:@"%d条相关的记录", result.matchCount];
        
    } else if([data isKindOfClass:[RCMessage class]]) {
        RCMessage *message = (RCMessage *)data;
        RCTextMessage *textContent = (RCTextMessage *)message.content;
        
        if(message.conversationType == ConversationType_PRIVATE) {
            ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:message.targetId];
            portrait = contact.portraitUri;
            name = contact.name;
        } else if(message.conversationType == ConversationType_GROUP) {
            GroupData *group = [[GroupDataSource sharedInstance] groupWithGroupid:message.targetId];
            portrait = group.portrait;
            name = group.name;
        }
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:nil
                                completed:nil];
        
        self.nameLabel.text = name;
        self.detailLabel.text = textContent.content;
    }
}

@end
