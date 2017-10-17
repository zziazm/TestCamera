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
#import "DKImagePickController.h"
#import <JavaScriptCore/JavaScriptCore.h>

static NSString * const url = @"http://10.150.200.216/sdcconnectmobile/index/index";
@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIWebView * webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    [self.view addSubview:_webView];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 10;
    [self.webView loadRequest:request];
    _webView.delegate = self;
}

- (IBAction)takePics:(id)sender {
   
    DKImagePickController *pc =  [[DKImagePickController alloc] init];
    __weak typeof(self) weakSelf = self;
    [pc setDidConfirmSingleImage:^(UIImage *image) {
        [weakSelf rtnImageToHtml:image];
    }];
    [pc setDidConfirmContinousImage:^(NSArray *images) {
        
    }];
    [self presentViewController:pc animated:YES completion:nil];
}

#pragma mark -- UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 创建JSContext
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 调用系统相机
    context[@"iOSCamera"] = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
//            DKCamera * vc = [[DKCamera alloc] init];
//            [self presentViewController:vc animated:YES completion:nil];
            DKImagePickController *pc =  [[DKImagePickController alloc] init];
            __weak typeof(self) weakSelf = self;
            [pc setDidConfirmSingleImage:^(UIImage *image) {
                [weakSelf rtnImageToHtml:image];
            }];
            [pc setDidConfirmContinousImage:^(NSArray *images) {
                
            }];
            [self presentViewController:pc animated:YES completion:nil];
        });
        return @"调用相机";
    };
}

- (void)rtnImageToHtml:(UIImage *)image{
    
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.001);
    
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context=[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
//    [self removeSpaceAndNewline:encodedImageStr];
    //使用模态返回到软件界面
    // 这里传值给h5界面
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
    [context evaluateScript:jsFunctStr];
}
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
