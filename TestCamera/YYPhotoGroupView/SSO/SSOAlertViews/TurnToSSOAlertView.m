//
//  TurnToSSOAlertView.m
//  PwC App1
//
//  Created by Nep on 12/11/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import "TurnToSSOAlertView.h"

static NSString *_appCode;

@interface TurnToSSOAlertView()

+ (NSString *)getAppCode;

@end

@implementation TurnToSSOAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *url = [NSString stringWithFormat:@"PwCSSO://%@", [TurnToSSOAlertView getAppCode]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (NSString *)getAppCode
{
    if (!_appCode)
    {
        NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        NSDictionary *urlType = [urlTypes objectAtIndex:0];
        NSArray *urlSchemes = [urlType objectForKey:@"CFBundleURLSchemes"];
        _appCode = [urlSchemes objectAtIndex:0];
    }
    return _appCode;
}
@end
