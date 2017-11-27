//
//  OfflineSSODelegate.h
//  Hybrid Framework for iPad
//
//  Created by Nep Tong on 2/26/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OfflineSSODelegate <NSObject>

@required
- (void)resumeFromOfflineSSO:(BOOL)authenticated;

@end
