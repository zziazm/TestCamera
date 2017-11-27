//
//  PWCameraResource.h
//  TestNewCamera
//
//  Created by 赵铭 on 2017/10/19.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PWCameraResource : NSObject
+ (UIImage *)imageForResource:(NSString *)name;
+ (UIImage *)cameraCancelImage;
+ (UIImage *)cameraFlashOnImage;
+ (UIImage *)cameraFlashAutoImage;
+ (UIImage *)cameraFlashOffImage;
+ (UIImage *)cameraSwitchImage;
+ (UIImage *)cameraTriggerImage;
@end
