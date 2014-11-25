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
    [dp addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.timePicker = dp;
    self.tableView.tableHeaderView = dp;
    
    [self debugPrintAllNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self requestNotificationPermissions];
}

- (void)requestNotificationPermissions
{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    settings = [UIApplication sharedApplication].currentUserNotificationSettings;
    NSLog(@"settings: %@", settings);
    if (!(settings.types & UIUserNotificationTypeAlert)) {
        NSString *title = @"Insufficient Permissions";
        NSString *message = @"To deliver reminders, PAM needs permission to display notifications. Please enable notifications for PAM in your device settings.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)hasReminder
{
    return ([UIApplication sharedApplication].scheduledLocalNotifications.count > 0);
}

- (void)updateReminder
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (self.enabledSwitch.on) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSString *alertBody = @"Daily reminder to log how you feel.";
        
        notification.alertBody = alertBody;
        notification.fireDate = self.timePicker.date;
        notification.repeatInterval = NSCalendarUnitDay;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    [self debugPrintAllNotifications];
}

- (void)debugPrintAllNotifications
{
    NSArray *notes = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSLog( @"enabled: %d, notifications: %d", self.enabledSwitch.on, notes.count);
    for (UILocalNotification *note in notes) {
        NSLog(@"notification: %@", note);
    }
}

- (void)doneButtonPressed:(id)sender
{
    [self updateReminder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)timePickerValueChanged:(id)sender
{
    self.enabledSwitch.on = YES;
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
    sw.on = [self hasReminder];
    cell.accessoryView = sw;
    self.enabledSwitch = sw;
    
    return cell;
}


@end
