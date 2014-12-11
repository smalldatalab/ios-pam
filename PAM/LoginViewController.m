//
//  LoginViewController.m
//  PAM
//
//  Created by Charles Forkish on 11/23/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "LoginViewController.h"
#import "UIView+AutoLayoutHelpers.h"
#import "AppDelegate.h"

#import <OMHClient/OMHClient.h>

@interface LoginViewController () <OMHSignInDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    UILabel *header = [[UILabel alloc] init];
    header.text = @"PAM";
    header.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:65.0];
    header.textAlignment = NSTextAlignmentCenter;
    
    UIButton *googleButton = [OMHClient googleSignInButton];
    
    [self.view addSubview:header];
    [self.view addSubview:googleButton];
    
    [self.view constrainChildToDefaultHorizontalInsets:header];
    [self.view constrainChildToDefaultHorizontalInsets:googleButton];
    
    [header constrainToTopInParentWithMargin:80];
    [googleButton constrainToBottomInParentWithMargin:80];
    
    [OMHClient sharedClient].signInDelegate = self;
}

- (void)OMHClientSignInFinishedWithError:(NSError *)error
{
    if (error != nil) {
        NSLog(@"OMHClientLoginFinishedWithError: %@", error);
        return;
    }
    
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [(AppDelegate *)[UIApplication sharedApplication].delegate userDidLogin];
    }
}




@end
