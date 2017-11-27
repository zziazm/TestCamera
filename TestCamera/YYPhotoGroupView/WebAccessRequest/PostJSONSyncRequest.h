//
//  PostJSONSyncRequest.h
//  vExpense
//
//  Created by Nep Tong on 10/23/13.
//  Copyright (c) 2013 PricewaterhouseCoopers Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequestBase.h"

@interface PostJSONSyncRequest : NSObject

@property (strong, nonatomic) NSString *serviceUrl;
@property (strong, nonatomic) id bodyObject;
@property (strong, nonatomic, readonly) NSData *resultData;
@property (strong, nonatomic, readonly) id resultObject;
@property BOOL isCancelled;

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (WebAccessResult)start;

@end
