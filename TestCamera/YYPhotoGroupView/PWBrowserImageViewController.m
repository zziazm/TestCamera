//
//  PWBrowserImageViewController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/10/16.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "PWBrowserImageViewController.h"
#define kPad 10
#import "UIView+YYAdd.h"
#define kTopBarHeight 44
#define kBottomBarHeight 44
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kPadding 20
#define kHiColor [UIColor colorWithRGBHex:0x2dd6b8]dddddddd
#define kBackColor [UIColor colorWithRed:32/255.0 green:41/255.0 blue:56/255.0 alpha:1]

@interface PWBrowserImageViewController ()

@end

@interface PWPhotoGroupItem()<NSCopying>

@end

@implementation PWPhotoGroupItem
- (id)copyWithZone:(nullable NSZone *)zone{
    PWPhotoGroupItem * item = [self.class new];
    return item;
}

@end

@interface DKPhotoGroupCell : UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, strong) PWPhotoGroupItem *item;

- (void)resizeSubviewSize;

@end

@implementation DKPhotoGroupCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.contentView addSubview:_scrollView];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    _imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [self.scrollView addSubview:_imageContainerView];
    
    _imageView = [UIImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = kBackColor;//[UIColor colorWithWhite:1.000 alpha:0.500];
    [_imageContainerView addSubview:_imageView];
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setItem:(PWPhotoGroupItem *)item{
    if (_item == item) {
        return;
    }
    
    _item =item;
    
    [self.scrollView setZoomScale:1.0 animated:YES];
    self.scrollView.maximumZoomScale = 1;
    if (!_item) {
        _imageView.image = nil;
        return;
    }
    
    if (_item.image) {
        _imageView.image = _item.image;
    }
    
    self.scrollView.maximumZoomScale = 3;
    [self resizeSubviewSize];
    
}

- (void)resizeSubviewSize{
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = self.width;
    
    UIImage * image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / self.width));
    }else{
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) {
            height = self.height;
        }
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = self.height/2;
    }
    
    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height < 1) {
        _imageContainerView.height = self.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.width , MAX(_imageContainerView.height, self.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    if (_imageContainerView.height <= self.height) {
        self.scrollView.alwaysBounceVertical = NO;
    }else {
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerView.bounds;
    [CATransaction commit];
    
}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIView * subView = _imageContainerView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@interface PWBrowserImageViewController()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, readonly) NSMutableArray <PWPhotoGroupItem *> *groupItems;

@property (nonatomic, readonly) NSInteger currentPage;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel * pageLabel;


@end


@implementation PWBrowserImageViewController

- (instancetype)initWithGroupItems:(NSArray<PWPhotoGroupItem *>*)groupItems{
    self = [super init];
    if (groupItems.count == 0) {
        return nil;
    }
    _groupItems = groupItems.mutableCopy;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate= self;
    tap2.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap2];
    
    [self.view addSubview:self.collectionView];
    
    _bottomView = [UIView new];
    _bottomView.frame = CGRectMake(0, kScreenHeight - kBottomBarHeight, kScreenWidth, kBottomBarHeight);
    _bottomView.backgroundColor = kBackColor;//[UIColor redColor];
    [self.view addSubview:_bottomView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat buttonHeight = 20;
    button.frame = CGRectMake(20, (_bottomView.height - buttonHeight)/2, 60, buttonHeight);
    [button setTitle:@"返回" forState: UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    //    CGFloat buttonHeight = 20;
    button1.frame = CGRectMake(kScreenWidth - 60 - 20, (_bottomView.height - buttonHeight)/2, 60, buttonHeight);
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_modeType == CameraModeSingleShotType) {
        [button1 addTarget:self action:@selector(button1Action) forControlEvents:UIControlEventTouchUpInside];
        [button1 setTitle:@"确定" forState: UIControlStateNormal];
    }else{
        [button1 addTarget:self action:@selector(deleteCurrentImage) forControlEvents:UIControlEventTouchUpInside];
        [button1 setTitle:@"删除" forState: UIControlStateNormal];
    }
    
    
    [_bottomView addSubview:button1];
    [self.view addSubview:_bottomView];
    
    if (_modeType == CameraModeContinuousType) {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.width = 150;
        _pageLabel.height = 30;
        _pageLabel.top = 20;
        _pageLabel.centerX = kScreenWidth/2;
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_pageLabel];
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [self scrollToPage:_groupItems.count - 1];
    
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + kPad, [UIScreen mainScreen].bounds.size.height) collectionViewLayout: layout];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, kPad);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        layout.minimumLineSpacing = kPad;
        [_collectionView registerClass:[DKPhotoGroupCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = kBackColor;
    }
    return _collectionView;
}

- (NSInteger)currentPage{
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.width + 0.5;
    if (page >= _groupItems.count) {
        page = (NSInteger)_groupItems.count - 1;
    }
    if (page < 0) {
        page = 0;
    }
    return page;
}

- (void)setPageLabelText:(NSInteger)currentPage{
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)currentPage, (unsigned long)self.groupItems.count];
}

- (void)deleteCurrentImage{
    
    NSInteger page = self.currentPage;
    if (self.groupItems.count > 1) {
        [_groupItems removeObjectAtIndex:page];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:page inSection:0]]];
        [self setPageLabelText:[self currentPage]+1];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.didDeleteImage) {
        self.didDeleteImage(page);
    }
}


- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)button1Action{
    if (self.singleConfirmAction) {
        self.singleConfirmAction();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollToPage:(NSInteger)page{
    if (page < self.groupItems.count) {
        [self.collectionView setContentOffset:CGPointMake(page*self.collectionView.width, 0) animated:NO];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    DKPhotoGroupCell * tile = (DKPhotoGroupCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]];
    if (tile) {
        if (tile.scrollView.zoomScale > 1) {
            [tile.scrollView setZoomScale:1 animated:YES];
        }else{
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.scrollView.maximumZoomScale;
            CGFloat xsize = self.collectionView.width / newZoomScale;
            CGFloat ysize = self.collectionView.height / newZoomScale;
            [tile.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}
#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _groupItems.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DKPhotoGroupCell * cell = [collectionView  dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.item = _groupItems[indexPath.row];
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat floatPage = scrollView.contentOffset.x / scrollView.width;
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : (intPage > self.groupItems.count ? self.groupItems.count - 1 : intPage);
    [self setPageLabelText:intPage + 1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
