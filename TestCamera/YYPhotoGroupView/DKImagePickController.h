//
//  DKImagePickController.h
//  TestCamera
//
//  Created by 赵铭 on 2017/10/12.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKImagePickController : UINavigationController
@property (nonatomic, copy) void(^didConfirmSingleImage)(UIImage *);
@property (nonatomic, copy) void(^didConfirmContinousImage)(NSArray *);
@property (nonatomic, assign) NSInteger maxCaptureCount;
@end
