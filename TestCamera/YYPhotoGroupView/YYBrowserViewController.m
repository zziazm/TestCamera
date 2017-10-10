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




@interface YYBrowserViewController ()
@property (nonatomic, strong) NSArray *items;
@end

@implementation YYBrowserViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    YYPhotoGroupView * c = [[YYPhotoGroupView alloc] initWithGroupItems:_items];
    __weak typeof(self) weakSelf = self;
    [c setDismissCompletion:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [c presentFromImageView:nil toContainer:self.view animated:YES completion:nil];
    
    // Do any additional setup after loading the view.
}
- (instancetype)initWithItems:(NSArray *)items{
    self = [super init];
    if (self) {
        _items = items;
    }
    return self;
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
