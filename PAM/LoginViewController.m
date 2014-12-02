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

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

NSString * const kPAMGoogleClientID = @"48636836762-ktb5qaq5seoqn4b73nfua0csual4b8ng.apps.googleusercontent.com";
NSString * const kPAMGoogleClientSecret = @"7bXtt441dFfwr5g2DopPaHy3";
NSString * const kOMHServerGoogleClientID = @"48636836762-9p082qvhat6ojtgnhn4najkmkuolaieu.apps.googleusercontent.com";

@interface LoginViewController () <GPPSignInDelegate>

@property (nonatomic, strong) UITextField *userTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *signInButton;

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
    
    GPPSignInButton *googleButton = [[GPPSignInButton alloc] init];
//    [googleButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    googleButton.style = kGPPSignInButtonStyleWide;
    
    [self.view addSubview:header];
    [self.view addSubview:googleButton];
    
    [self.view constrainChildToDefaultHorizontalInsets:header];
    [self.view constrainChildToDefaultHorizontalInsets:googleButton];
    
    [header constrainToTopInParentWithMargin:80];
    [googleButton constrainToBottomInParentWithMargin:80];
    
    [self configureGoogleSignIn];
}

- (void)login
{
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [(AppDelegate *)[UIApplication sharedApplication].delegate userDidLogin];
    }
}



#pragma mark - Google Login

- (void)configureGoogleSignIn
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kPAMGoogleClientID;
    signIn.homeServerClientID = kOMHServerGoogleClientID;

    signIn.scopes = @[ @"profile" ];            // "profile" scope
    signIn.delegate = self;

}

- (NSString *)base64EncodedString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Client received google error %@ and auth object %@",error, auth);
    if (error) {

    }
    else {
        NSString *serverCode = [GPPSignIn sharedInstance].homeServerAuthorizationCode;
        NSLog(@"serverCode: %@", serverCode);
        NSLog(@"test encode: %@", [self base64EncodedString:[NSString stringWithFormat:@"%@:%@", @"android-app", @"secret"]]);
        
        NSString *encodedClientIDAndSecret = [self base64EncodedString:[NSString stringWithFormat:@"%@:%@", kPAMGoogleClientID, kPAMGoogleClientSecret]];
        
        [self login];
    }
}

@end
