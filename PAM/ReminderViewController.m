//
//  ReminderViewController.m
//  PAM
//
//  Created by Charles Forkish on 11/25/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "ReminderViewController.h"
#import "UIView+AutoLayoutHelpers.h"

@interface ReminderViewController ()

@property (nonatomic, strong) UISwitch *enabledSwitch;
@property (nonatomic, strong) UIDatePicker *timePicker;

@end

@implementation ReminderViewController

- (instancetype)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    self.title = @"Daily Reminder";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIDatePicker *dp = [[UIDatePicker alloc] init];
    dp.backgroundColor = [UIColor whiteColor];
    dp.datePickerMode = UIDatePickerModeTime;
    self.timePicker = dp;
    self.tableView.tableHeaderView = dp;
}

- (void)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Enabled";
    
    UISwitch *sw = [[UISwitch alloc] init];
    cell.accessoryView = sw;
    self.enabledSwitch = sw;
    
    return cell;
}


@end
