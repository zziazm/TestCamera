//
//  SSOKeychainAccessor.m
//  PwCAuthentication
//
//  Created by Nep on 12/5/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import "SSOKeychainAccessor.h"
#import "SSKeychain.h"
#import "KeychainUserInfo.h"

#define SERVICE_NAME @"PwCSSO"

@implementation SSOKeychainAccessor

+ (KeychainUserInfo *)getKeychainUserInfo
{
    KeychainUserInfo *userInfo = nil;
    NSArray *array = [SSKeychain accountsForService:SERVICE_NAME];
    if (array && array.count > 0)
    {
        NSString *userString = [[array objectAtIndex:0] objectForKey:(__bridge id)kSecAttrAccount];
        NSString *userToken = [SSKeychain passwordForService:SERVICE_NAME account:userString];
        NSArray *elements = [userString componentsSeparatedByString:@"|"];
        
        userInfo = [[KeychainUserInfo alloc] init];
        userInfo.token = userToken;
        userInfo.staffName = [elements objectAtIndex:0];
        if (elements.count > 1)
        {
            userInfo.staffId = [elements objectAtIndex:1];
        }
    }
    return userInfo;
}

@end
