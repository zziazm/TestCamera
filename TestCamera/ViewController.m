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
#import "SSOKeychainAccessor.h"
#import "SSOSharedInfo.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "CameraModeView.h"
#import "DKImagePickController.h"
#import "PWCameraViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SSOSharedInfo.h"
#import "UIViewController+HUD.h"
#import "PreviewViewController.h"
#import "UIViewController_PwCSSOAwakeViewController.h"
#import "MJRefresh.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJRefresh.h"
//static NSString * const url = @"http://10.150.200.216/sdcconnectmobile/index/index";
//static NSString * const url = @"http://cnshaapppwv725/sdcconnectmobile/index/index";
static NSString * const url = @"http://10.150.200.216/sdcconnectmobiletest/index/index";
//static NSString * const url =  @"http://10.158.13.58/sdcconnectmobile/index/index";//prod

//static NSString * const url = @"http://10.150.200.216/sdcconnectmobiletest/PreView/1.pdf";

//static NSString * const url  = @"http://10.150.200.216/sdcconnectmobiletest/PreView/2.docx";

//static NSString * const url = @"http://10.150.200.216/sdcconnectmobiletest/PreView/CNWPC-3f2a9041-cb9d-40ba-a1e6-e4aa96fbeb62.png";

//static NSString * const url = @"http://10.150.200.216/sdcconnectmobiletest/PreView/deploy-bf14142e-2bd7-4460-99b8-ec01fa57d428.txt";

@interface ViewController ()<UIWebViewDelegate,TestJSExport>
@property (nonatomic, strong)UIWebView * webView;
@end

@interface ViewController ()<UIAlertViewDelegate>
{
    Reachability *currentAbility;
    UIAlertView *alView;
    int flag;
    BOOL showHud;
}
@end

@implementation ViewController{
    Reachability *_hostReach;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _webView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
   [self.view addSubview:_webView];
    _webView.delegate = self;
    [_webView.scrollView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"webView"];
    self.webView.scrollView.headerPullToRefreshText = @"";
    self.webView.scrollView.headerReleaseToRefreshText = @"";
    self.webView.scrollView.headerRefreshingText = @"";
    showHud = YES;
}

- (void)headerRereshing{
    [self loadAfterAuthenticated];
}


- (void)loadAfterAuthenticated{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 10;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChanged:) name:kReachabilityChangedNotification object:nil];
    //    [self.webView loadRequest:request];
    [request setValue:[SSOSharedInfo sharedInstance].userInfo.token forHTTPHeaderField:@"AUTHORIZATION"];
    NSLog(@"userToken=%@",[SSOSharedInfo sharedInstance].userInfo.token);
    //    https://mobileapps.pwchk.com/InnovationApp/
    [self.webView loadRequest:request];
    if (showHud) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void)connectionStatusChanged:(NSNotification *)notification
{
    NSLog(@"current status:%d", flag);
    currentAbility= [notification object];
    
    if (currentAbility.currentReachabilityStatus == NotReachable)
    {
        if(flag==0)
        {
            alView=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please open or retry VPN to check your connection to PwC network" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            NSLog(@"Disconnected staus = %d",currentAbility.currentReachabilityStatus);
            [self.webView stopLoading];
            [alView show];
            flag=1;
        }
    }
    
    else if (currentAbility.currentReachabilityStatus==ReachableViaWiFi ||currentAbility.currentReachabilityStatus==ReachableViaWWAN){
        [alView dismissWithClickedButtonIndex:0 animated:NO];
    }
}


- (IBAction)takePics:(id)sender {
    DKImagePickController *pc =  [[DKImagePickController alloc] init];
    __weak typeof(self) weakSelf = self;
    [pc setDidConfirmSingleImage:^(UIImage *image) {
        [weakSelf rtnImageToHtml:image];
    }];
    [pc setDidConfirmContinousImage:^(NSArray *images) {
        [weakSelf rtnMultiImages:images];
    }];
    [self presentViewController:pc animated:YES completion:nil];
}

#pragma mark -- UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = request.URL.absoluteString;
    NSLog(@"url :%@",requestString);
    NSString *urlString = request.URL.absoluteString;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    showHud = NO;
    [self.webView.scrollView headerEndRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // 创建JSContext
//    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//
//    // 调用系统相机
//    context[@"iOSCamera"] = ^(){
//        dispatch_async(dispatch_get_main_queue(), ^{
////            DKCamera * vc = [[DKCamera alloc] init];
////            [self presentViewController:vc animated:YES completion:nil];
//            DKImagePickController *pc =  [[DKImagePickController alloc] init];
//            __weak typeof(self) weakSelf = self;
//            [pc setDidConfirmSingleImage:^(UIImage *image) {
//                [weakSelf rtnImageToHtml:image];
//            }];
//            [pc setDidConfirmContinousImage:^(NSArray *images) {
//                [weakSelf rtnMultiImages:images];
//
//            }];
//            [self presentViewController:pc animated:YES completion:nil];
//        });
//        return @"调用相机";
//    };
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
//    // 调用系统相机
//    context[@"iOSCamera"] = ^(){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSArray *args = [JSContext currentArguments];
//
//
//
//            for (JSValue *jsVal in args) {
//                NSLog(@"%@", jsVal.toString);
//            }
//            DKImagePickController *pc =  [[DKImagePickController alloc] init];
//            __weak typeof(self) weakSelf = self;
//            pc.maxCaptureCount = 2;
//            [pc setDidConfirmSingleImage:^(UIImage *image) {
//                [weakSelf rtnImageToHtml:image];
//            }];
//            [pc setDidConfirmContinousImage:^(NSArray *images) {
//                [weakSelf rtnMultiImages:images];
//
//            }];
//            [self presentViewController:pc animated:YES completion:nil];
//        });
//        return @"调用相机";
//    };
    
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    
//    context[@"test.openCamera"] = ^() {
//        NSArray *args = [JSContext currentArguments];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"方式二" message:@"这是OC原生的弹出窗" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
//            [alertView show];
//        });
//
//        for (JSValue *jsVal in args) {
//            NSLog(@"%@", jsVal.toString);
//        }
//
//        NSLog(@"-------End Log-------");
//    };
    context[@"test"] = self;
    
    
}

- (void)showToastWithParameters:(NSString *)parameterone parametertwo:(NSString *)parametertwo {
    dispatch_async(dispatch_get_main_queue(), ^{
        //            DKCamera * vc = [[DKCamera alloc] init];
        //            [self presentViewController:vc animated:YES completion:nil];
        DKImagePickController *pc =  [[DKImagePickController alloc] init];
        
        pc.maxCaptureCount = [parameterone integerValue];
        __weak typeof(self) weakSelf = self;
        [pc setDidConfirmSingleImage:^(UIImage *image) {
            [weakSelf rtnImageToHtml:image];
        }];
        [pc setDidConfirmContinousImage:^(NSArray *images) {
            [weakSelf rtnMultiImages:images];
            
        }];
        [self presentViewController:pc animated:YES completion:nil];
    });
}

- (void)openFileWithParameters:(NSString *)parameterone parametertwo:(NSString *)parametertwo{
    dispatch_async(dispatch_get_main_queue(), ^{
        PreviewViewController *vc = [[PreviewViewController alloc] init];
        vc.path = parameterone;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    });
    
}


- (void)showAlert{
    NSString *jsFunctStr = [NSString stringWithFormat:@"TestCameraR"];
    JSContext *context=[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [context evaluateScript:jsFunctStr];
}

- (void)rtnMultiImages:(NSArray *)images{
    NSMutableDictionary *dic = @{}.mutableCopy;
    NSMutableArray *array = @[].mutableCopy;
    [dic setObject:array forKey:@"Images"];
    NSString * temS = @"";
    for (int i = 0; i<images.count; i++) {
        UIImage *image = images[i];
        NSMutableDictionary *temDic = @{}.mutableCopy;
        [array addObject:temDic];
//UIImage *nI = [self imageByScalingAndCroppingForSize:CGSizeMake(200, 200) withSourceImage:image];
        NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
        NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
        NSString *key = [NSString stringWithFormat:@"image%d", i];
        [temDic setObject:imageString forKey:key];
        if(i == images.count - 1){
            temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%@",imageString]];
        }else{
            temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%@,",imageString]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
            JSContext *context=[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            [context evaluateScript:jsFunctStr];
        });
    }
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",temS];
//    JSContext *context=[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    [context evaluateScript:jsFunctStr];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.webView.scrollView headerEndRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Load error: %@", error);
    
    if(error.code==NSURLErrorCancelled)
    return;
    
    if([error.domain isEqual:@"WebKitErrorDomain"] && error.code==101)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please go to PwC AppStore to install vContacts." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    else if(error.code==-999 || error.code==-1009 || error.code==-1001||error.code==-1004)
    {
        UIAlertView *alrtView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please open or retry VPN to check your connection to PwC network" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alrtView show];
        
        [webView stopLoading];
        [self showDisconnection];

    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}


- (void)rtnImageToHtml:(UIImage *)image{

//    UIImage *nI = [self imageByScalingAndCroppingForSize:CGSizeMake(200, 200) withSourceImage:image];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);

//    NSData *imgData = UIImagePNGRepresentation(image);
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context=[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    //[self removeSpaceAndNewline:encodedImageStr];
    //使用模态返回到软件界面
    // 这里传值给h5界面
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
//    NSString *jsFunctStr = [NSString stringWithFormat:@"TestCameraR('%@')",imageString];
    [context evaluateScript:jsFunctStr];
}


- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
        scaleFactor = widthFactor; // scale to fit height
        else
        scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
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


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please open or retry VPN to check your connection to PwC network" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    if (buttonIndex==0) {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        flag=0;
    }
    
    else if(buttonIndex==1&&currentAbility.currentReachabilityStatus==NotReachable)
    {
        [alert show];
    }
    else
    {
        [self loadAfterAuthenticated];
    }
}

-(void)showDisconnection
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Disconnection" ofType:@"html"]];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
