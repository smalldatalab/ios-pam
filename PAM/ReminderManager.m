//
//  ReminderManager.m
//  PAM
//
//  Created by Charlie Forkish on 4/16/16.
//  Copyright © 2016 Charlie Forkish. All rights reserved.
//

#import "ReminderManager.h"
#import "Reminder.h"
#import "NSDate+Additions.h"

@interface ReminderManager () <NSCoding>

@property (nonatomic, strong) NSMutableArray *privateReminders;

@end

@implementation ReminderManager

+ (instancetype)sharedReminderManager
{
    static ReminderManager *_sharedReminderManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *encodedManager = [[NSUserDefaults standardUserDefaults] objectForKey:@"RemindersArchive"];
        if (encodedManager != nil) {
            _sharedReminderManager = (ReminderManager *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedManager];
            NSLog(@"unarchived reminder manager with count: %lu", (unsigned long)_sharedReminderManager.reminders.count);
        }
        else {
            _sharedReminderManager = [[self alloc] initPrivate];
        }
    });
    
    return _sharedReminderManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[ReminderManager sharedReminderManager]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        [self commonInit];
//        [self debugPrintAllNotifications];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        _privateReminders = [decoder decodeObjectForKey:@"reminders"];
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    if (!_privateReminders) {
        _privateReminders = [NSMutableArray array];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"encoding reminder manager");
    [aCoder encodeObject:self.privateReminders forKey:@"reminders"];
}

- (void)save {
    NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:encoded forKey:@"RemindersArchive"];
}

- (void)saveReminder:(Reminder *)reminder {
    NSLog(@"save reminder");
    if (![self.privateReminders containsObject:reminder]) {
        [self.privateReminders addObject:reminder];
    }
    [self updateReminderNotifications];
    [self save];
}

- (void)deleteReminder:(Reminder *)reminder {
    [self.privateReminders removeObject:reminder];
    [self updateReminderNotifications];
    [self save];
}

- (NSArray *)reminders {
    return _privateReminders;
}

- (void)updateReminderNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
    for (Reminder *reminder in self.privateReminders) {
        if (reminder.enabled && (reminder.weekdaysMask != ReminderRepeatDayNever)) {
            [self scheduleNotificationsForReminder:reminder];
        }
    }
    [self debugPrintAllNotifications];
}

- (void)scheduleNotificationsForReminder:(Reminder *)reminder {
    if (reminder.weekdaysMask == ReminderRepeatDayEveryday) {
        [self scheduleNotificationForDate:reminder.nextFireDate repeatInterval:NSCalendarUnitDay];
    }
    else {
        NSDate *today = [NSDate date];
        for (int i = 0; i < 7; i++) {
            NSDate *fireDate = [reminder fireDateForDate:[today dateByAddingDays:i]];
            if (fireDate != nil) {
                [self scheduleNotificationForDate:fireDate repeatInterval:NSCalendarUnitWeekOfYear];
            }
        }
    }
}

- (void)scheduleNotificationForDate:(NSDate *)date repeatInterval:(NSCalendarUnit)repeatInterval {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = date;
    notification.repeatInterval = repeatInterval;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = @"Reminder to log how you're feeling";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)synchronizeNotifications {
    [self updateReminderNotifications];
}

- (void)debugPrintAllNotifications
{
    NSArray *notes = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *note in notes) {
        NSLog(@"notification: %@", note);
    }
}

@end
