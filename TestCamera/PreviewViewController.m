//
//  PreviewViewController.m
//  TestCamera
//
//  Created by 赵铭 on 2017/11/24.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "PreviewViewController.h"
#import "MBProgressHUD+Add.h"
#import "MBProgressHUD.h"
#import "SSOSharedInfo.h"
#import "UIView+YYAdd.h"
@interface PreviewViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIWebView * webView;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [self.view addSubview:_webView];
    [self.webView setScalesPageToFit:YES];
    _webView.delegate = self;
    [self loadAfterAuthenticated];
    
    UILabel * label = [UILabel new];
//    label.top =10;//[UIScreen mainScreen].bounds.size.height - 10 - 30;
//    label.left = 10;//[UIScreen mainScreen].bounds.size.width - 10 - 100;
    label.text = @"Back";
    label.width = 60;
    label.height = 30;
    label.textAlignment = NSTextAlignmentLeft;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)]];
    label.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    
    // Do any additional setup after loading the view.
}
- (void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadAfterAuthenticated{
    //
    _path = [_path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_path]];
    request.timeoutInterval = 10;
    [request setValue:[SSOSharedInfo sharedInstance].userInfo.token forHTTPHeaderField:@"AUTHORIZATION"];
    NSLog(@"userToken=%@",[SSOSharedInfo sharedInstance].userInfo.token);
    [self.webView loadRequest:request];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = request.URL.absoluteString;
    NSLog(@"url :%@",requestString);
    NSString *urlString = request.URL.absoluteString;
    return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
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
