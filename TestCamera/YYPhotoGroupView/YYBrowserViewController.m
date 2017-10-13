//
//  YYBrowserViewController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/10/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "YYBrowserViewController.h"
#import "YYPhotoGroupView.h"
#import "UIView+YYAdd.h"
#import "NSString+YYAdd.h"

#import "UIImage+YYAdd.h"
#define kTopBarHeight 44
#define kBottomBarHeight 44
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kBackColor [UIColor colorWithRed:32/255.0 green:41/255.0 blue:56/255.0 alpha:1]



@interface YYBrowserViewController ()<YYPhotoGroupViewDelegate>
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) YYPhotoGroupView *groupView;
@end

@implementation YYBrowserViewController





- (instancetype)initWithItems:(NSArray *)items{
    self = [super init];
    if (self) {
        _items = items;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackColor;
    
    
    YYPhotoGroupView * c = [[YYPhotoGroupView alloc] initWithGroupItems:_items];
    __weak typeof(self) weakSelf = self;
    c.delegate = self;
    [c setDismissCompletion:^{
//        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [c presentFromImageView:nil toContainer:self.view animated:YES completion:nil];
    _groupView = c;
    if (_modeType == CameraModeContinuousType) {
        [c scrollToPage:_items.count - 1];
    }
    
    
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
    
    // Do any additional setup after loading the view.
}

#pragma mark -- YYPhotoGroupViewDelegate
- (void)photoGroupView:(YYPhotoGroupView *)photoGroupView
         didDeletePage:(NSInteger)page{
    if (self.didDeleteImage) {
        self.didDeleteImage(page);
    }
}

- (void)deleteCurrentImage{
    [_groupView deleteCurrentPage];
}


- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)button1Action{
    if (self.singleConfirmAction) {
        self.singleConfirmAction();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)dealloc{
//    NSLog(@"a");
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
