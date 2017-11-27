//
//  WCFSoapRequest.m
//  WebAccessRequest
//
//  Created by Nep on 10/16/12.
//
//

#import "WCFSoapRequest.h"
#import "Reachability.h"

static NSString *soapFormat = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n"
                                    "<soap:Body>\n"
                                        "%@"
                                    "</soap:Body>\n"
                               "</soap:Envelope>\n";

@interface WCFSoapRequest()
{
    NSCondition *_condition;
    WebAccessResult _webAccessResult;
    NSURLConnection *_connection;
    NSThread *_connectionThread;
    NSMutableData *_responseData;
}

- (NSURLConnection *)makeConnection;
@end

@implementation WCFSoapRequest

#pragma mark - Public Properties
@synthesize serviceUrl = _serviceUrl;
@synthesize methodName = _methodName;
@synthesize methodXmlns = _methodXmlns;
@synthesize parameters = _parameters;
@synthesize soapAction = _sopaAction;
@synthesize resultString = _resultString;
@synthesize isCancelled = _isCancelled;

- (NSData *)resultData
{
    return _responseData;
}

- (NSString *)resultString
{
    if (!_resultString)
    {
        [self makeResult];
    }
    return _resultString;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _webAccessResult = WebAccessResultWaiting;
        _condition = [[NSCondition alloc] init];
        _isCancelled = NO;
    }
    return self;
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

#pragma mark - Private Method
- (void)makeResult
{
    switch (_webAccessResult) {
        case WebAccessResultDone:
        {
            _resultString = [self extractResultString];
            break;
        }
        case WebAccessResultCancelled:
        {
            _resultString = @"The request is canceled.";
            break;
        }
        case WebAccessResultFailed:
        {
            _resultString = @"Request failed.";
            break;
        }
        case WebAccessResultTimeOut:
        {
            _resultString = @"Timed out.";
            break;
        }
        default:
            break;
    }
}

- (NSString *)extractResultString
{
    NSString *resultString;
    @try
    {
        NSString *theXML = [[NSString alloc] initWithBytes:_responseData.mutableBytes
                                                    length:_responseData.length
                                                  encoding:NSUTF8StringEncoding];

        NSString *noReturn = [NSString stringWithFormat:@"<%@Result/>", _methodName];

        if ([theXML rangeOfString:noReturn].location != NSNotFound)
        {
            return @"#NoResult#";
        }
        
        NSRange resultRange=[theXML rangeOfString:[NSString stringWithFormat:@"<%@Result", _methodName]];
        resultString=[theXML substringFromIndex:resultRange.location+resultRange.length];
        NSRange resultRange2 = [resultString rangeOfString:@">"];
        NSString *resultString2 = [resultString substringFromIndex:resultRange2.location + 1];
        NSRange resultRangeback=[resultString2 rangeOfString:[NSString stringWithFormat:@"</%@Result>", _methodName]];
        resultString=[resultString2 substringToIndex:resultRangeback.location];
    }
    @catch (NSException *exception)
    {
        resultString = nil;
    }
    return resultString;
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
    // Message
    NSMutableString *methodContent = [[NSMutableString alloc] init];
    
    // <Method>
    if (_methodXmlns)
    {
        [methodContent appendFormat:@"<%@ xmlns=\"%@\">\n", _methodName, _methodXmlns];
    }
    else
    {
        [methodContent appendFormat:@"<%@>\n", _methodName];
    }
    
    // <param> </param>
    for (WCFSoapRequestParam *param in _parameters)
    {
        [methodContent appendFormat:@"<%@>%@</%@>\n", param.name, param.value, param.name];
    }
    
    // </Method>
    [methodContent appendFormat:@"</%@>\n", _methodName];
    
    NSString *soapMessage = [NSString stringWithFormat:soapFormat, methodContent];
    
    // Url
    NSURL *url = [NSURL URLWithString:_serviceUrl];
    
    // Request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:16.0];
    [urlRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)soapMessage.length];
    [urlRequest addValue:length forHTTPHeaderField:@"Content-Length"];
    
    [urlRequest addValue:_sopaAction forHTTPHeaderField:@"SOAPAction"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
}

- (void)startConnection
{
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

@implementation WCFSoapRequestParam

@synthesize name = _name;
@synthesize value = _value;

- (id)initWithValue:(NSString *)value forName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _value = value;
        _name = name;
    }
    return self;
}

@end
