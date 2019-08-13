//
//  StartupPageViewController.m
//  Kaixin
//
//

#import "StartupPageViewController.h"

@interface StartupCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *contentImageView;

@end

@implementation StartupCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        CONTENT_VIEW.layer.masksToBounds = YES;
        self.contentImageView = [[UIImageView alloc] init];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [CONTENT_VIEW addSubview:self.contentImageView];
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

@end

@interface StartupPageViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *dataSource;
@property (nonatomic, strong) UIButton         *btnContinue;
@property (nonatomic, strong) UIPageControl    *pageControl;

@end

@implementation StartupPageViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[StartupCell class]
            forCellWithReuseIdentifier:[StartupCell reuseIdentifier]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorFromString:@"0x37c4ff"];
    [view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view).offset(-12);
        make.centerX.equalTo(view);
    }];
    
    UIButton *btnContinue = [UIButton buttonWithTitleColor:[UIColor whiteColor]
                                           backgroundColor:[UIColor colorFromString:@"0x37c4ff"]
                                               borderColor:nil
                                               cornerRadii:CGSizeMake(6, 6)];
    [btnContinue setTitle:@"继续" forState:UIControlStateNormal];
    [btnContinue addTarget:self
                    action:@selector(touchContinue)
          forControlEvents:UIControlEventTouchUpInside];
    btnContinue.hidden = YES;
    [view addSubview:btnContinue];
    [btnContinue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.bottom.equalTo(self.pageControl.mas_top).offset(-8);
        make.width.equalTo(@108);
        make.height.equalTo(@38);
    }];
    
    self.btnContinue = btnContinue;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = @[@"ic_conversation", @"ic_startup", @"ic_discover"];
    
    self.pageControl.numberOfPages = self.dataSource.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchContinue {
    [NSUserDefaults saveFirstTimeStartup:NO];
    
    [super touchContinue];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    
    self.pageControl.currentPage = offsetX/width;
    self.btnContinue.hidden = !(offsetX == (self.dataSource.count-1)*width);
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[StartupCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(StartupCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentImageView.image = [UIImage imageNamed:self.dataSource[indexPath.item]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      CGRectGetHeight(collectionView.bounds));
}

@end
