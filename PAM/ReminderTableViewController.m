//
//  ReminderTableViewController.m
//  PAM
//
//  Created by Charlie Forkish on 4/16/16.
//  Copyright © 2016 Charlie Forkish. All rights reserved.
//

#import "ReminderTableViewController.h"
#import "ReminderViewController.h"
#import "ReminderManager.h"
#import "Reminder.h"

static NSString * const kHasRequestedPermissionKey = @"HAS_REQUESTED_PERMISSION";

@interface ReminderTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *reminders;

@end

@implementation ReminderTableViewController

- (instancetype)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Reminders";
    self.reminders = [ReminderManager sharedReminderManager].reminders;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [self requestNotificationPermissions];
    }
}

- (void)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestNotificationPermissions
{
    UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
    NSLog(@"settings: %@", settings);
    if ((settings.types & UIUserNotificationTypeAlert)) return;
    
    NSString *title;
    NSString *message;
    BOOL hasRequested = [[NSUserDefaults standardUserDefaults] boolForKey:kHasRequestedPermissionKey];
    
    if (!hasRequested) {
        title = @"Reminder Permissions";
        message = @"To deliver reminders, PAM needs permission to display notifications. Please allow notifications for PAM.";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRequestedPermissionKey];
    }
    else {
        title = @"Insufficient Permissions";
        message = @"To deliver reminders, PAM needs permission to display notifications. Please enable notifications for PAM in your device settings.";
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert view did dismiss");
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reminders.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Add reminder";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        Reminder *reminder = self.reminders[indexPath.row - 1];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.75;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.minimumScaleFactor = 0.75;
        
        cell.textLabel.text = [reminder labelText];
        cell.detailTextLabel.text = [reminder detailLabelText];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = reminder.enabled;
        [sw addTarget:reminder action:@selector(toggleEnabled) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Reminder *reminder = nil;
    if (indexPath.row > 0) {
        reminder = self.reminders[indexPath.row - 1];
    }
    else {
        reminder = [[Reminder alloc] init];
    }
    ReminderViewController *vc = [[ReminderViewController alloc] initWithReminder:reminder];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
