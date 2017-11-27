
//
//  PwCSSOHelper.m
//  LMS for iPad
//
//  Created by Nep Tong on 1/28/13.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PwCSSOHelper.h"
#import "KeyChainAccessor/SSOKeychainAccessor.h"
#import "PwCAuthentication/TerritoryAuthentication.h"
#import "PwCAuthentication/AuthenticatedUserInfo.h"
#import "KeyChainAccessor/KeychainUserInfo.h"
#import "SSOError.h"
#import "SSOSharedInfo.h"
#import "SSOAlertViews/WaitingAuthenticateAlertView.h"
#import "SSOAlertViews/TurnToSSOAlertView.h"
#import "SSOAlertViews/UserChangedAlertView.h"
#import "ImageHelper/ImageHelper.h"
#import "ImageHelper/ImageHelper-ImageProcessing.h"
#import "UIViewController_PwCSSOAwakeViewController.h"
#import "OfflineSSODelegate.h"
#import "TerritoryAuthentication.h"

static PwCSSOHelper *_sharedInstance;

@implementation PwCSSOHelper
{
    UIViewController *_awakeViewController;
    UIAlertView *_alertView;
    BOOL _isBlurCoverShown;
    UIImageView *_blurCover;
}

#pragma mark - Public Class Method
+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (!_sharedInstance)
        {
            _sharedInstance = [super allocWithZone:zone];
        }
        return _sharedInstance;
    }
}

+ (void)checkSSOOnline
{
    [[self sharedInstance] checkSSOOnlineInner];
}

+ (void)checkSSOOffline
{
    [[self sharedInstance] checkSSOOfflineInner];
}

+ (void)registerAwakeViewController:(UIViewController *)viewController
{
    [[PwCSSOHelper sharedInstance] registerAwakeViewControllerInner:viewController];
}

#pragma mark - Private Class Method
+ (PwCSSOHelper *)sharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (void)checkSSOOnlineInner
{
    if (_alertView)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    KeychainUserInfo *userInfo = [SSOKeychainAccessor getKeychainUserInfo];
    if (![SSOSharedInfo sharedInstance].hasAuthenticated)
    {
        if (userInfo != nil)
        {
            _alertView = [[WaitingAuthenticateAlertView alloc] initNew];
            [self showBlurCoverWithAlertView:_alertView];
            [self performSelectorInBackground:@selector(authenticateUser) withObject:nil];
        }
        else
        {
            _alertView = [[TurnToSSOAlertView alloc] initWithTitle:@"Not logging in" message:@"Please turn to PwC SSO to login."];
            [self showBlurCoverWithAlertView:_alertView];
        }
    }
    else
    {
        if (userInfo == nil || ![userInfo.staffId isEqualToString:[SSOSharedInfo sharedInstance].userInfo.staffId])
        {
            // User changed
            _alertView = [[UserChangedAlertView alloc] initNew];
            [self showBlurCoverWithAlertView:_alertView];
        }
        else
        {
            if (_isBlurCoverShown)
            {
                [self hideBlurCover];
            }
        }
    }
}

- (void)checkSSOOfflineInner
{
    if (_alertView)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    KeychainUserInfo *userInfo = [SSOKeychainAccessor getKeychainUserInfo];
    if (userInfo != nil)
    {
        // Found usertoken in keychain
        if ([SSOSharedInfo sharedInstance].userInfo == nil)
        {
            // Just launched
            if (_isBlurCoverShown)
            {
                [self hideBlurCover];
            }
            
            [SSOSharedInfo sharedInstance].userInfo = userInfo;
            [self offlineCheckSucceeded:NO];
        }
        else
        {
            // Awake from background
            if ([[SSOSharedInfo sharedInstance].userInfo.staffId isEqualToString:userInfo.staffId])
            {
                // Same user
                
                // Update token in memory
                [SSOSharedInfo sharedInstance].userInfo = userInfo;
                
                if (_isBlurCoverShown)
                {
                    [self hideBlurCover];
                }
                [self offlineCheckSucceeded:YES];
            }
            else
            {
                // User changed
                _alertView = [[UserChangedAlertView alloc] initNew];
                [self showBlurCoverWithAlertView:_alertView];
            }
        }
    }
    else
    {
        // Not found usertoken in keychain
        _alertView = [[TurnToSSOAlertView alloc] initWithTitle:@"Not logging in" message:@"Please turn to PwC SSO to login."];
        [self showBlurCoverWithAlertView:_alertView];
    }
}

- (void)registerAwakeViewControllerInner:(UIViewController *)viewController
{
    _awakeViewController = viewController;
}

- (void)authenticateUser
{
    KeychainUserInfo *savedUserInfo = [SSOKeychainAccessor getKeychainUserInfo];
    
    TitleMessage *titleMessage = nil;
    AuthenticatedUserInfo *userInfo = [TerritoryAuthentication authenticateUserToken:savedUserInfo.token titleMessage:&titleMessage];
    
    
    if (titleMessage != nil)
    {
        [self performSelectorOnMainThread:@selector(authenticateError:) withObject:titleMessage waitUntilDone:NO];
    }
    else if (userInfo && ![userInfo isKindOfClass:[NSNull class]] && [userInfo.activeFlag isEqualToString:@"Y"])
    {
        [SSOSharedInfo sharedInstance].userInfo = savedUserInfo;
        [SSOSharedInfo sharedInstance].hasAuthenticated = YES;
        [self performSelectorOnMainThread:@selector(authenticateSucceeded:) withObject:userInfo waitUntilDone:NO];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(authenticateFailed) withObject:nil waitUntilDone:NO];
    }
}

- (void)authenticateSucceeded:(KeychainUserInfo *)userInfo
{
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    if (_isBlurCoverShown)
    {
        [self hideBlurCover];
    }
    if ([_awakeViewController respondsToSelector:@selector(loadAfterAuthenticated)])
    {
        [_awakeViewController loadAfterAuthenticated];
    }
}

- (void)authenticateFailed
{
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    _alertView = [[TurnToSSOAlertView alloc] initWithTitle:@"Login failed" message:@"Please turn to PwC SSO to login."];
    [_alertView show];
}

- (void)authenticateError:(TitleMessage *)titleMessage
{
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    _alertView = [[UIAlertView alloc] initWithTitle:titleMessage.title message:titleMessage.message delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
    [_alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _alertView = [[WaitingAuthenticateAlertView alloc] initNew];
    [self showBlurCoverWithAlertView:_alertView];
    [self performSelectorInBackground:@selector(authenticateUser) withObject:nil];
}

- (void)offlineCheckSucceeded:(BOOL)authenticated
{
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(resumeFromOfflineSSO:)])
    {
        [((NSObject<OfflineSSODelegate> *)[UIApplication sharedApplication].delegate) resumeFromOfflineSSO:authenticated];
    }
}

#pragma mark - Methods migerate from UUIViewController+AlertWithBlurredView.h
- (void)showBlurCoverWithAlertView:(UIAlertView *)alertView
{
    if (!_isBlurCoverShown)
    {
        UIImage *blurredViewShot = [self generateBlurredScreenShot];
        _blurCover = [[UIImageView alloc] initWithImage:blurredViewShot];
        _blurCover.frame = [UIApplication sharedApplication].keyWindow.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:_blurCover];
        
        _isBlurCoverShown = YES;
    }
    
    if (alertView)
    {
        [alertView show];
    }
}

- (void)hideBlurCover
{
    [_blurCover removeFromSuperview];
    _blurCover = nil;
    _isBlurCoverShown = NO;
}

- (UIImage *)generateBlurredScreenShot
{
    UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self gaussianBlurImage:screenShot];
}

- (UIImage *)gaussianBlurImage:(UIImage *)image
{
    UIImage *result = [self scaleImage:image toScale:0.4];
    result = [ImageHelper convolveImage:result withBlurRadius:3];
    return result;
}


- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
    
}
@end
