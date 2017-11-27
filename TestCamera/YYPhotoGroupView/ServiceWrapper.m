//
//  ServiceWrapper.m
//  PwC Contacts for iphone
//
//  Created by Nep Tong on 2/18/13.
//
//

#import "ServiceWrapper.h"

#define RESULT_DIC_KEY_RETURN_VALUE @"ReturnCode"
#define RESULT_DIC_KEY_DATA @"Data"
#define RESULT_DIC_KEY_MESSAGE @"Message"

@implementation ServiceWrapper

@synthesize returnCode = _returnCode;
@synthesize data = _data;
@synthesize message = _message;

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    if (self)
    {
        if ([aDictionary valueForKey:RESULT_DIC_KEY_RETURN_VALUE])
        {
            _returnCode = [[aDictionary valueForKey:RESULT_DIC_KEY_RETURN_VALUE] integerValue];
        }
        else
        {
            _returnCode = -1;
        }
        _data = [aDictionary valueForKey:RESULT_DIC_KEY_DATA];
        _message = [aDictionary valueForKey:RESULT_DIC_KEY_MESSAGE];
    }
    return self;
}

@end
