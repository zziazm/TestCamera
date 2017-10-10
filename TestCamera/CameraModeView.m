//
//  CameraModeView.m
//  TestCamera
//
//  Created by 赵铭 on 2017/10/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CameraModeView.h"
#import "UIView+YYAdd.h"
#define kLabelWidth 100
#define kLabelFont 14
#define kForegroundColor [UIColor colorWithRed:1 green:0.7 blue:0.006 alpha:1]
#define kNotForegroundColor [UIColor whiteColor]
#define kBackColor [UIColor colorWithRed:32/255.0 green:41/255.0 blue:56/255.0 alpha:1]



@interface CameraModeView ()

@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, strong) CATextLayer *videoTextLayer;
@property (nonatomic, strong) CATextLayer *photoTextLayer;
@property (nonatomic, strong) UIColor * foregroundColor;

@property (nonatomic, strong) UILabel * singleLabel;
@property (nonatomic, strong) UILabel * continousLabel;
@end

@implementation CameraModeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
       
    }
    return self;
}

//- (CATextLayer *)textLayerWithTitle:(NSString *)title{
//    CATextLayer * layer = [CATextLayer new];
//    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17];
////    layer.font = font.fontName;
//    layer.fontSize = 17;
//    layer.string = title;
//    layer.alignmentMode = @"center";
//    layer.contentsScale = [UIScreen mainScreen].scale;//UIScreen.mainScreen().scale
//    return layer;
//}
- (void)setupView{
    self.backgroundColor = kBackColor;
    
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*kLabelWidth, 20)];
    [self addSubview:self.labelContainerView];
    
    self.foregroundColor = kForegroundColor;
    
    self.singleLabel = [UILabel new];
    self.singleLabel.textColor = kForegroundColor;
    self.singleLabel.textAlignment = NSTextAlignmentCenter;
    self.singleLabel.frame = CGRectMake(0, 0, kLabelWidth, 20);
    self.singleLabel.text = @"single";
    self.singleLabel.font = [UIFont systemFontOfSize:14];
    self.singleLabel.userInteractionEnabled = YES;
    [self.labelContainerView addSubview: self.singleLabel];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingle)];
    [self.singleLabel addGestureRecognizer:tap];
    
    
    
//    self.videoTextLayer = [self textLayerWithTitle:@"单拍"];
//    self.videoTextLayer.frame = CGRectMake(0, 0, 60, 20);
//    self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
//    [self.labelContainerView.layer addSublayer: self.videoTextLayer];

    self.continousLabel = [UILabel new];
    self.continousLabel.textColor = kNotForegroundColor;
    self.continousLabel.font = [UIFont systemFontOfSize:14];
    self.continousLabel.frame = CGRectMake(kLabelWidth, 0, kLabelWidth, 20);
    self.continousLabel.text = @"continous";
    self.continousLabel.textAlignment = NSTextAlignmentCenter;
    [self.labelContainerView addSubview: self.continousLabel];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContinious)];
    self.continousLabel .userInteractionEnabled = YES;
    [self.continousLabel addGestureRecognizer:tap1];
//    self.photoTextLayer = [self textLayerWithTitle:@"连拍"];
//    self.photoTextLayer.frame = CGRectMake(60, 0, 60, 20);
//    [self.labelContainerView.layer addSublayer:self.photoTextLayer];
    
    UISwipeGestureRecognizer * right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchModel:)];//UISwipeGestureRecognizer(target: self, action: #selector(switchModel(_:)))
    UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchModel:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:left];
    [self addGestureRecognizer:right];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.labelContainerView.centerX = self.centerX + kLabelWidth/2;
    self.labelContainerView.top = 8;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor);
    CGRect circleRect = CGRectMake(CGRectGetMidX(rect), 2, 6, 6);//CGRect(x: rect.midX - 3, y: 2, width: 6, height: 6)
    CGContextFillEllipseInRect(context, circleRect);
}

- (void)setCameraModel:(CameraModeType)cameraModel{
    _cameraModel = cameraModel;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
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
        self.labelContainerView.centerX = self.centerX + kLabelWidth/2;
    } completion:^(BOOL finished) {
        if (self.cameraModel != CameraModeSingleShotType) {
            self.cameraModel = CameraModeSingleShotType;
            self.singleLabel.textColor = self.foregroundColor;
            self.continousLabel.textColor = kNotForegroundColor;
        }
    }];
}
- (void)scrollRightAnimation{
    [UIView animateWithDuration:0.28 animations:^{
        self.labelContainerView.centerX = self.centerX - kLabelWidth/2;
    } completion:^(BOOL finished) {
        if (self.cameraModel != CameraModeContinuousType) {
            self.cameraModel = CameraModeContinuousType;
            self.continousLabel.textColor = kForegroundColor;
            self.singleLabel.textColor = kNotForegroundColor;
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
