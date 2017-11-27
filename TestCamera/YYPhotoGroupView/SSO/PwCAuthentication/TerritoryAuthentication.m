//
// Created by Nep Tong on 4/10/14.
// Copyright (c) 2014 PwC. All rights reserved.
//

#import "TerritoryAuthentication.h"
#import "KeychainUserInfo.h"
#import "WCFJSONRequest.h"
#import "TitleMessage.h"
#import "ServiceWrapper.h"
#import "SSOKeychainAccessor.h"

#define AUTHENTICATION_URL @"%@ApplicationCenter.RestService/api/applicationservice/GetCurrentUserWithHashCode/?hashcode=%@&appcode=mobile"
#define AUTHENTICATION_AUTHORIZATION_HEADER @"Basic UmVzdEFjY291bnQ6OGlrLChPTA=="

@implementation TerritoryAuthentication {

}

+ (AuthenticatedUserInfo *)authenticateUserToken:(NSString *)userToken titleMessage:(TitleMessage **)titleMessage
{
    AuthenticatedUserInfo *userInfo = nil;
    @try
    {
        WCFJSONRequest *request = [[WCFJSONRequest alloc] initWithMethod:HttpMethodGET];
        NSString *domainString = [[NSBundle mainBundle].infoDictionary objectForKey:@"DomainString"];
        request.serviceUrl = [NSString stringWithFormat:AUTHENTICATION_URL, domainString, userToken];
        [request addValue:AUTHENTICATION_AUTHORIZATION_HEADER forHTTPHeaderField:@"Authorization"];
        
        WebAccessResult result = [request start];
        // The following code won't be executed until the request gets a result.
        if (result == WebAccessResultDone)
        {
            ServiceWrapper *wrapper = [[ServiceWrapper alloc] initWithDictionary:request.resultObject];
            if (wrapper.returnCode == 0)
            {
                userInfo = [[AuthenticatedUserInfo alloc] initWithDictionary:wrapper.data];
            }
            else
            {
                *titleMessage = [[TitleMessage alloc] initWithTitle:@"Server Error" message:wrapper.message];
            }
        }
        else
        {
            *titleMessage = [[TitleMessage alloc] initWithTitle:@"Network Error" message:@"Please check network connection."];
        }
    }
    @catch (NSException *exception)
    {
        *titleMessage = [[TitleMessage alloc] initWithTitle:@"Error" message:exception.reason];
    }
    return  userInfo;
}
@end