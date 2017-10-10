//
//  YYPhotoGroupView.h
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/1.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface YYPhotoGroupItem : NSObject

@property (nonatomic, strong, nullable) UIView *thumbView;

@property (nonatomic, assign) CGSize largeImageSize;

@property (nonatomic, strong) NSURL *largeImageURL;

@property (nonatomic, strong) UIImage *image;
@end


@interface YYPhotoGroupView : UIView
@property (nonatomic, copy) void(^dismissCompletion)(void);

@property (nonatomic, readonly) NSArray <YYPhotoGroupItem *> *groupItems;

@property (nonatomic, readonly) NSInteger currentPage;

@property (nonatomic, assign) BOOL blurEffectBackground;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(nullable void(^)(void))completion;

- (void)dismissAnimated:(BOOL)animated;
- (void)dismiss;
- (void)dismissAnimationed:(BOOL)animated completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
