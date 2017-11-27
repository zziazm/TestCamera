//
//  PWCameraResource.m
//  TestNewCamera
//
//  Created by 赵铭 on 2017/10/19.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "PWCameraResource.h"

@implementation PWCameraResource
+ (UIImage *)imageForResource:(NSString *)name{
    NSString * assetPath = [NSBundle bundleForClass:[PWCameraResource class]].resourcePath;
    NSBundle * bundle = [NSBundle bundleWithPath:[assetPath stringByAppendingPathComponent:@"PWCameraResource.bundle"]];
    NSString * imagePath = [bundle pathForResource:name ofType:@"png" inDirectory:@"Images"];
    
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    return  image;
}

+ (UIImage *)cameraCancelImage{
    return [self imageForResource:@"camera_cancel"];
}

+ (UIImage *)cameraFlashOnImage{
    return [self imageForResource:@"camera_flash_on"];
}

+ (UIImage *)cameraFlashAutoImage{
    return [self imageForResource:@"camera_flash_auto"];
}

+ (UIImage *)cameraFlashOffImage{
    return [self imageForResource:@"camera_flash_off"];
}

+ (UIImage *)cameraSwitchImage{
    return [self imageForResource:@"camera_switch"];
}

+ (UIImage *)cameraTriggerImage{
    return [self imageForResource:@"camera_trigger"];

}
@end
