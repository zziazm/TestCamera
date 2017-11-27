//
//  DKImagePickController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/10/12.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickController.h"
#import "DKCamera.h"
#import "PWCameraViewController.h"
@interface DKImagePickController ()

@end

@implementation DKImagePickController
- (instancetype)init{
    if (self= [super init]) {
//        DKCamera * rootVC = [DKCamera new];
//        self.viewControllers = @[rootVC];
//        self.navigationBar.hidden = YES;
        
        PWCameraViewController * rootVC = [PWCameraViewController new];
        self.viewControllers = @[rootVC];
        self.navigationBar.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PWCameraViewController *vc = (PWCameraViewController*)self.viewControllers.firstObject;
    vc.maxCaptureCount = _maxCaptureCount;
    // Do any additional setup after loading the view.
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
