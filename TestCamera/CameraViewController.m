//
//  CameraViewController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/9/29.
//  Copyright © 2017年 zm. All rights reserved.
//


#import "CameraViewController.h"
#import "CameraModeView.h"
//#import "DBCameraView.h"
#import <AVFoundation/AVFoundation.h>
#define kTopBarHeight 44
#define kBottomBarHeight 80
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface CameraViewController ()
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
////    DBCameraView *c = [[DBCameraView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight - (kTopBarHeight + kTopBarHeight))];
////    [self.view addSubview:c];
//    [self setNeedsStatusBarAppearanceUpdate];
//    _cameraView = [[CustomCameraSessionView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight - (kTopBarHeight + kTopBarHeight))];
//    _cameraView.delegate = self;
//    [self.view addSubview:_cameraView];
//
//    [_cameraView hideCameraToggleButton];
//    [_cameraView hideFlashButton];
//    [_cameraView hideDismissButton];
//    [_cameraView hideTopBar];
//    [_cameraView setTopBarColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
}


#pragma mark -- CACameraSessionDelegate
- (void)didCaptureImage:(UIImage *)image{
    
}
- (void)didCaptureImageWithData:(NSData *)imageData{
    
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//隐藏status bar
- (BOOL)prefersStatusBarHidden{
    return YES;
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
