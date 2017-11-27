//
//  SSOError.m
//  PwC SSO
//
//  Created by Nep Tong on 3/8/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "SSOError.h"

@implementation SSOError

@synthesize title;
@synthesize message;

- (id)initWithTitle:(NSString *)aTitle message:(NSString *)aMessage
{
    self = [super init];
    if (self)
    {
        self.title = aTitle;
        self.message = aMessage;
    }
    return self;
}
@end
