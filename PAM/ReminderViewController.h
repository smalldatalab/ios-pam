//
//  ReminderViewController.h
//  PAM
//
//  Created by Charles Forkish on 11/25/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reminder;

@interface ReminderViewController : UITableViewController

- (instancetype)initWithReminder:(Reminder *)reminder;

@end
