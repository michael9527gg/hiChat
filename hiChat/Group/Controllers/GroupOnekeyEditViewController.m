//
//  GroupOnekeyEditViewController.m
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupOnekeyEditViewController.h"
#import "GroupIconCell.h"
#import "OnekeyImageCell.h"
#import "OnkeyTextEditView.h"
#import <LYCocoaDevKit/UICollectionViewCell+LYCocoaDevKit.h>

@interface GroupOnekeyEditViewController () < OnekeyImageCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MessageSendManagerDelegate >

@property (nonatomic, strong) NSArray           *data;
@property (nonatomic, assign) OnekeyEditType    onekeyEditType;

@property (nonatomic, strong) UICollectionView  *groupsView;
@property (nonatomic, strong) OnkeyTextEditView *textView;
@property (nonatomic, strong) UICollectionView  *imagesView;
@property (nonatomic, strong) NSMutableArray    *imagesArr;
@property (nonatomic, strong) UIButton          *keyboardBtn;

@property (nonatomic, assign) CGFloat           groupCellWidth;
@property (nonatomic, assign) BOOL              showMore;
@property (nonatomic, assign) BOOL              isDeleting;

@end

@implementation GroupOnekeyEditViewController

- (instancetype)initWithOnekeyEditType:(OnekeyEditType)onekeyEditType
                                  data:(NSArray *)data {
    if(self = [super init]) {
        self.onekeyEditType = onekeyEditType;
        self.data = data;
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    flowLayout.minimumLineSpacing = 0;
//    flowLayout.minimumInteritemSpacing = 0;
//
//    CGFloat padding = 2;
//    CGFloat width = ([UIScreen mainScreen].bounds.size.width-padding*2)/8.0;
//    NSInteger num = self.data.count/8;
//    if(self.data.count%8 > 0) {
//        num++;
//    }
//
//    // 最多显示4行
//    if(num > 4) self.showMore = YES;
//    CGFloat height = width*MIN(num, 4);
//    self.groupCellWidth = width;
//
//    self.groupsView = [[UICollectionView alloc] initWithFrame:CGRectZero
//                                         collectionViewLayout:flowLayout];
//    self.groupsView.backgroundColor = [UIColor whiteColor];
//    self.groupsView.delegate = self;
//    self.groupsView.dataSource = self;
//    self.groupsView.scrollEnabled = NO;
//    [self.groupsView registerClass:[GroupIconCell class]
//        forCellWithReuseIdentifier:[GroupIconCell reuseIdentifier]];
//    [view addSubview:self.groupsView];
//    [self.groupsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(view).offset(padding);
//        make.left.equalTo(view).offset(padding);
//        make.right.equalTo(view).offset(-padding);
////        make.height.equalTo(@(height));
//        make.height.equalTo(@0);
//    }];
    
//    UILabel *topLabel = [[UILabel alloc] init];
//    topLabel.text = @"文本内容";
//    topLabel.textColor = [UIColor lightGrayColor];
//    [view addSubview:topLabel];
//    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.groupsView.mas_bottom).offset(8);
//        make.left.equalTo(view).offset(4);
//    }];
    
//    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
//    fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    fl.minimumLineSpacing = 12;
//    fl.minimumInteritemSpacing = 12;
//    self.imagesView = [[UICollectionView alloc] initWithFrame:CGRectZero
//                                         collectionViewLayout:fl];
//    self.imagesView.backgroundColor = [UIColor whiteColor];
//    self.imagesView.delegate = self;
//    self.imagesView.dataSource = self;
//    [self.imagesView registerClass:[OnekeyImageCell class]
//        forCellWithReuseIdentifier:[OnekeyImageCell reuseIdentifier]];
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                                                              action:@selector(longGestureAction:)];
//    [self.imagesView addGestureRecognizer:longGesture];
//    [view addSubview:self.imagesView];
//    [self.imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11.0, *)) {
//            make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
//        } else {
//            make.bottom.equalTo(view);
//        }
//        make.left.right.equalTo(view);
//        make.height.equalTo(view).multipliedBy(.25);
//    }];
//
//    UILabel *infoLabel = [[UILabel alloc] init];
//    infoLabel.text = @"点击下方添加图片（长按删除）";
//    infoLabel.textColor = [UIColor lightGrayColor];
//    [view addSubview:infoLabel];
//    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.imagesView.mas_top).offset(-8);
//        make.left.equalTo(view).offset(4);
//    }];
    
    self.textView = [[OnkeyTextEditView alloc]init];
    self.textView.placeHolder = @"请输入消息内容";
    self.textView.maxLength = 65535;
    self.textView.hasBorder = NO;
    [view addSubview:self.textView];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(topLabel.mas_bottom).offset(8);
        make.top.equalTo(view);
        make.left.right.equalTo(view);
//        make.bottom.equalTo(infoLabel.mas_top).offset(-8);
        make.bottom.equalTo(view);
    }];
    
    self.keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.keyboardBtn setTitle:@"关闭键盘" forState:UIControlStateNormal];
    self.keyboardBtn.backgroundColor = [UIColor lightGrayColor];
    [self.keyboardBtn setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    [self.keyboardBtn addTarget:self
                         action:@selector(touchCloseKeyboard)
               forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.keyboardBtn];
    
    [self.keyboardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.height.equalTo(@0);
        make.bottom.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"群发编辑";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchSend)];
    [MessageSendManager manager].delegate = self;
    
    [self.groupsView reloadData];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    CGRect keyboardFrame    = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self.keyboardBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view).offset(-keyboardFrame.size.height);
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self.keyboardBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@0);
        make.bottom.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)touchCloseKeyboard {
    [self.view endEditing:YES];
}

- (void)back {
    if(self.imagesArr.count || self.textView.text.length) {
        [YuAlertViewController showAlertWithTitle:@"温馨提示"
                                          message:@"如果现在返回，编辑的内容将会丢失，是否继续？"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_CONTINUE
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }
                                      cancelTitle:YUCLOUD_STRING_CANCEL
                                     cancelAction:nil
                                       completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSMutableArray *)imagesArr {
    if(!_imagesArr) {
        _imagesArr = [NSMutableArray array];
    }
    
    return _imagesArr;
}

- (void)touchSend {
    if(!self.textView.text.length && !self.imagesArr.count) {
        [MBProgressHUD showMessage:@"群发内容不能为空"
                            onView:APP_DELEGATE_WINDOW];
        
        return;
    }
    [self.view endEditing:YES];
    
    NSMutableArray *mulArr = [NSMutableArray array];
    
    if(self.textView.text.length) {
        RCTextMessage *textMessage = [RCTextMessage messageWithContent:self.textView.text];
        [mulArr addObject:textMessage];
    }
    
    if(self.imagesArr.count) {
        for(UIImage *image in self.imagesArr) {
            RCImageMessage *imageMessage = [RCImageMessage messageWithImage:image];
            [mulArr addObject:imageMessage];
        }
    }
    
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:self.imagesArr.count*self.data.count];
    
    for(RCMessageContent *content in mulArr) {
        for(NSString *groupid in self.data) {
            MesssageItem *item = [[MesssageItem alloc] init];
            item.conversationType = ConversationType_GROUP;
            if(self.onekeyEditType == OnekeyEditTypeContact) {
                item.conversationType = ConversationType_PRIVATE;
            }
            item.targetid = groupid;
            item.content = content;
            [messages addObject:item];
        }
    }
    
    [[MessageSendManager manager] sendMessages:messages];
}

- (void)longGestureAction: (UILongPressGestureRecognizer*)longGesture {
    CGPoint point = [longGesture locationInView:self.imagesView];
    
    switch (longGesture.state) {
            case UIGestureRecognizerStateBegan: {
                NSIndexPath *indexPath = [self.imagesView indexPathForItemAtPoint:point];
                if (indexPath.item == self.imagesArr.count+1-1) break;
                self.isDeleting = YES;
                [self.imagesView reloadData];
            }
            break;
            case UIGestureRecognizerStateChanged: {
            }
            break;
            case UIGestureRecognizerStateEnded: {
            }
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView == self.groupsView) {
        return MIN(32, [self.data count]);
    } else {
        return self.imagesArr.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.groupsView) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:[GroupIconCell reuseIdentifier]
                                                         forIndexPath:indexPath];
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:[OnekeyImageCell reuseIdentifier]
                                                         forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.groupsView) {
        GroupIconCell *gCell = (GroupIconCell *)cell;
        if(self.showMore && (indexPath.item == MIN(32, [self.data count]) - 1)) {
            gCell.iconView.image = [[UIImage imageNamed:@"ic_contacts_more"] imageMaskedWithColor:[UIColor grayColor]];
        } else {
            if(self.onekeyEditType == OnekeyEditTypeContact) {
                ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:self.data[indexPath.item]];
                [gCell.iconView sd_setImageWithURL:[NSURL URLWithString:[contact.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                                  placeholderImage:[UIImage imageNamed:@"ic_contacts_placeholder"]
                                         completed:nil];
            } else {
                GroupData *group = [[GroupDataSource sharedInstance] groupWithGroupid:self.data[indexPath.item]];
                [gCell.iconView sd_setImageWithURL:[NSURL URLWithString:[group.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                                  placeholderImage:[UIImage imageNamed:@"ic_group_placeholder"]
                                         completed:nil];
            }
        }
    } else {
        OnekeyImageCell *oCell = (OnekeyImageCell *)cell;
        oCell.delegate = self;
        
        if(indexPath.item == (self.imagesArr.count+1-1)) {
            oCell.iconView.contentMode = UIViewContentModeCenter;
            oCell.iconView.image = [[UIImage imageNamed:@"ic_add_image"] imageResized:44];
            oCell.showDelete = NO;
        } else {
            oCell.iconView.image = nil;
            oCell.iconView.contentMode = UIViewContentModeScaleAspectFit;
            oCell.iconView.image = self.imagesArr[indexPath.item];
            oCell.showDelete = self.isDeleting;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.groupsView) {
        return CGSizeMake(self.groupCellWidth, self.groupCellWidth);
    } else {
        CGFloat height = CGRectGetHeight(collectionView.bounds);
        return CGSizeMake(9.0*height/16.0, height);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.imagesView) {
        if(indexPath.item == (self.imagesArr.count+1-1) && !self.isDeleting) {
            if(self.imagesArr.count < 2) {
                [[UniManager manager] selectImageWithLimit:1
                                                      type:PHAssetMediaTypeImage
                                            viewController:self
                                                   squared:NO
                                                    upload:NO
                                            withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                if (success) {
                                                    
                                                    [self.imagesArr addObjectsFromArray:info[@"images"]];
                                                    
                                                    [self.imagesView reloadData];
                                                }
                                            }];
            } else {
                [YuAlertViewController showAlertWithTitle:@"温馨提示"
                                                  message:@"当前仅支持最多一次群发两张图片"
                                           viewController:self.navigationController
                                                  okTitle:YUCLOUD_STRING_OK
                                                 okAction:nil
                                              cancelTitle:nil
                                             cancelAction:nil
                                               completion:nil];
            }
        } else {
            self.isDeleting = NO;
            [self.imagesView reloadData];
        }
    }
}

#pragma mark - OnekeyImageCellDelegate

- (void)userChooseDelete:(OnekeyImageCell *)cell {
    NSIndexPath *indexPath = [self.imagesView indexPathForCell:cell];
    [self.imagesArr removeObjectAtIndex:indexPath.item];
    self.isDeleting = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imagesView reloadData];
    });
}

#pragma mark - MessageSendManagerDelegate

- (void)messagesSendSuccess:(BOOL)success {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
