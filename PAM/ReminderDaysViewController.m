//
//  ReminderReminderDaysViewController.m
//  Reminderage_ios
//
//  Created by Charles Forkish on 5/1/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "ReminderDaysViewController.h"
#import "Reminder.h"

@interface ReminderDaysViewController ()

@property (nonatomic, strong) Reminder *reminder;

@end

@implementation ReminderDaysViewController

- (instancetype)initWithReminder:(Reminder *)reminder
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.reminder = reminder;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Repeats";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (ReminderRepeatDay)repeatDayForRow:(NSInteger)row
{
    switch (row) {
        case 0:
            return ReminderRepeatDaySunday;
        case 1:
            return ReminderRepeatDayMonday;
        case 2:
            return ReminderRepeatDayTuesday;
        case 3:
            return ReminderRepeatDayWednesday;
        case 4:
            return ReminderRepeatDayThursday;
        case 5:
            return ReminderRepeatDayFriday;
        case 6:
            return ReminderRepeatDaySaturday;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    ReminderRepeatDay day = [self repeatDayForRow:indexPath.row];
    cell.textLabel.text = [Reminder fullNameForRepeatDay:day];
    cell.accessoryType = ([self.reminder repeatDayIsOn:day] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderRepeatDay day = [self repeatDayForRow:indexPath.row];
    [self.reminder toggleRepeatForDay:day];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
