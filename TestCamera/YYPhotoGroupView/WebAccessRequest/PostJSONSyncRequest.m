//
//  PostJSONSyncRequest.m
//  vExpense
//
//  Created by Nep Tong on 10/23/13.
//  Copyright (c) 2013 PricewaterhouseCoopers Limited. All rights reserved.
//

#import "PostJSONSyncRequest.h"
#import "Reachability.h"

@implementation PostJSONSyncRequest
{
    NSMutableDictionary *_httpHeader;
    NSData *_responseData;
    id _resultObject;
}

@synthesize serviceUrl = _serviceUrl;
@synthesize bodyObject = _bodyObject;

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpHeader = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSData *)resultData
{
    return _responseData;
}

- (id)resultObject
{
    if (!_resultObject && _responseData)
    {
        NSError *error;
        _resultObject = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    }
    return _resultObject;
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_httpHeader setObject:value forKey:field];
    
}

- (WebAccessResult)start
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]== NotReachable)
        // Check connection
    {
        return WebAccessResultNoConnection;
    }
    
    NSURL *url = [[NSURL alloc] initWithString:_serviceUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    for (NSString *field in _httpHeader.allKeys)
    {
        [request setValue:[_httpHeader objectForKey:field] forHTTPHeaderField:field];
    }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (_bodyObject)
    {
        // Content-Type
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        // HTTPBody
        NSData *bodyData = [self dataFromBodyObject];
        [request setHTTPBody:bodyData];
        
        // Content-Length
        NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)bodyString.length];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
    }
    
    NSError *error;
    _responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
        return WebAccessResultFailed;
    }
    return WebAccessResultDone;
}

- (NSData *)dataFromBodyObject
{
    if ([_bodyObject isKindOfClass:[NSString class]])
    {
        NSString *quotedString = [NSString stringWithFormat:@"\"%@\"", _bodyObject];
        return [quotedString dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        return [NSJSONSerialization dataWithJSONObject:_bodyObject options:kNilOptions error:nil];
    }
}
@end
