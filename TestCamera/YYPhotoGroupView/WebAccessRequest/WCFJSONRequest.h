//
//  WCFJSONRequest.h
//  iOS Common Components
//
//  Created by NuNu on 13-1-23.
//  Copyright (c) 2013年 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequestBase.h"

typedef enum
{
    HttpMethodGET,
    HttpMethodPOST,
    HttpMethodPUSH,
    HttpMethodDELETE
} HttpMethod;

@interface WCFJSONRequest : NSObject<NSURLConnectionDelegate>

@property HttpMethod httpMethod;
@property (strong, nonatomic) NSString *serviceUrl;
@property (strong, nonatomic) id bodyObject;
@property (strong, nonatomic, readonly) NSData *resultData;
@property (strong, nonatomic, readonly) id resultObject;
@property BOOL isCancelled;

- (id)initWithMethod:(HttpMethod)method;
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (WebAccessResult)start;
- (void)cancel;
@end


