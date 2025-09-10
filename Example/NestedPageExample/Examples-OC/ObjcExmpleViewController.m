//
//  ObjcExmpleViewController.m
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/5.
//

#import "ObjcExmpleViewController.h"
#import "NestedPageExample-Swift.h"

@interface ChildViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NestedPageScrollable>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSArray<NSString *> *dataArray;
@end

@implementation ChildViewController

- (instancetype)init {
    self = [super init];
    if (self) {

        _backgroundColor = [UIColor systemBackgroundColor];
        
        // 生成一些示例数据
        NSMutableArray *data = [NSMutableArray array];
        for (int i = 1; i <= 30; i++) {
            [data addObject:[NSString stringWithFormat:@"项目 %d", i]];
        }
        _dataArray = [data copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.backgroundColor;
    
    // 使用标题更新数据数组
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 1; i <= 30; i++) {
        [data addObject:[NSString stringWithFormat:@"%@ - 项目 %d", self.title, i]];
    }
    _dataArray = [data copy];
    
    _tableView = [[UITableView alloc] initWithFrame: self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 60;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"选中了: %@", self.dataArray[indexPath.row]);
}

#pragma mark - NestedPageScrollable

- (nonnull UIScrollView *)contentScrollView {
    return self.tableView;
}

@end

@interface ObjcExmpleViewController () <NestedPageViewControllerDataSourceObjc, NestedPageViewControllerDelegateObjc>
@property (nonatomic, strong) NestedPageViewControllerObjcBridge *pageViewControllerBridge;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) UIView *coverView;

// 自定义导航栏相关
@property (nonatomic, strong) UIView *customNavigationBar;
@property (nonatomic, strong) UIView *navigationContentView;
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation ObjcExmpleViewController

#pragma mark - 自定义导航栏

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏系统导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复系统导航栏
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupCustomNavigationBar {
    // 创建导航栏容器
    self.customNavigationBar = [[UIView alloc] init];
    self.customNavigationBar.backgroundColor = UIColor.systemBackgroundColor;
    self.customNavigationBar.alpha = 0.0; // 初始透明，滚动时显示
    [self.view addSubview:self.customNavigationBar];
    
    // 创建导航内容视图
    self.navigationContentView = [[UIView alloc] init];
    self.navigationContentView.backgroundColor = UIColor.clearColor;
    [self.customNavigationBar addSubview:self.navigationContentView];
    
    // 创建标题标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"ObjC桥接示例";
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = UIColor.labelColor;
    [self.navigationContentView addSubview:titleLabel];
    
    // 设置布局
    [self layoutCustomNavigationBar];
}

- (void)layoutCustomNavigationBar {
    CGFloat safeAreaTop = self.view.safeAreaInsets.top;
    CGFloat navBarHeight = 44.0;
    CGFloat totalNavBarHeight = safeAreaTop + navBarHeight;
    
    // 设置导航栏容器frame
    self.customNavigationBar.frame = CGRectMake(
        0,
        0,
        self.view.bounds.size.width,
        totalNavBarHeight
    );
    
    // 设置导航内容视图frame
    self.navigationContentView.frame = CGRectMake(
        0,
        safeAreaTop,
        self.view.bounds.size.width,
        navBarHeight
    );
    
    // 获取并设置标题标签frame
    UILabel *titleLabel = nil;
    for (UIView *subview in self.navigationContentView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            titleLabel = (UILabel *)subview;
            break;
        }
    }
    
    if (titleLabel) {
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(
            (self.view.bounds.size.width - titleLabel.frame.size.width) / 2,
            (navBarHeight - titleLabel.frame.size.height) / 2,
            titleLabel.frame.size.width,
            titleLabel.frame.size.height
        );
    }
}

- (void)setupBackButton {
    // 创建固定的返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    self.backButton.tintColor = UIColor.systemBlueColor;
    self.backButton.backgroundColor = UIColor.clearColor;
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 直接添加到控制器的view上，确保始终可见
    [self.view addSubview:self.backButton];
}

- (void)layoutBackButton {
    CGFloat safeAreaTop = self.view.safeAreaInsets.top;
    CGFloat navBarHeight = 44.0;
    
    CGFloat buttonWidth = 40.0;
    CGFloat buttonHeight = 30.0;
    
    // 设置位置与原导航栏中的返回按钮完全一致
    self.backButton.frame = CGRectMake(
        16,
        safeAreaTop + (navBarHeight - buttonHeight) / 2,
        buttonWidth,
        buttonHeight
    );
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 设置标题数组
    self.titles = @[@"推荐", @"关注", @"热门", @"附近"];
    
    // 创建封面视图
    self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    self.coverView.backgroundColor = UIColor.systemPinkColor;
    
    // 添加标题标签
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 60)];
    titleLabel.text = @"ObjC桥接示例";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.coverView addSubview:titleLabel];
    
    // 创建并配置NestedPageViewController
    self.pageViewControllerBridge = [[NestedPageViewControllerObjcBridge alloc] init];
    self.pageViewControllerBridge.dataSource = self;
    self.pageViewControllerBridge.delegate = self;
    
    // 应用全局配置
    [[NestedPageConfig shared] applyConfigTo:self.pageViewControllerBridge.nestedPageViewController];
    
    // 添加到父视图控制器
    [self.pageViewControllerBridge addToParentViewController:self];
    
    // 设置自定义导航栏
    [self setupCustomNavigationBar];
    [self setupBackButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 更新自定义导航栏布局
    [self layoutCustomNavigationBar];
    
    // 更新返回按钮布局
    [self layoutBackButton];
    
    // 设置NestedPageViewController的视图布局
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    self.pageViewControllerBridge.containerInsets = UIEdgeInsetsMake(0, 0, safeBottom, 0);
    self.pageViewControllerBridge.nestedPageViewController.view.frame = self.view.bounds;
    
    CGFloat safeAreaTop = self.view.safeAreaInsets.top;
    CGFloat navBarHeight = 44;
    // 调整吸顶位置偏移，由于nestedPageViewController.view是全屏的，默认只有到达屏幕最顶端才会吸顶，这里设置吸顶位置在导航栏的下方
    self.pageViewControllerBridge.stickyOffset = safeAreaTop + navBarHeight;
}

#pragma mark - NestedPageViewControllerDataSourceObjc

- (NSInteger)numberOfViewControllersIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    return self.titles.count;
}

- (UIViewController<NestedPageScrollable> *)pageViewController:(NestedPageViewControllerObjcBridge *)pageViewController viewControllerAt:(NSInteger)index {
    ChildViewController *childVC = [[ChildViewController alloc] init];
    childVC.title = self.titles[index];
    
    return childVC;
}

- (UIView *)coverViewIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    return self.coverView;
}

- (CGFloat)heightForCoverViewIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    return 200.0;
}

- (UIView *)tabStripIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    NestedPageTabStripConfigurationObjcBridge *config = [NestedPageTabStripConfigurationObjcBridge defaultConfiguration];
    config.titles = self.titles;
    config.titleColor = UIColor.grayColor;
    config.titleSelectedColor = UIColor.blackColor;
    config.backgroundColor = UIColor.whiteColor;
    
    NestedPageTabStripViewObjcBridge *tabStripBridge = [[NestedPageTabStripViewObjcBridge alloc] initWithConfiguration:config];
    tabStripBridge.swiftTabStripView.tintColor = [UIColor redColor];
    tabStripBridge.linkedScrollView = self.pageViewControllerBridge.containerScrollView;
    return tabStripBridge.swiftTabStripView;
}

- (CGFloat)heightForTabStripIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    return 50.0;
}

- (NSArray<NSString *> *)titlesForTabStripIn:(NestedPageViewControllerObjcBridge *)pageViewController {
    return nil;
}

#pragma mark - NestedPageViewControllerDelegateObjc

- (void)pageViewController:(NestedPageViewControllerObjcBridge *)pageViewController didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"滚动到页面: %@", self.titles[index]);
}

- (void)pageViewController:(NestedPageViewControllerObjcBridge *)pageViewController
contentScrollViewDidScroll:(UIScrollView *)scrollView
              headerOffset:(CGFloat)headerOffset
                 isSticked:(BOOL)isSticked {
    
    // 计算导航栏透明度
    CGFloat coverHeight = [self heightForCoverViewIn:pageViewController];
    CGFloat tabHeight = [self heightForTabStripIn:pageViewController];
    CGFloat headerHeight = coverHeight + tabHeight;
    
    // 注意：scrollView.contentOffset.y初始值为-headerHeight
    CGFloat headerOffsetY = headerOffset;
        
    // 计算导航栏透明度
    CGFloat scrollDistance = headerHeight - self.customNavigationBar.frame.size.height - tabHeight;
    self.customNavigationBar.alpha = MIN(MAX(headerOffsetY / scrollDistance, 0.0), 1.0);
}

@end
