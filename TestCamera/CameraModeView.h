//
//  CameraModeView.h
//  TestCamera
//
//  Created by 赵铭 on 2017/10/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    CameraModeSingleShotType,
    CameraModeContinuousType,
} CameraModeType;
@interface CameraModeView : UIControl
@property (nonatomic, assign) CameraModeType cameraModel;

@end
