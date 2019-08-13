//
//  UserSelectHeader.m
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "UserSelectHeader.h"

@interface UserSelectHeader() < UISearchBarDelegate >

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton    *bottomBtn;

@end

@implementation UserSelectHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorFromHex:0xe6e6e6];
        
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.placeholder = @"搜索";
        searchBar.delegate = self;
        [self addSubview:searchBar];
        [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@64);
        }];
        self.searchBar = searchBar;
        
        UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomBtn setTitleColor:[UIColor darkGrayColor]
                        forState:UIControlStateNormal];
        bottomBtn.layer.cornerRadius = 22;
        bottomBtn.layer.masksToBounds = YES;
        bottomBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bottomBtn.layer.borderWidth = .5f;
        [bottomBtn addTarget:self
                      action:@selector(touchAllMembers:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bottomBtn];
        
        [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(24);
            make.top.equalTo(searchBar.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(120, 44));
            make.bottom.equalTo(self).offset(-12);
        }];
        
        self.bottomBtn = bottomBtn;
    }
    
    return self;
}

- (void)setShowMentionAll:(BOOL)showMentionAll {
    _showMentionAll = showMentionAll;
    
    if(!showMentionAll) {
        self.bottomBtn.hidden = YES;
        
        [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@64);
            make.bottom.equalTo(self);
        }];
    }
}

- (void)setSelectPurpose:(ContactSelectPurpose)selectPurpose {
    _selectPurpose = selectPurpose;
    
    switch (selectPurpose) {
        case ContactSelectPurposeStartChat:
        case ContactSelectPurposeMessageForward: {
            self.bottomBtn.hidden = YES;
            [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.equalTo(self);
                make.right.equalTo(self);
                make.height.equalTo(@64);
                make.bottom.equalTo(self);
            }];
        }
            break;
        case ContactSelectPurposeCreateGroup:
        case ContactSelectPurposeOneKey:
        case ContactSelectPurposeMessageForwardForStaff:
        case ContactSelectPurposeInviteGroupMember: {
            [self.bottomBtn setTitle:@"全选" forState:UIControlStateNormal];
            [self.bottomBtn setTitle:@"取消全选" forState:UIControlStateSelected];
        }
            break;
        case ContactSelectPurposeMentionSomebody: {
            [self.bottomBtn setTitle:@"@全体成员" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)touchAllMembers:(UIButton *)button {
    switch (self.selectPurpose) {
        case ContactSelectPurposeStartChat: {
            
        }
            break;
        case ContactSelectPurposeCreateGroup:
        case ContactSelectPurposeOneKey:
        case ContactSelectPurposeMessageForwardForStaff:
        case ContactSelectPurposeInviteGroupMember: {
            button.selected = !button.selected;
            [self.delegate userChooseSelectAll:button.selected];
        }
            break;
        case ContactSelectPurposeMentionSomebody: {
            [self.delegate userChooseAllMember];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.delegate searchWithText:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.delegate searchWithText:searchBar.text];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    NSLog(@"searchText: %@", searchText);
    
    [self.delegate searchWithText:searchText];
}

@end
