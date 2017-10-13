//
//  YYBrowserViewController.h
//  TestCamera
//
//  Created by 赵铭 on 2017/10/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraModeView.h"
@interface YYBrowserViewController : UIViewController
- (instancetype)initWithItems:(NSArray *)items;
@property (nonatomic, assign) CameraModeType modeType;
@property (nonatomic, copy) void(^didDeleteImage)(NSInteger idx);
@property (nonatomic, copy) void(^singleConfirmAction)(void);
@end
