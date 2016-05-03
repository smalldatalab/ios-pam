//
//  ReminderDaysViewController.h
//  ohmage_ios
//
//  Created by Charles Forkish on 5/1/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reminder;

@interface ReminderDaysViewController : UITableViewController

- (instancetype)initWithReminder:(Reminder *)reminder;

@end
