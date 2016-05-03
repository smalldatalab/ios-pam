//
//  ReminderManager.h
//  PAM
//
//  Created by Charlie Forkish on 4/16/16.
//  Copyright © 2016 Charlie Forkish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reminder;

@interface ReminderManager : NSObject

+ (instancetype)sharedReminderManager;

@property (nonatomic, readonly) NSArray *reminders;

- (void)saveReminder:(Reminder *)reminder;
- (void)deleteReminder:(Reminder *)reminder;

- (void)synchronizeNotifications;

@end
