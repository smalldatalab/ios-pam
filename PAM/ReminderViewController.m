//
//  ReminderViewController.m
//  PAM
//
//  Created by Charles Forkish on 11/25/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "ReminderViewController.h"
#import "UIView+AutoLayoutHelpers.h"
#import "Reminder.h"
#import "ReminderDaysViewController.h"
#import "ReminderManager.h"


@interface ReminderViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) UISwitch *enabledSwitch;
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, strong) Reminder *reminder;
@property (nonatomic, strong) Reminder *tempReminder;

@end

@implementation ReminderViewController

- (instancetype)initWithReminder:(Reminder *)reminder
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.reminder = reminder;
        self.tempReminder = [reminder copy];
//        if (reminder.isNew) {
//            self.reminder = reminder;
//        }
//        else {
//            self.reminder = [reminder copy];
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    if (self.reminder.isNew) {
        self.title = @"New Reminder";
    }
    else {
        self.title = @"Edit Reminder";
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIDatePicker *dp = [[UIDatePicker alloc] init];
    dp.backgroundColor = [UIColor whiteColor];
    dp.datePickerMode = UIDatePickerModeTime;
    dp.date = self.reminder.localTime;
    [dp addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.timePicker = dp;
    self.tableView.tableHeaderView = dp;
    
    if (!self.reminder.isNew) {
        [self setupFooter];
    }
}

- (void)setupFooter {
    CGSize buttonSize = CGSizeMake(self.tableView.frame.size.width - 30, 44);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Delete Reminder" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button constrainSize:buttonSize];
    button.backgroundColor = [self lightColor: [UIColor redColor]];
    
    CGRect buttonFrame = button.frame;
    
    CGRect footerFrame = CGRectMake(0, 0, self.tableView.frame.size.width, buttonFrame.size.height + 30);
    UIView *footerView = [[UIView alloc] initWithFrame:footerFrame];
    
    [footerView addSubview:button];
    [button centerHorizontallyInView:footerView];
    [button centerVerticallyInView:footerView];
    self.tableView.tableFooterView = footerView;
}

- (UIColor *)lightColor:(UIColor *)color
{
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s * 0.5
                          brightness:MIN(b * 1.2, 1.0)
                               alpha:a];
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}



//- (void)updateReminder
//{
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    
//    if (self.enabledSwitch.on) {
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        NSString *alertBody = @"Daily reminder to log how you feel.";
//        
//        notification.alertBody = alertBody;
//        notification.fireDate = self.timePicker.date;
//        notification.repeatInterval = NSCalendarUnitDay;
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
//    
//    [self debugPrintAllNotifications];
//}

- (void)doneButtonPressed:(id)sender
{
//    [self updateReminder];
    self.reminder.enabled = self.enabledSwitch.on;
    self.reminder.weekdaysMask = self.tempReminder.weekdaysMask;
    self.reminder.localTime = self.timePicker.date;
    [[ReminderManager sharedReminderManager] saveReminder:self.reminder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonPressed {
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Delete reminder?"
                                                           message:@"Are you sure you want to delete this reminder?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Delete", nil];
    [confirmAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert view clicked button at index: %ld", buttonIndex);
    if (buttonIndex == 1) {
        [[ReminderManager sharedReminderManager] deleteReminder:self.reminder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)timePickerValueChanged:(id)sender
{
    [self.enabledSwitch setOn:YES animated:YES];
    self.tempReminder.enabled = YES;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Repeats";
        cell.detailTextLabel.text = [self.tempReminder repeatLabelText];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Enabled";
        
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = self.tempReminder.enabled;
        cell.accessoryView = sw;
        self.enabledSwitch = sw;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ReminderDaysViewController *vc = [[ReminderDaysViewController alloc] initWithReminder:self.tempReminder];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
