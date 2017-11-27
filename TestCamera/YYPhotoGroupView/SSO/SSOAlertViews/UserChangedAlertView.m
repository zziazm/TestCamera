//
//  UserChangedAlertView.m
//  PwC App1
//
//  Created by Nep on 12/11/12.
//  Copyright (c) 2012 PwC. All rights reserved.
//

#import "UserChangedAlertView.h"

@implementation UserChangedAlertView

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
    return [super initWithTitle:@"User changed" message:@"Login information has changed, for security reasons, please reopen this app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    abort();
}
@end
