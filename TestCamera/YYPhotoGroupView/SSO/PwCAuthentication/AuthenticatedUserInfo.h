//
//  AuthenticatedUserInfo2.h
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticatedUserInfo : NSObject

@property (strong, nonatomic) NSString *activeFlag;
@property (strong, nonatomic) NSString *additionUserID;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *mobileNumber;
@property int rootGroupID;
@property int userID;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) NSArray *menus;
@property (strong, nonatomic) NSArray *roles;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
