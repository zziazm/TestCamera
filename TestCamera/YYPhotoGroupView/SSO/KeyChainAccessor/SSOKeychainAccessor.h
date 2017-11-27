//
//  SSOKeychainAccessor.h
//  PwCAuthentication
//
//  Created by Nep on 12/5/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KeychainUserInfo;

@interface SSOKeychainAccessor : NSObject

+ (KeychainUserInfo *)getKeychainUserInfo;

@end