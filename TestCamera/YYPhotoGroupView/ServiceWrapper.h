//
//  ServiceWrapper.h
//  PwC Contacts for iphone
//
//  Created by Nep Tong on 2/18/13.
//
//

#import <Foundation/Foundation.h>

@interface ServiceWrapper : NSObject

@property NSInteger returnCode;
@property (strong, nonatomic) id data;
@property (strong, nonatomic) NSString *message;

- (id)initWithDictionary:(NSDictionary *)aDictionary;
@end
