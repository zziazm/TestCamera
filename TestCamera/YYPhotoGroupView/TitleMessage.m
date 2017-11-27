//
// Created by Nep Tong on 4/10/14.
// Copyright (c) 2014 PwC. All rights reserved.
//

#import "TitleMessage.h"


@implementation TitleMessage
{

}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super init];
    if (self)
    {
        self.title = title;
        self.message = message;
    }
    return self;
}

+ (TitleMessage *)networkError
{
    return [[TitleMessage alloc] initWithTitle:(NSString *)@"Network Error" message:@"Please check your network connection."];
}

+ (TitleMessage *)unknownError
{
    return [[TitleMessage alloc] initWithTitle:(NSString *)@"Unknown Error" message:@"Please contact GTS."];
}

+ (TitleMessage *)serverError
{
    return [[TitleMessage alloc] initWithTitle:(NSString *)@"Server Error" message:@"Server Exception."];
}

@end
