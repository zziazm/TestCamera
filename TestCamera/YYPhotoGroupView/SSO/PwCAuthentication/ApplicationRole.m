//
//  ApplicationRole.m
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "ApplicationRole.h"

@implementation ApplicationRole

@synthesize activeFlag;
@synthesize applicationCode;
@synthesize roleID;
@synthesize roleName;
@synthesize roleType;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.activeFlag = [dictionary objectForKey:@"ActiveFlag"];
        self.applicationCode = [dictionary objectForKey:@"ApplicationCode"];
        self.roleID = [dictionary objectForKey:@"RoleID"];
        self.roleName = [dictionary objectForKey:@"RoleName"];
        self.roleType = [dictionary objectForKey:@"RoleType"];
    }
    return self;
}

+ (NSArray *)arrayFromJSONDicArray:(NSArray *)dicArray
{
    NSMutableArray *array = nil;
    if (dicArray)
    {
        array = [[NSMutableArray alloc] initWithCapacity:dicArray.count];
        for (NSDictionary *dic in dicArray)
        {
            ApplicationRole *role = [[ApplicationRole alloc] initWithDictionary:dic];
            [array addObject:role];
        }
    }
    return array;
}
@end
