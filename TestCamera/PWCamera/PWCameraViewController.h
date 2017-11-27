//
//  PWCameraViewController.h
//  TestNewCamera
//
//  Created by 赵铭 on 2017/10/19.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
typedef enum : NSUInteger {
    PWCameraDeviceSourceFrontType,
    DKCameraDeviceSourceRearType,
} PWCameraDeviceSourceType;


@interface PWCameraViewController : UIViewController
@property (nonatomic, copy) void(^didCancel)(void);
@property (nonatomic, copy) void (^didFinishCapturingImage)(UIImage * image);
@property (nonatomic, copy) void(^onFaceDetection)(NSArray<AVMetadataFaceObject *>*faces);
@property (nonatomic, strong) UIView * cameraOverlayView;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, strong) UIButton * flashButton;
@property (nonatomic, assign) BOOL allowsRotate;
@property (nonatomic, assign) BOOL showsCameraControls;
//@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, assign) PWCameraDeviceSourceType defaultCaptureDevice;
@property (nonatomic, strong) AVCaptureDevice * currentDevice;
@property (nonatomic, strong) AVCaptureDevice * captureDeviceFront;
@property (nonatomic, strong) AVCaptureDevice * captureDeviceRear;
@property (nonatomic, assign) UIDeviceOrientation originalOrientation;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, strong) UIButton * cameraSwitchButton;
@property (nonatomic, strong) UIButton * captureButton;
@property (nonatomic, assign) BOOL shouldAutorotate;
@property (nonatomic, assign) NSInteger maxCaptureCount;
+ (BOOL)isAvailable;
+ (void)checkCameraPermission:(void(^)(BOOL granted))handler;
@end
