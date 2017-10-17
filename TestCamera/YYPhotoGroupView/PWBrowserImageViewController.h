//
//  PWBrowserImageViewController.h
//  TestCamera
//
//  Created by 赵铭 on 2017/10/16.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraModeView.h"

NS_ASSUME_NONNULL_BEGIN
@interface PWPhotoGroupItem : NSObject

@property (nonatomic, strong) UIImage * _Nullable image;

@end
@interface PWBrowserImageViewController : UIViewController
@property (nonatomic, assign) CameraModeType modeType;

@property (nonatomic, copy) void(^didDeleteImage)(NSInteger idx);

@property (nonatomic, copy) void(^singleConfirmAction)(void);

@property (nonatomic, copy) void(^dismissCompletion)(void);



- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;
@end

NS_ASSUME_NONNULL_END

