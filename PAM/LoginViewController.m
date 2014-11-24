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

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *signInButton;

@end

@implementation LoginViewController

//- (void)loadView
//{
//    CGRect screenBounds = [UIScreen mainScreen].bounds;
//    UIView *view = [[UIView alloc] initWithFrame:screenBounds];
//    view.backgroundColor = [OHMAppConstants ohmageColor];
//    self.view = view;
//    
//    UIView *contentBox = [[UIView alloc] init];
//    contentBox.backgroundColor = [UIColor whiteColor];
//    [view addSubview:contentBox];
//    [view constrainChild:contentBox toHorizontalInsets:UIEdgeInsetsMake(0, kUIViewSmallMargin, 0, kUIViewSmallMargin)];
//    self.contentBox = contentBox;
//    
//    UILabel *header = [[UILabel alloc] init];
//    header.text = @"PAM";
//    header.textColor = [OHMAppConstants ohmageColor];
//    header.font = [OHMAppConstants headerTitleFont];
//    header.textAlignment = NSTextAlignmentCenter;
//    [contentBox addSubview:header];
//    [header constrainToTopInParentWithMargin:kUIViewVerticalMargin];
//    [contentBox constrainChild:header toHorizontalInsets:kUIViewDefaultInsets];
//    
//    UIView *emailField = [OHMUserInterface textFieldWithLabelText:@"E-MAIL" setupBlock:^(UITextField *tf) {
//        tf.placeholder = @"enter your e-mail";
//        tf.delegate = self;
//        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        self.emailTextField = tf;
//    }];
//    
//    UIView *passwordField = [OHMUserInterface textFieldWithLabelText:@"PASSWORD" setupBlock:^(UITextField *tf) {
//        tf.placeholder = @"enter your password";
//        tf.secureTextEntry = YES;
//        tf.delegate = self;
//        self.passwordTextField = tf;
//    }];
//    
//    [contentBox addSubview:emailField];
//    [contentBox addSubview:passwordField];
//    
//    [emailField positionBelowElement:header margin:kUIViewVerticalMargin];
//    [passwordField positionBelowElement:emailField margin:kUIViewVerticalMargin];
//    
//    [contentBox constrainChild:emailField toHorizontalInsets:kUIViewDefaultInsets];
//    [contentBox constrainChild:passwordField toHorizontalInsets:kUIViewDefaultInsets];
//    
//    CGFloat buttonWidth = screenBounds.size.width - 2 * kUIViewSmallMargin - 2 * kUIViewHorizontalMargin;
//    CGSize buttonSize = CGSizeMake(buttonWidth, kUIButtonDefaultHeight);
//    UIButton *signInButton = [OHMUserInterface buttonWithTitle:@"Sign In"
//                                                         color:[OHMAppConstants ohmageColor]
//                                                        target:self
//                                                        action:@selector(signInButtonPressed:)
//                                                          size:buttonSize];
//    signInButton.enabled = (self.emailTextField.text.length > 0 && self.passwordTextField.text.length > 0);
//    self.signInButton = signInButton;
//    
//    [contentBox addSubview:signInButton];
//    [signInButton positionBelowElement:passwordField margin:kUIViewVerticalMargin];
//    [signInButton centerHorizontallyInView:contentBox];
//    [signInButton constrainToBottomInParentWithMargin:kUIViewVerticalMargin];
//    
//    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [view addSubview:activityIndicator];
//    [activityIndicator centerHorizontallyInView:view];
//    [activityIndicator positionBelowElement:contentBox margin:2 * kUIViewVerticalMargin];
//    activityIndicator.alpha = 0;
//    self.activityIndicator = activityIndicator;
//    
//    
//    UIButton *cancelButton = [OHMUserInterface buttonWithTitle:@"Cancel"
//                                                         color:[UIColor clearColor]
//                                                        target:self
//                                                        action:@selector(cancelModalPresentationButtonPressed:)
//                                                          size:buttonSize];
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [view addSubview:cancelButton];
//    [cancelButton constrainToBottomInParentWithMargin:kUIViewVerticalMargin];
//    [cancelButton centerHorizontallyInView:view];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    UILabel *header = [[UILabel alloc] init];
    header.text = @"PAM";
    header.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:45.0];
    header.textAlignment = NSTextAlignmentCenter;
    
    UIView *frame = [[UIView alloc] init];
    frame.backgroundColor = [UIColor whiteColor];
    frame.layer.cornerRadius = 8.0;
    
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    
    UITextField *userField = [[UITextField alloc] init];
    userField.backgroundColor = [UIColor whiteColor];
    userField.placeholder = @"Username";
    userField.delegate = self;
    userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.userTextField = userField;
    
    UITextField *passField = [[UITextField alloc] init];
    passField.backgroundColor = [UIColor whiteColor];
    passField.placeholder = @"Password";
    passField.secureTextEntry = YES;
    passField.delegate = self;
    self.passwordTextField = passField;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor colorWithRed:0.0 green:110.0/255.0 blue:194.0/255.0 alpha:1.0];
    button.layer.cornerRadius = 8.0;
    [button setTitle:@"Log In" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:header];
    [self.view addSubview:frame];
    [frame addSubview:userField];
    [frame addSubview:separator];
    [frame addSubview:passField];
    [self.view addSubview:button];
    
    [frame constrainHeight:61];
    [userField constrainHeight:30];
    [passField constrainHeight:30];
    [button constrainSize:CGSizeMake(120, 30)];
    
    [self.view constrainChildToDefaultHorizontalInsets:header];
    [self.view constrainChildToDefaultHorizontalInsets:frame];
    [frame constrainChildToDefaultHorizontalInsets:userField];
    [frame constrainChild:separator toHorizontalInsets:UIEdgeInsetsZero];
    [frame constrainChildToDefaultHorizontalInsets:passField];
    [button centerHorizontallyInView:self.view];
    
    [header constrainToTopInParentWithMargin:50];
    [frame positionBelowElement:header margin:30];
    [userField constrainToTopInParentWithMargin:0];
    [passField constrainToBottomInParentWithMargin:0];
    [separator positionBelowElement:userField margin:0];
    [separator positionAboveElement:passField margin:0];
    [button positionBelowElement:frame margin:30];
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

@end
