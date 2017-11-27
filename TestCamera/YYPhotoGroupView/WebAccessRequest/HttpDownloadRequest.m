//
//  HttpDownloadRequest.m
//  WebAccessRequest
//
//  Created by Nep on 10/18/12.
//
//

#import "HttpDownloadRequest.h"
#import "Reachability.h"

@interface HttpDownloadRequest()
{
    WebAccessResult _webAccessResult;
    NSCondition *_condition;
    NSURLConnection *_connection;
    NSMutableDictionary *_httpHeader;
    NSThread *_connectionThread;
    NSFileHandle *_fileHandler;
    
    long long _dataExpectedBytes;
    long long _dataReceivedBytes;
    long long _incrementDisplay;
    long long _nextDisplay;
}
@end

@implementation HttpDownloadRequest

@synthesize progressDelegate = _progressDelegate;
@synthesize requestUrl = _requestUrl;
@synthesize destination = _destination;
@synthesize incrementDisplayPercent = _incrementDisplayPercent;
@synthesize isCancelled = _isCancelled;

#pragma mark - Public Method
- (id)init
{
    self = [super init];
    if (self)
    {
        _webAccessResult = WebAccessResultWaiting;
        _condition = [[NSCondition alloc] init];
        _httpHeader = [[NSMutableDictionary alloc] init];
        _incrementDisplayPercent = 0;
    }
    return self;
}

- (id)initWithUrl:(NSString *)url destination:(NSString *)destination
{
    self = [self init];
    if (self)
    {
        self.requestUrl = url;
        self.destination = destination;
    }
    return self;
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_httpHeader setObject:value forKey:field];
}

- (WebAccessResult)start
{
    // No Wifi connection
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]== NotReachable)
    {
        _webAccessResult = WebAccessResultNoConnection;
    }
    else
    {
        // Create Connection
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
        
        if (_webAccessResult != WebAccessResultDone)
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:_destination error:&error];            
        }
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

#pragma mark - Connection
- (NSURLConnection *)makeConnection
{
    // Url
    NSURL *url = [NSURL URLWithString:_requestUrl];
    
    // Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:16.0f];
    for (NSString *field in _httpHeader.allKeys)
    {
        [request setValue:[_httpHeader objectForKey:field] forHTTPHeaderField:field];
    }
    
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    return [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
}

- (void)startConnection
{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_destination])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_destination error:&error];
    }
    
    _connection = [self makeConnection];
    [_connection start];
    
    do
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    while (![NSThread currentThread].isCancelled);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"code: %ld", (long)[httpResponse statusCode]);
    _dataExpectedBytes = response.expectedContentLength;
    NSLog(@"expectedContentLength: %lld", _dataExpectedBytes);
    _dataReceivedBytes = 0;
    _incrementDisplay = _dataExpectedBytes / 100 * _incrementDisplayPercent;
    if (_incrementDisplay < _dataExpectedBytes)
    {
        _nextDisplay = _incrementDisplay;
    }
    else
    {
        _nextDisplay = _dataExpectedBytes;
    }
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)responseData
{
    if (_dataReceivedBytes == 0)
    {
        [[NSFileManager defaultManager] createFileAtPath:_destination contents:responseData attributes:nil];
        _fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:_destination];
    }
    else
    {
        [_fileHandler seekToEndOfFile];
        [_fileHandler writeData:responseData];
    }

    _dataReceivedBytes += responseData.length;
    
    if (_dataReceivedBytes >= _nextDisplay)
    {
        // Refresh
        if (_progressDelegate)
        {
            float progress = (float)_dataReceivedBytes / (float)_dataExpectedBytes;
            [_progressDelegate setProgress:progress];
        }
        
        _nextDisplay = _dataReceivedBytes + _incrementDisplay;
        if (_nextDisplay > _dataExpectedBytes)
        {
            _nextDisplay = _dataExpectedBytes;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
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
