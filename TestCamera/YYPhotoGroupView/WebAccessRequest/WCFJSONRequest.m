//
//  WCFJSONRequest.m
//  iOS Common Components
//
//  Created by NuNu on 13-1-23.
//  Copyright (c) 2013年 PwC. All rights reserved.
//

#import "WCFJSONRequest.h"
#import "Reachability.h"

@interface WCFJSONRequest()
{
    NSCondition *_condition;
    WebAccessResult _webAccessResult;
    NSURLConnection *_connection;
    NSMutableDictionary *_httpHeader;
    NSThread *_connectionThread;
    NSMutableData *_responseData;
    id _resultObject;
}
@end

@implementation WCFJSONRequest

@synthesize httpMethod = _httpMethod;
@synthesize serviceUrl = _serviceUrl;
@synthesize bodyObject = _bodyObject;
@synthesize isCancelled = _isCancelled;

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

- (id)initWithMethod:(HttpMethod)method
{
    self = [super init];
    if (self)
    {
        _webAccessResult = WebAccessResultWaiting;
        _condition = [[NSCondition alloc] init];
        _httpHeader = [[NSMutableDictionary alloc] init];
        _isCancelled = NO;
        _httpMethod = method;
    }
    return self;
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
        _webAccessResult = WebAccessResultNoConnection;
    }
    else
    {
        _connectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(startConnection) object:nil];
        
        // Connect start
        [_connectionThread start];
        
        // Wait for result
        [_condition lock];
        while(_webAccessResult == WebAccessResultWaiting)
            [_condition wait];
        [_condition unlock];
        
        // Terminate threads
        [_connectionThread cancel];
    }
    return _webAccessResult;
}

- (void)cancel
{
    [_connection cancel];
    _webAccessResult = WebAccessResultCancelled;
    [_condition lock];
    [_condition signal];
    [_condition unlock];
    _isCancelled = YES;
}

#pragma mark - Timer
- (void)webAccessTimeOut:(NSTimer *) timer
{
    _webAccessResult = WebAccessResultTimeOut;
    [_condition lock];
    [_condition signal];
    [_condition unlock];
}
#pragma mark - Connection
- (NSURLConnection *)makeConnection
{
    
    // Url
    NSURL *url = [NSURL URLWithString:_serviceUrl];
    
    // Request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    
    for (NSString *field in _httpHeader.allKeys)
    {
        [urlRequest setValue:[_httpHeader objectForKey:field] forHTTPHeaderField:field];
    }
    
    // HttpMethod
    if (_httpMethod == HttpMethodGET)
    {
        [urlRequest setHTTPMethod:@"GET"];
    }
    else if (_httpMethod == HttpMethodPOST)
    {
        [urlRequest setHTTPMethod:@"POST"];
    }
    else if (_httpMethod == HttpMethodPUSH)
    {
        [urlRequest setHTTPMethod:@"PUSH"];
    }
    else if (_httpMethod == HttpMethodDELETE)
    {
        [urlRequest setHTTPMethod:@"DELETE"];
    }
    
    if (_bodyObject)
    {        
        // Content-Type
        [urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        // HTTPBody
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:_bodyObject options:kNilOptions error:&error];
        [urlRequest setHTTPBody:bodyData];
        
        // Content-Length
        NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)bodyString.length];
        [urlRequest addValue:length forHTTPHeaderField:@"Content-Length"];
    }    
    return [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
}

- (void)startConnection
{
    // Create Connection
    _connection = [self makeConnection];
    [_connection start];
    
    do
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    while (![NSThread currentThread].isCancelled);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    //    NSLog(@"code: %d", [httpResponse statusCode]);
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)responseData
{
    [_responseData appendData:responseData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connection = nil;
    _responseData = nil;
    
    if (error.code == -1001)
    {
        _webAccessResult = WebAccessResultTimeOut;
    }
    else
    {
        _webAccessResult = WebAccessResultFailed;
    }
    [_condition lock];
    [_condition signal];
    [_condition unlock];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_webAccessResult == WebAccessResultWaiting)
    {
        _webAccessResult = WebAccessResultDone;
        [_condition lock];
        [_condition signal];
        [_condition unlock];
    }
}

@end
