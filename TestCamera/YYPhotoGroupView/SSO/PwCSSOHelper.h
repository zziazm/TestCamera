//
//  PwCSSOHelper.h
//  LMS for iPad
//
//  Created by Nep Tong on 1/28/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PwCSSOHelper : NSObject

+ (void)checkSSOOnline;
+ (void)checkSSOOffline;
+ (void)registerAwakeViewController:(UIViewController *)viewController;

@end
