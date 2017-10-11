//
//  ViewController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/9/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "DKCamera.h"
#import "CameraModeView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CameraModeView * v = [[CameraModeView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 150, [UIScreen mainScreen].bounds.size.width, 150)];
//    [self.view addSubview:v];
//    [v addTarget:self action:@selector(test:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)takePics:(id)sender {
    DKCamera * vc = [[DKCamera alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
//    [vc setDidCancel:^{
//        [vc dismissViewControllerAnimated:YES completion:nil];
//    }];
//    CameraViewController * vc = [[CameraViewController alloc] init];
    
    
}

//- (void)test:(id)v{
//    CameraModeView *c = v;
//    NSLog(@"%d", c.cameraModel);
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
