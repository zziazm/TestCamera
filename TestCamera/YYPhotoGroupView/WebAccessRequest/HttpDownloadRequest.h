//
//  HttpDownloadRequest.h
//  WebAccessRequest
//
//  Created by Nep on 10/18/12.
//
//

#import <Foundation/Foundation.h>
#import "WebRequestBase.h"
#import "HttpDownloadProgressDelegate.h"

@interface HttpDownloadRequest : NSObject<NSURLConnectionDelegate>

@property (strong, nonatomic) NSObject<HttpDownloadProgressDelegate> *progressDelegate;

@property (strong, nonatomic) NSString *requestUrl;
@property (strong, nonatomic) NSString *destination;
@property float incrementDisplayPercent;
@property BOOL isCancelled;

- (id)initWithUrl:(NSString *)url destination:(NSString *)destination;
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (WebAccessResult)start;
- (void)cancel;
@end



