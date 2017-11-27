//
//  AuthenticatedUserInfo2.m
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "AuthenticatedUserInfo.h"
#import "ApplicationMenu.h"
#import "ApplicationRole.h"

@implementation AuthenticatedUserInfo

@synthesize activeFlag;
@synthesize additionUserID;
@synthesize emailAddress;
@synthesize mobileNumber;
@synthesize rootGroupID;
@synthesize userID;
@synthesize userName;
@synthesize menus;
@synthesize roles;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.activeFlag = [dictionary objectForKey:@"ActiveFlag"];
        self.additionUserID = [dictionary objectForKey:@"AdditionUserID"];
        self.emailAddress = [dictionary objectForKey:@"EmailAddress"];
        self.mobileNumber = [dictionary objectForKey:@"MobileNo"];
        self.rootGroupID = [[dictionary objectForKey:@"RootGroupID"] intValue];
        self.userID = [[dictionary objectForKey:@"UserID"] intValue];
        self.userName = [dictionary objectForKey:@"UserName"];
        
        self.menus = [ApplicationMenu arrayFromJSONDicArray:[dictionary objectForKey:@"Menus"]];
        self.roles = [ApplicationRole arrayFromJSONDicArray:[dictionary objectForKey:@"Roles"]];
    }
    return self;
}

@end
