//
//  WCFSoapRequest.h
//  WebAccessRequest
//
//  Created by Nep on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import "WebRequestBase.h"

@interface WCFSoapRequest : NSObject<NSURLConnectionDelegate>

@property (strong, nonatomic) NSString *serviceUrl;
@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSString *methodXmlns;
@property (strong, nonatomic) NSArray *parameters;
@property (strong, nonatomic) NSString *soapAction;
@property (strong, nonatomic) NSString *resultString;
@property (strong, nonatomic, readonly) NSData *resultData;
@property BOOL isCancelled;

- (id)init;
- (WebAccessResult)start;
- (void)cancel;
@end



@interface WCFSoapRequestParam : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *value;

- (id)initWithValue:(NSString *)value forName:(NSString *)name;
@end