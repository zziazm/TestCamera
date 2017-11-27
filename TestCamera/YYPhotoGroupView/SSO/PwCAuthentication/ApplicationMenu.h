//
//  ApplicationMenu.h
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationMenu : NSObject

@property (strong, nonatomic) NSString *activeFlag;
@property (strong, nonatomic) NSString *applicationCode;
@property (strong, nonatomic) NSString *menuID;
@property (strong, nonatomic) NSString *menuName;
@property (strong, nonatomic) NSString *menuTarget;
@property (strong, nonatomic) NSString *menuURL;
@property (strong, nonatomic) NSString *parentMenuID;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)arrayFromJSONDicArray:(NSArray *)dicArray;
@end
