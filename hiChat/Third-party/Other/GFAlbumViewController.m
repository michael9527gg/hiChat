//
//  GFAlbumViewController.m
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import "GFAlbumViewController.h"
#import "GFPhotosDataSource.h"
#import "GFAlbumCell.h"
#import "NSBundle+GFPhotoBrowser.h"


@interface GFAlbumViewController () < GFPhotosDataDelegate >

@property (nonatomic, strong) GFPhotosDataSource          *dataSource;

@end

@implementation GFAlbumViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self.tableView registerClass:[GFAlbumCell class]
               forCellReuseIdentifier:[GFAlbumCell cellIdentifier]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = GFLocalizedString(@"Albums", nil);
    
    self.dataSource = [[GFPhotosDataSource alloc] init];
    self.dataSource.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GFLocalizedString(@"Cancel", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeView)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

#pragma mark - GFPhotosDataDelegate

- (void)dataInitWillBegin {
    
}

- (void)dataInitDidFinish:(NSArray<PhotoSectionInfo *> *)sections {
    [self.tableView reloadData];
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[GFAlbumCell cellIdentifier]
                                                            forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(GFAlbumCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.sectionInfo = [self.dataSource sectionInfoForSection:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotoSectionInfo *sectionInfo = [self.dataSource sectionInfoForSection:indexPath.row];
    [self.delegate album:self selectSection:sectionInfo];
}

@end
