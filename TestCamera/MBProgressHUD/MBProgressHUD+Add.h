//
//  MBProgressHUD+Add.h
//  Coffee
//
//  Created by 赵铭 on 2017/2/15.
//  Copyright © 2017年 pwc. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Add)
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view completion:(void(^)())completion;

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view isDimBackground:(BOOL)isDimBackground;

- (void)showMessage:(NSString *)message dismissDelay:(CGFloat)time;
+ (MBProgressHUD *)showToWindowWithMessag:(NSString *)message;

@end
