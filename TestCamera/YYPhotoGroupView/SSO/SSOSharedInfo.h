//
//  SharedInfo.h
//  PwC App1
//
//  Created by Nep on 12/6/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyChainAccessor/KeychainUserInfo.h"

@interface SSOSharedInfo : NSObject

@property BOOL hasAuthenticated;
@property (strong, nonatomic) KeychainUserInfo *userInfo;
+ (SSOSharedInfo *)sharedInstance;

@end
