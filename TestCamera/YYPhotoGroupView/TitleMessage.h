//
// Created by Nep Tong on 4/10/14.
// Copyright (c) 2014 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TitleMessage : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

+ (TitleMessage *)networkError;
+ (TitleMessage *)unknownError;
+ (TitleMessage *)serverError;
@end