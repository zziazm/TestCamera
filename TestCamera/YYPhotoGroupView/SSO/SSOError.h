//
//  SSOError.h
//  PwC SSO
//
//  Created by Nep Tong on 3/8/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSOError : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

- (id)initWithTitle:(NSString *)aTitle message:(NSString *)aMessage;
@end
