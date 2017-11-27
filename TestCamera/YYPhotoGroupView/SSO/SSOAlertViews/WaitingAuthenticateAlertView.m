//
//  WaitingAuthenticateAlertView.m
//  PwC App1
//
//  Created by Nep on 12/11/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import "WaitingAuthenticateAlertView.h"
@interface WaitingAuthenticateAlertView()
{
    UIActivityIndicatorView *_activityIndicatorView;
}
@end

@implementation WaitingAuthenticateAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initNew
{
    self = [super initWithTitle:@"Authenticating..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.frame = CGRectMake(130,60, 20, 20);
        [self addSubview:_activityIndicatorView];
    }
    return self;
}

- (void)show
{
    [_activityIndicatorView startAnimating];
    [super show];
}

@end
