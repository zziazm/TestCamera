//
//  ApplicationRole.h
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationRole : NSObject

@property (strong, nonatomic) NSString *activeFlag;
@property (strong, nonatomic) NSString *applicationCode;
@property (strong, nonatomic) NSString *roleID;
@property (strong, nonatomic) NSString *roleName;
@property (strong, nonatomic) NSString *roleType;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)arrayFromJSONDicArray:(NSArray *)dicArray;
@end
