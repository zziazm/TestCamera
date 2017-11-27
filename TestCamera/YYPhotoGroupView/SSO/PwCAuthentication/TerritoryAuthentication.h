//
// Created by Nep Tong on 4/10/14.
// Copyright (c) 2014 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticatedUserInfo.h"
#import "TitleMessage.h"


@interface TerritoryAuthentication : NSObject

+ (AuthenticatedUserInfo *)authenticateUserToken:(NSString *)userToken titleMessage:(TitleMessage **)titleMessage;

@end