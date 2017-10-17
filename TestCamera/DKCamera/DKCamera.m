//
//  DKCamera.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/4.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKCamera.h"
#import "UIView+YYAdd.h"
#import "CameraModeView.h"
#define kTopBarHeight 44
#define kBottomBarHeight 100
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kIVWidth  60
#import "YYBrowserViewController.h"
#import "YYPhotoGroupView.h"
#import "DKImagePickController.h"
#define kBackColor [UIColor colorWithRed:32/255.0 green:41/255.0 blue:56/255.0 alpha:1]
#define kCurrentVersion [[[UIDevice currentDevice] systemVersion] intValue]

#import "PWBrowserImageViewController.h"

#define kLabelWidth 100
#define kLabelFont 14
#define kForegroundColor [UIColor colorWithRed:1 green:0.7 blue:0.006 alpha:1]
#define kNotForegroundColor [UIColor whiteColor]



@interface DKCaptureButton : UIButton

@end

@implementation DKCaptureButton

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.backgroundColor = [UIColor whiteColor];
    return  YES;
    
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event   {
    self.backgroundColor = [UIColor whiteColor];
    return  YES;

}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.backgroundColor = nil;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    self.backgroundColor = nil;
}

@end

@implementation NSBundle(DKCameraExtension)

+ (NSBundle *)cameraBundle{
    NSString * assetPath = [NSBundle bundleForClass:[DKCameraResource class]].resourcePath;
    
    return [NSBundle bundleWithPath:[assetPath stringByAppendingPathComponent:@"DKCameraResource.bundle"]];
}

@end

@implementation DKCameraResource

+ (UIImage *)imageForResource:(NSString *)name{
    NSBundle * bundle = [NSBundle cameraBundle];
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

@end


@interface DKCamera ()

@property (nonatomic, assign) CGFloat beginZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL isStopped;
@property (nonatomic, strong) UIView * focusView;
@property (nonatomic, strong) CameraModeView * bottomView;
//@property (nonatomic, strong) CameraModeView *modeView;
@property (nonatomic, weak) AVCaptureStillImageOutput * stillImageOutput;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UILabel *ivCountLabel;
@property (nonatomic, assign) NSInteger ivCount;
@property (nonatomic, assign) CameraModeType modeType;
@property (nonatomic, strong) NSMutableArray *continousImages;
@property (nonatomic, strong) UIButton * completionButton;




@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, strong) UIColor * foregroundColor;

@property (nonatomic, strong) UILabel * singleLabel;
@property (nonatomic, strong) UILabel * continousLabel;
@end

@implementation DKCamera

+ (void)checkCameraPermission:(void(^)(BOOL granted))handler{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        handler(YES);
    }else if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }];
    }else{
        handler(NO);
    }
}
+ (BOOL)isAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
- (void)hideContinousImageView:(BOOL)hideden{
    self.iv.hidden = hideden;
    self.ivCountLabel.hidden = hideden;
    self.completionButton.hidden = hideden;
}
- (instancetype)init{
    if (self = [super init]) {
        _allowsRotate = NO;
        _showsCameraControls = YES;
        _contentView = [UIView new];
        _captureSession = [AVCaptureSession new];
        _beginZoomScale = 1.0;
        _zoomScale = 1.0;
        _defaultCaptureDevice = DKCameraDeviceSourceRearType;
        _motionManager = [CMMotionManager new];
        _isStopped = NO;
        _bottomView = [CameraModeView new];
        _iv = [UIImageView new];
        _continousImages = @[].mutableCopy;
        _ivCountLabel = [UILabel new];
        [self hideContinousImageView:YES];
    }
    return self;
}
- (void)setShowsCameraControls:(BOOL)showsCameraControls{
    if (_showsCameraControls != showsCameraControls) {
        _showsCameraControls = showsCameraControls;
        self.contentView.hidden = !showsCameraControls;
    }
}
- (void)setCameraOverlayView:(UIView *)cameraOverlayView{
    if (_cameraOverlayView != cameraOverlayView) {
        _cameraOverlayView = cameraOverlayView;
        [self.view addSubview:_cameraOverlayView];
    }
    
    
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    _flashMode = flashMode;
    [self updateFlashButton];
    [self updateFlashMode];
    [self updateFlashModeToUserDefautls:self.flashMode];
}

- (void)updateFlashModeToUserDefautls:(AVCaptureFlashMode)flashMode{
    [[NSUserDefaults standardUserDefaults] setObject:@(flashMode) forKey:@"DKCamera.flashMode"];
}

- (void)updateFlashMode{
    if (self.currentDevice && self.currentDevice.isFlashAvailable && [self.currentDevice isFlashModeSupported:self.flashMode]) {
        [self.currentDevice lockForConfiguration:nil];
        self.currentDevice.flashMode = self.flashMode;
        [_currentDevice unlockForConfiguration];
    }
}

- (void)updateFlashButton{
    UIImage * flashImage = [self flashImage:self.flashMode];
    [self.flashButton setImage:flashImage forState:UIControlStateNormal];
    [self.flashButton sizeToFit];
    
}


- (UIImage *)flashImage:(AVCaptureFlashMode)flashModel{
    UIImage * image;
    switch (flashModel) {
        case AVCaptureFlashModeAuto:
            image = [DKCameraResource cameraFlashAutoImage];
            break;
        case AVCaptureFlashModeOn:
            image = [DKCameraResource cameraFlashOnImage];
            break;
        case AVCaptureFlashModeOff:
            image = [DKCameraResource cameraFlashOffImage];
        default:
            break;
    }
    return image;
}
- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton new];
        [_flashButton addTarget:self action:@selector(switchFlashMode) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _flashButton;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
        
    }
    
    if (!self.motionManager.isAccelerometerActive) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error) {
                UIDeviceOrientation currentOrientation = [DKCamera toDeviceOrientationFor:accelerometerData.acceleration] != UIDeviceOrientationUnknown ? [DKCamera toDeviceOrientationFor:accelerometerData.acceleration] : self.currentOrientation;
                
                if (self.currentOrientation == UIDeviceOrientationUnknown) {
                    [self initialOriginalOrientationForOrientation];
                    self.currentOrientation = self.originalOrientation;
                }
                
                if (self.currentOrientation != currentOrientation) {
                    self.currentOrientation = currentOrientation;
                    [self updateContentLayoutForCurrentOrientation];
                }
                
            }else{
                NSLog(@"error while update accelerometer:%@",error.localizedDescription);
            }
        }];
        [self updateSession:YES];
    }

}

- (void)viewDidAppear:(BOOL)animated{

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDevices];
    [self setupUI];
    [self setupSession];
    [self setupMotionManager];
    // Do any additional setup after loading the view.
}

- (void)setupMotionManager{
    self.motionManager.accelerometerUpdateInterval = 0.5;
    self.motionManager.gyroUpdateInterval = 0.5;
}
- (void)setupSession{
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [self setupCurrentDevice];
    
   AVCaptureStillImageOutput * stillImageOutput = [AVCaptureStillImageOutput new];
    if ([self.captureSession canAddOutput:stillImageOutput]) {
        [self.captureSession addOutput:stillImageOutput];
        self.stillImageOutput = stillImageOutput;
    }
    
    if (self.onFaceDetection != nil) {
       AVCaptureMetadataOutput * metadataOutput = [AVCaptureMetadataOutput new];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("MetadataOutputQueue",  DISPATCH_QUEUE_CONCURRENT)];
        
        if ([self.captureSession canAddOutput:metadataOutput]) {
            [self.captureSession addOutput:metadataOutput];
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        }
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight - kTopBarHeight - kBottomBarHeight);
    
    CALayer * rootLayer = self.view.layer;
    rootLayer.masksToBounds = YES;
    [rootLayer addSublayer:self.previewLayer];
//    [rootLayer insertSublayer:self.previewLayer atIndex:0];
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (self.onFaceDetection) {
        self.onFaceDetection(metadataObjects);
    }
}

- (UIButton *)cameraSwitchButton{
    if (!_cameraSwitchButton) {
        _cameraSwitchButton = [UIButton new];
        [_cameraSwitchButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        [_cameraSwitchButton setImage:[DKCameraResource cameraSwitchImage] forState:UIControlStateNormal];
        [_cameraSwitchButton sizeToFit];
    }
    return _cameraSwitchButton;
}

- (UIButton *)captureButton{
    if (!_captureButton) {
        CGFloat bottomViewHeight = 100;
        _captureButton = [DKCaptureButton new];
        [_captureButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        CGSize size = CGSizeMake(bottomViewHeight - 30, bottomViewHeight-30);
        CGSize newSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(0.9, 0.9));
        _captureButton.bounds = CGRectMake(0, 0, newSize.width, newSize.height);
        _captureButton.centerY = bottomViewHeight/2 + 50;
        _captureButton.layer.cornerRadius = _captureButton.bounds.size.height / 2;
        _captureButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _captureButton.layer.borderWidth = 2;
        _captureButton.layer.masksToBounds = YES;
    }
    return _captureButton;
}

- (void)setupUI{
    self.view.backgroundColor = kBackColor;
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.view.bounds;
    
    CGFloat bottomViewHeight = kBottomBarHeight;

    self.captureButton.center = CGPointMake(self.contentView.bounds.size.width / 2, kScreenHeight - 7 - self.captureButton.height/2);
    self.captureButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.captureButton];

    
    UIButton * cancelButton = [UIButton new];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[DKCameraResource cameraCancelImage] forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    cancelButton.frame = CGRectMake(self.contentView.bounds.size.width - cancelButton.bounds.size.width - 15, 10, cancelButton.frame.size.width, cancelButton.frame.size.height);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:cancelButton];
    
    self.flashButton.frame = CGRectMake(5, 10, self.flashButton.frame.size.width, self.flashButton.frame.size.height);
    [self.contentView addSubview:self.flashButton];
    
//  [self.contentView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)]];
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocus:)]];
    
    UIView *circle = [UIView new];
    circle.width = 6;
    circle.height = 6;
    circle.layer.cornerRadius = 3;
    circle.layer.masksToBounds = YES;
    circle.backgroundColor = kForegroundColor;
    circle.top = kScreenHeight - kBottomBarHeight + 2;
    circle.centerX = self.contentView.centerX;
    [self.contentView addSubview:circle];
    
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kBottomBarHeight + 8, 2*kLabelWidth, 20)];

    [self.contentView addSubview:self.labelContainerView];
    self.labelContainerView.centerX = self.contentView.centerX + kLabelWidth/2;
    
    
    self.foregroundColor = kForegroundColor;
    
    self.singleLabel = [UILabel new];
    self.singleLabel.textColor = kForegroundColor;
    self.singleLabel.textAlignment = NSTextAlignmentCenter;
    self.singleLabel.frame = CGRectMake(0, 0, kLabelWidth, 20);
    self.singleLabel.text = @"single";
    self.singleLabel.font = [UIFont systemFontOfSize:14];
    self.singleLabel.userInteractionEnabled = YES;
    [self.labelContainerView addSubview: self.singleLabel];
    UITapGestureRecognizer * tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingle)];
    [self.singleLabel addGestureRecognizer:tapSingle];
    
    self.continousLabel = [UILabel new];
    self.continousLabel.textColor = kNotForegroundColor;
    self.continousLabel.font = [UIFont systemFontOfSize:14];
    self.continousLabel.frame = CGRectMake(kLabelWidth, 0, kLabelWidth, 20);
    self.continousLabel.text = @"continous";
    self.continousLabel.textAlignment = NSTextAlignmentCenter;
    [self.labelContainerView addSubview: self.continousLabel];
    UITapGestureRecognizer * tapContinious = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContinious)];
    self.continousLabel .userInteractionEnabled = YES;
    [self.continousLabel addGestureRecognizer:tapContinious];
    
    UISwipeGestureRecognizer * right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchModel:)];//UISwipeGestureRecognizer(target: self, action: #selector(switchModel(_:)))
    UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchModel:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.contentView addGestureRecognizer:left];
    [self.contentView addGestureRecognizer:right];
    
    
    CGFloat pad = 35;
    _iv.frame = CGRectMake(20, kScreenHeight - kIVWidth - 5 , kIVWidth, kIVWidth);
    _iv.backgroundColor = [UIColor grayColor];
    _iv.userInteractionEnabled = YES;
    _iv.contentMode = UIViewContentModeScaleAspectFill;
    _iv.clipsToBounds = YES;
    [_iv setContentMode:[UIScreen mainScreen].scale];
    _iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:_iv];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browserContinousImages)];
    [_iv addGestureRecognizer:tap];
    
    
    
    
    CGFloat lW = 20;
    _ivCountLabel.frame = CGRectMake(0, 0, lW, lW);
    _ivCountLabel.layer.cornerRadius = lW/2;
    _ivCountLabel.layer.masksToBounds = YES;
    _ivCountLabel.textColor = [UIColor whiteColor];
    _ivCountLabel.textAlignment = UIViewContentModeScaleAspectFit;
    _ivCountLabel.backgroundColor = [UIColor redColor];
    _ivCountLabel.center = CGPointMake(_iv.right, _iv.top);
    [_contentView addSubview:_ivCountLabel];
    
    _completionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _completionButton.frame = CGRectMake(0, 0, 60, 30);
    _completionButton.left = kScreenWidth - 20 - _completionButton.width;
    _completionButton.centerY = _iv.centerY;
    [_completionButton setTitle:@"完成" forState:UIControlStateNormal];
    [_contentView addSubview:_completionButton];
    [_completionButton addTarget:self action:@selector(completeAction:) forControlEvents: UIControlEventTouchUpInside];
    _completionButton.hidden = YES;
}

- (void)switchModel:(UISwipeGestureRecognizer *)recognizer{
    //1. 判断手势滑动方向
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self scrollRightAnimation];
    }else{
        [self scrollLeftAnimation];
        
    }
}

- (void)tapSingle{
    [self scrollLeftAnimation];
}

- (void)tapContinious{
    [self scrollRightAnimation];
}

- (void)scrollLeftAnimation{
    [UIView animateWithDuration:0.28 animations:^{
        self.labelContainerView.centerX = self.contentView.centerX + kLabelWidth/2;
    } completion:^(BOOL finished) {
        if (self.modeType != CameraModeSingleShotType) {
            self.modeType = CameraModeSingleShotType;
            self.singleLabel.textColor = self.foregroundColor;
            self.continousLabel.textColor = kNotForegroundColor;
        }
    }];
}

- (void)scrollRightAnimation{
    [UIView animateWithDuration:0.28 animations:^{
        self.labelContainerView.centerX = self.contentView.centerX - kLabelWidth/2;
    } completion:^(BOOL finished) {
        if (self.modeType != CameraModeContinuousType) {
            self.modeType = CameraModeContinuousType;
            self.continousLabel.textColor = kForegroundColor;
            self.singleLabel.textColor = kNotForegroundColor;
        }
    }];
}

- (void)completeAction:(id)btn{
    DKImagePickController *d = (DKImagePickController *)self.navigationController;
    if (d.didConfirmContinousImage) {
        d.didConfirmContinousImage(self.continousImages);
    }

    [d dismissViewControllerAnimated:YES completion:nil];
}
- (void)setupDevices{
    NSArray<AVCaptureDevice *> * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.captureDeviceRear = device;
        }
        if (device.position == AVCaptureDevicePositionFront) {
            self.captureDeviceFront = device;
        }
    }
    
    switch (self.defaultCaptureDevice) {
        case PWCameraDeviceSourceFrontType:
            self.currentDevice = self.captureDeviceFront?:self.captureDeviceRear;
            break;
        case DKCameraDeviceSourceRearType:
            self.currentDevice = self.captureDeviceRear?:self.captureDeviceFront;
        default:
            break;
    }
}

- (void)startSession{
    self.isStopped = NO;
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopSession{
    [self pauseSession];
    [self.captureSession stopRunning];
}
- (void)pauseSession{
    self.isStopped = YES;
    [self updateSession:NO];
}

- (void)updateSession:(BOOL)isEnable{
    if (!self.isStopped || (self.isStopped && isEnable)) {
        self.previewLayer.connection.enabled = isEnable;
    }
}

- (void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.didCancel) {
        self.didCancel();
    }
}


- (void)takePicture{
   AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    
    if (self.stillImageOutput && !self.stillImageOutput.isCapturingStillImage) {
        self.captureButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
           AVCaptureConnection * connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (connection) {
                connection.videoOrientation = [DKCamera toAVCaptureVideoOrientation:self.currentOrientation];
                connection.videoScaleAndCropFactor = self.zoomScale;
                [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                    if (!error) {
                      NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        
                        UIImage * takenImage = [UIImage imageWithData:imageData];
                        if (imageData && takenImage) {
                            CGRect outputRect = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
                            
                            CGImageRef takenCGImage = takenImage.CGImage;
                            CGFloat width = CGImageGetWidth(takenCGImage);
                            CGFloat height = CGImageGetHeight(takenCGImage);
                            
                            CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
                            
                            CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
                            
                            UIImage * cropTakenImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:takenImage.imageOrientation];
                            if (self.modeType == CameraModeSingleShotType) {
                                [self handleSingleImage:cropTakenImage];
                            }else{
                                [self handleContinousImage:cropTakenImage];
                            }
                           
                            self.captureButton.enabled = YES;
                            if (self.didFinishCapturingImage) {
                                self.didFinishCapturingImage(cropTakenImage);

                            }
                        }
                    }else{
                        NSLog(@"error while capturing still image %@", error.localizedDescription);
                        self.captureButton.enabled = YES;

                    }

                }];
            }
        });
    }
}

- (void)handleContinousImage:(UIImage *)image{
    [_continousImages addObject:image];
    [self showContinousImageView];
}

- (void)handleSingleImage:(UIImage *)image{
    NSMutableArray * items = @[].mutableCopy;
    YYPhotoGroupItem * item = [[YYPhotoGroupItem alloc] init];
    item.image = image;
    [items addObject:item];
    PWBrowserImageViewController * c = [[PWBrowserImageViewController alloc] initWithGroupItems:items];
    __weak typeof (self) weakSelf = self;
    [c setSingleConfirmAction:^{
        DKImagePickController *d = (DKImagePickController *)weakSelf.navigationController;
        if (d.didConfirmSingleImage) {
            d.didConfirmSingleImage(image);
        }
    }];
    [self.navigationController pushViewController:c animated:YES];
//    YYBrowserViewController * c = [[YYBrowserViewController alloc] initWithItems:items];
//    __weak typeof (self) weakSelf = self;
//    [c setSingleConfirmAction:^{
//        DKImagePickController *d = (DKImagePickController *)weakSelf.navigationController;
//        if (d.didConfirmSingleImage) {
//            d.didConfirmSingleImage(image);
//
//        }
//    }];
//    [self.navigationController pushViewController:c animated:YES];
}

- (void)handleZoom:(UIPinchGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.beginZoomScale = self.zoomScale;
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        self.zoomScale = MIN(4.0, MAX(1.0, self.beginZoomScale * gesture.scale));
        [CATransaction begin];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.zoomScale, self.zoomScale)];
        [CATransaction commit];
    }
}

- (void)handleFocus:(UITapGestureRecognizer *)gesture{
    if (self.currentDevice && self.currentDevice.isFocusPointOfInterestSupported) {
        CGPoint touchPoint = [gesture locationInView:self.view];
        [self focusAtTouchPoint:touchPoint];
    }
}

- (void)focusAtTouchPoint:(CGPoint)touchPoint{
    if (self.currentDevice == nil || self.currentDevice.isFlashAvailable == NO) {
        return;
    }
    if (CGRectContainsPoint(CGRectMake(0, 0, kScreenWidth, kTopBarHeight), touchPoint) || CGRectContainsPoint(CGRectMake(0, kScreenHeight - kBottomBarHeight, kScreenWidth, kBottomBarHeight), touchPoint)) {
        return;
    }
    CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:touchPoint];
   
    [self showFocusViewAtPoint:touchPoint];
    
    if (self.currentDevice) {
        [self.currentDevice lockForConfiguration:nil];
        self.currentDevice.focusPointOfInterest = focusPoint;
        self.currentDevice.exposurePointOfInterest = focusPoint;
        
        self.currentDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        
        if ([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.currentDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [self.currentDevice unlockForConfiguration];
    }
    
    
    

}

- (void)showFocusViewAtPoint:(CGPoint)touchPoint{
    
    
    self.focusView.transform = CGAffineTransformIdentity;
    self.focusView.center = touchPoint;
    
    [self.view addSubview:self.focusView];
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.focusView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    } completion:^(BOOL finished) {
        [self.focusView removeFromSuperview];
    } ];
    
    
}
- (UIView *)focusView{
    if (!_focusView) {
        _focusView = [UIView new];
        CGFloat diameter = 100.0;
        _focusView.bounds = CGRectMake(0, 0, diameter, diameter);
        _focusView.layer.borderWidth = 2;
        _focusView.layer.cornerRadius = diameter / 2;
        _focusView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _focusView;
}


- (void)switchCamera{
    self.currentDevice = self.currentDevice == self.captureDeviceRear ? self.captureDeviceFront : self.captureDeviceRear;
    [self setupCurrentDevice];
    
}

- (void)setupCurrentDevice{
    if (self.currentDevice){
        if (self.currentDevice.isFlashAvailable) {
            self.flashButton.hidden = NO;
            self.flashMode = [self flashModeFromUserDefaults];
            
            
        }else{
            self.flashButton.hidden = YES;
        }
        
        for (AVCaptureInput * oldInput in self.captureSession.inputs) {
            [self.captureSession removeInput:oldInput];
        }
        
        AVCaptureDeviceInput * frontInput =  [AVCaptureDeviceInput deviceInputWithDevice:self.currentDevice error:nil];
        
        if ([self.captureSession canAddInput:frontInput]) {
            [self.captureSession addInput:frontInput];
        }
        
        [self.currentDevice lockForConfiguration:nil];
        if ([self.currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.currentDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.currentDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        
        [self.currentDevice unlockForConfiguration];
        
    }
}

- (AVCaptureFlashMode)flashModeFromUserDefaults{
   AVCaptureFlashMode rawValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"DKCamera.flashMode"];
    return rawValue;
}

+ (AVCaptureVideoOrientation)toAVCaptureVideoOrientation:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
}

- (void)switchFlashMode{
    switch (self.flashMode) {
        case AVCaptureFlashModeAuto:
            self.flashMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOn:
            self.flashMode = AVCaptureFlashModeAuto;
            break;
        case AVCaptureFlashModeOff:
            self.flashMode = AVCaptureFlashModeOn;
            break;
        default:
            break;
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
                    from:(AVCaptureConnection *)connection
{
    if (self.onFaceDetection) {
        self.onFaceDetection(metadataObjects);
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}


- (void)initialOriginalOrientationForOrientation{
    self.originalOrientation = [DKCamera toDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if (self.previewLayer.connection) {
        self.previewLayer.connection.videoOrientation = [DKCamera toAVCaptureVideoOrientation:self.originalOrientation];
    }
}

- (void)updateContentLayoutForCurrentOrientation{
    CGFloat newAngle = [DKCamera toAngleRelativeToPortrait:self.currentOrientation] - [DKCamera toAngleRelativeToPortrait:self.originalOrientation];
    
    if (self.allowsRotate) {
        CGSize contentViewNewSize;
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        if (UIDeviceOrientationIsLandscape(self.currentOrientation)) {
            contentViewNewSize = CGSizeMake(MAX(width, height), MIN(width, height));
        }else{
            contentViewNewSize = CGSizeMake(MIN(width, height), MAX(width, height));
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.bounds = CGRectMake(0, 0, contentViewNewSize.width, contentViewNewSize.height);
            self.contentView.transform = CGAffineTransformMakeRotation(newAngle);
        }];
    }else{
      CGAffineTransform rotateAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, newAngle);
        [UIView animateWithDuration:0.2 animations:^{
            self.flashButton.transform = rotateAffineTransform;
            self.cameraSwitchButton.transform = rotateAffineTransform;
        }];
    }
}

+ (UIDeviceOrientation)toDeviceOrientation:(UIInterfaceOrientation)orientation{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIDeviceOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIDeviceOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return UIDeviceOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return UIDeviceOrientationLandscapeRight;
            break;
        default:
            return UIDeviceOrientationPortrait;
            break;
    }
}

+ (CGFloat)toAngleRelativeToPortrait:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            return -M_PI_2;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return M_PI_2;
            break;
        default:
            return 0.0;
            break;
    }
}

+ (UIDeviceOrientation)toDeviceOrientationFor:(CMAcceleration)acceleration{
    if (acceleration.x >= 0.75) {
        return UIDeviceOrientationLandscapeRight;
    }else if (acceleration.x <= -0.75){
        return UIDeviceOrientationLandscapeLeft;
    }else if (acceleration.y <= -0.75){
        return UIDeviceOrientationPortrait;
    }else if (acceleration.y >= 0.75){
        return UIDeviceOrientationPortraitUpsideDown;
    }else{
        return UIDeviceOrientationUnknown;
    }
}

- (void)modeChange:(id)view{
    CameraModeView *modeView = view;
    self.modeType = modeView.cameraModel;
    if (modeView.cameraModel == CameraModeSingleShotType) {
        [self hideContinousImageView:YES];
    }else{
        if (self.continousImages.count > 0) {
            [self showContinousImageView];
        }else{
            [self hideContinousImageView:YES];
        }
    }
}



- (void)showContinousImageView{
    if (self.continousImages.count == 0){
        [self hideContinousImageView:YES];
        _iv.image = nil;
        _ivCountLabel.text = @"";
        return;
    }
    [self hideContinousImageView:NO];
    _iv.image = self.continousImages.lastObject;
    _ivCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.continousImages.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModeType:(CameraModeType)modeType{
    _modeType = modeType;
    if (modeType == CameraModeSingleShotType) {
        [self hideContinousImageView:YES];
    }else{
        if (self.continousImages.count > 0) {
            [self showContinousImageView];
        }else{
            [self hideContinousImageView:YES];
        }
    }
}
- (void)browserContinousImages{
    if (_continousImages.count < 1) {
        return;
    }
    NSMutableArray *items = @[].mutableCopy;
    for (UIImage *image in _continousImages) {
        YYPhotoGroupItem *item = [[YYPhotoGroupItem alloc] init];
        item.image = image;
        [items addObject:item];
    }
    
    PWBrowserImageViewController  * vc = [[PWBrowserImageViewController alloc] initWithGroupItems:items];
    vc.modeType = CameraModeContinuousType;
    [vc setDidDeleteImage:^(NSInteger idx) {
        [self.continousImages removeObjectAtIndex:idx];
        [self showContinousImageView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
//    YYBrowserViewController * vc = [[YYBrowserViewController alloc] initWithItems:items];
//    vc.modeType = CameraModeContinuousType;
//    [vc setDidDeleteImage:^(NSInteger idx) {
//        NSLog(@"%ld", (long)idx);
//        [self.continousImages removeObjectAtIndex:idx];
//        [self showContinousImageView];
//    }];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
