//
//  GroupCategoriesViewController.m
//  hiChat
//
//  Created by Polly polly on 30/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "GroupCategoriesViewController.h"
#import "GroupSelectCell.h"
#import "GroupOnekeyEditViewController.h"

@protocol GroupCategoriesHeaderViewDelegate <NSObject>

- (void)userChooseAllCategory:(NSInteger)section
                       choose:(BOOL)choose;

- (void)expandSection:(NSInteger)section
               expand:(BOOL)expand;

@end

@interface GroupCategoriesHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<GroupCategoriesHeaderViewDelegate> delegate;

@property (nonatomic, copy)      NSString  *categoryName;
@property (nonatomic, assign)    BOOL      active;
@property (nonatomic, assign)    BOOL      userChoose;
@property (nonatomic, assign)    NSInteger section;

@property (nonatomic, strong) UILabel      *nameLabel;
@property (nonatomic, strong) UIButton     *indicatorBtn;
@property (nonatomic, strong) UIButton     *indicatorView;
@property (nonatomic, strong) UIButton     *selectView;

@end

@implementation GroupCategoriesHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.selectView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectView setImage:[UIImage imageNamed:@"ic_contact_unselect"]
                         forState:UIControlStateNormal];
        [self.selectView setImage:[UIImage imageNamed:@"ic_contact_select"]
                         forState:UIControlStateSelected];
        [self.selectView addTarget:self
                            action:@selector(selectAll)
                  forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.selectView];
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        self.indicatorView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.indicatorView setImage:[UIImage imageNamed:@"ic_group_right"]
                            forState:UIControlStateNormal];
        [self.indicatorView setImage:[UIImage imageNamed:@"ic_group_down"]
                            forState:UIControlStateSelected];
        [self.indicatorView addTarget:self
                               action:@selector(touchExpand)
                     forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW).offset(-8);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        self.indicatorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.indicatorBtn setTitle:@"展开" forState:UIControlStateNormal];
        [self.indicatorBtn setTitle:@"收起" forState:UIControlStateSelected];
        [self.indicatorBtn setTitleColor:[UIColor lightGrayColor]
                                forState:UIControlStateNormal];
        [self.indicatorBtn setTitleColor:[UIColor lightGrayColor]
                                forState:UIControlStateSelected];
        [self.indicatorBtn addTarget:self
                              action:@selector(touchExpand)
                    forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.indicatorBtn];
        [self.indicatorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.right.equalTo(self.indicatorView.mas_left).offset(-2);
            make.size.mas_equalTo(CGSizeMake(60, 24));
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectView.mas_right).offset(12);
            make.centerY.equalTo(CONTENT_VIEW);
            make.right.lessThanOrEqualTo(self.indicatorBtn.mas_left).offset(-4);
        }];
    }
    
    return self;
}

- (void)touchExpand {
    self.indicatorBtn.selected = !self.indicatorBtn.selected;
    self.indicatorView.selected = !self.indicatorView.selected;
    
    [self.delegate expandSection:self.section
                          expand:self.indicatorBtn.selected];
}

- (void)selectAll {
    self.selectView.selected = !self.selectView.selected;
    
    [self.delegate userChooseAllCategory:self.section
                                  choose:self.selectView.selected];
}

- (void)setCategoryName:(NSString *)categoryName {
    _categoryName = categoryName;
    
    self.nameLabel.text = categoryName;
}

- (void)setActive:(BOOL)active {
    _active = active;
    
    self.indicatorView.selected = active;
    self.indicatorBtn.selected = active;
}

- (void)setUserChoose:(BOOL)userChoose {
    _userChoose = userChoose;
    
    self.selectView.selected = userChoose;
}

@end

#define ReuseIdentifier @"group.category.header.reuseIdentifier"

@interface GroupCategoriesViewController () < UITableViewDataSource, UITableViewDelegate, GroupCategoriesHeaderViewDelegate >

@property (nonatomic, strong) UITableView                 *tableView;

@property (nonatomic, strong) NSMutableArray              *sectionTitles;
@property (nonatomic, strong) NSMutableArray<NSArray *>   *sections;
@property (nonatomic, strong) NSMutableArray<GroupData *> *groups;

@property (nonatomic, strong) NSMutableArray              *inactiveSections;
@property (nonatomic, strong) NSMutableSet                *selectSet;

@end

@implementation GroupCategoriesViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    [self.tableView registerClass:[GroupSelectCell class]
           forCellReuseIdentifier:[GroupSelectCell reuseIdentifier]];
    [self.tableView registerClass:[GroupCategoriesHeaderView class] forHeaderFooterViewReuseIdentifier:ReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.view = view;
}

- (instancetype)init {
    if(self = [super init]) {
        self.inactiveSections = [NSMutableArray array];
        self.selectSet = [NSMutableSet set];
        self.sections = [NSMutableArray array];
        self.sectionTitles = [NSMutableArray array];
        self.groups = [NSMutableArray array];
        
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"群组分类";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(touchCancel)];
    
    [self fetchData];
}

- (void)fetchData {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] requestAllGroupCategoriesWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if(success) {
            [hud hideAnimated:YES];
            
            [self processData:info];
            
            [self addRightNaviBarItems];
            
            [self.tableView reloadData];
        }
        else {
            [MBProgressHUD finishLoading:hud
                                  result:success
                                    text:[info msg]
                              completion:nil];
        }
    }];
}

- (void)addRightNaviBarItems {
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(touchFinish)];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [selectBtn setTitle:@"取消" forState:UIControlStateSelected];
    [selectBtn addTarget:self
                  action:@selector(touchSelectAll:)
        forControlEvents:UIControlEventTouchUpInside];
    [selectBtn sizeToFit];
    
    UIBarButtonItem *allBtn = [[UIBarButtonItem alloc] initWithCustomView:selectBtn];
    
    self.navigationItem.rightBarButtonItems = @[doneBtn, allBtn];
}

- (void)processData:(NSDictionary *)data {
    NSArray *array = [data valueForKey:@"result"];
    
    NSMutableArray *result = [NSMutableArray arrayWithArray:array];
    // 先对数组排序
    [result sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        id category = [obj1 valueForKey:@"category"];
        NSInteger sort1 = 0;
        NSInteger sort2 = 0;
        
        if([category isKindOfClass:[NSString class]]) {
            sort1 = ((NSString *)category).integerValue;
        } else {
            sort1 = ((NSNumber *)category).integerValue;
        }
        
        category = [obj2 valueForKey:@"category"];
        if([category isKindOfClass:[NSString class]]) {
            sort2 = ((NSString *)category).integerValue;
        } else {
            sort2 = ((NSNumber *)category).integerValue;
        }
        
        return sort1 > sort2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    for(NSDictionary *dic in result) {
        NSString *categoryName = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"name"]);
        [self.sectionTitles addObject:categoryName];
        
        NSArray *groupList = [dic valueForKey:@"groupList"];
        NSMutableArray *arrT = [NSMutableArray arrayWithCapacity:groupList.count];
        for(NSDictionary *group in groupList) {
            GroupData *data = [GroupData groupWithDic:group];
            [arrT addObject:data];
            [self.groups addObject:data];
        }
        [self.sections addObject:arrT];
    }
}

- (void)touchFinish {
    if(!self.selectSet.count) {    
        [MBProgressHUD showMessage:@"发送群组不能为空"
                            onView:APP_DELEGATE_WINDOW
                            result:NO
                        completion:nil];
        
        return;
    }
    
    GroupOnekeyEditViewController *edit = [[GroupOnekeyEditViewController alloc] initWithOnekeyEditType:OnekeyEditTypeGroup
                                                                                                   data:[self.selectSet allObjects]];
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)touchSelectAll:(UIButton *)button {
    button.selected = !button.isSelected;
    
    if(button.isSelected) {
        for(GroupData *data in self.groups) {
            [self.selectSet addObject:data.uid];
        }
    }
    else {
        [self.selectSet removeAllObjects];
    }
    
    [self.tableView reloadData];
}

- (void)touchCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(![self.inactiveSections containsObject:@(section)]) {
        return self.sections[section].count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[GroupSelectCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(GroupSelectCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupData *data = self.sections[indexPath.section][indexPath.row];
    cell.data = data;
    
    cell.userChoose = [self.selectSet containsObject:data.uid];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:ReuseIdentifier];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    GroupCategoriesHeaderView *headerView = (GroupCategoriesHeaderView *)view;
    headerView.categoryName = self.sectionTitles[section];
    headerView.delegate = self;
    headerView.section = section;
    if([self.inactiveSections containsObject:@(section)]) {
        headerView.active = NO;
    } else {
        headerView.active = YES;
    }
    
    BOOL beChoosen = YES;
    
    NSArray *groups = self.sections[section];
    
    for(GroupData *data in groups) {
        if(![self.selectSet containsObject:data.uid]) {
            beChoosen = NO;
        }
    }
    
    headerView.userChoose = beChoosen;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupData *data = self.sections[indexPath.section][indexPath.row];
    
    if([self.selectSet containsObject:data.uid]) {
        [self.selectSet removeObject:data.uid];
    } else {
        [self.selectSet addObject:data.uid];
    }
    
    [self.tableView reloadData];
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

#pragma mark - RCConversationSettingTableViewHeaderDelegate

- (void)userChooseAllCategory:(NSInteger)section choose:(BOOL)choose {
    
    NSArray *groups = self.sections[section];
    
    for(GroupData *data in groups) {
        if(choose) {
            [self.selectSet addObject:data.uid];
        } else {
            [self.selectSet removeObject:data.uid];
        }
    }
    
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)expandSection:(NSInteger)section expand:(BOOL)expand {
    if(expand) {
        [self.inactiveSections removeObject:@(section)];
    } else {
        [self.inactiveSections addObject:@(section)];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:UITableViewRowAnimationNone];
}

@end
