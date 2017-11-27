//
//  ApplicationMenu.m
//  PwC SSO
//
//  Created by Nep Tong on 3/7/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "ApplicationMenu.h"
@class ExtensionData;

@implementation ApplicationMenu

@synthesize activeFlag;
@synthesize applicationCode;
@synthesize menuID;
@synthesize menuName;
@synthesize menuTarget;
@synthesize menuURL;
@synthesize parentMenuID;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.activeFlag = [dictionary objectForKey:@"ActiveFlag"];
        self.applicationCode = [dictionary objectForKey:@"ApplicationCode"];
        self.menuID = [dictionary objectForKey:@"MenuID"];
        self.menuName = [dictionary objectForKey:@"MenuName"];
        self.menuTarget = [dictionary objectForKey:@"MenuTarget"];
        self.menuURL = [dictionary objectForKey:@"MenuURL"];
        self.parentMenuID = [dictionary objectForKey:@"ParentMenuID"];
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
            ApplicationMenu *menu = [[ApplicationMenu alloc] initWithDictionary:dic];
            [array addObject:menu];
        }
    }
    return array;    
}

@end
