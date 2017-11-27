//
//  SharedInfo.m
//  PwC App1
//
//  Created by Nep on 12/6/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import "SSOSharedInfo.h"

@implementation SSOSharedInfo

@synthesize hasAuthenticated;
@synthesize userInfo;

+ (SSOSharedInfo *)sharedInstance
{
    static SSOSharedInfo *_sharedInstance = nil;
    @synchronized(self)
    {
        if (!_sharedInstance)
        {
            _sharedInstance = [[SSOSharedInfo alloc] init];
        }
        return _sharedInstance;
    }
}

@end
