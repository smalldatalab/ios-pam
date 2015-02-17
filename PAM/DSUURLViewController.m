//
//  DSUURLViewController.m
//  PAM
//
//  Created by Charles Forkish on 2/15/15.
//  Copyright (c) 2015 Charlie Forkish. All rights reserved.
//

#import "DSUURLViewController.h"
#import "OMHClient.h"
#import "UIView+AutoLayoutHelpers.h"

@interface DSUURLViewController () <UITextFieldDelegate>

@property (nonatomic, retain) UITextField *textField;

@end

@implementation DSUURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Set DSU URL";
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    UITextField *tf = [[UITextField alloc] init];
    tf.delegate = self;
    tf.text = [OMHClient DSUBaseURL];
    tf.backgroundColor = [UIColor whiteColor];
    tf.borderStyle = UITextBorderStyleBezel;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.minimumFontSize = 6.0;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.view addSubview:tf];
    [self.view constrainChildToDefaultHorizontalInsets:tf];
    [tf centerVerticallyInView:self.view];
    
    self.textField = tf;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
}

- (void)doneButtonPressed:(id)sender
{
    NSLog(@"done button pressed");
    [self.textField resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"tf done editing");
    if (textField.text.length > 0) {
        [OMHClient setDSUBaseURL:textField.text];
    }
    else {
        textField.text = [OMHClient DSUBaseURL];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
