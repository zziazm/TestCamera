//
//  HttpDownloadProgressDelegate.h
//  WebAccessRequest
//
//  Created by Nep on 10/26/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpDownloadProgressDelegate <NSObject>

- (void)setProgress:(float)newProgress;

@end
