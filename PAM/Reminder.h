//
//  Reminder.h
//  PAM
//
//  Created by Charlie Forkish on 4/16/16.
//  Copyright © 2016 Charlie Forkish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ReminderRepeatDay) {
    ReminderRepeatDaySunday = 1,
    ReminderRepeatDayMonday = 1 << 1,
    ReminderRepeatDayTuesday = 1 << 2,
    ReminderRepeatDayWednesday = 1 << 3,
    ReminderRepeatDayThursday = 1 << 4,
    ReminderRepeatDayFriday = 1 << 5,
    ReminderRepeatDaySaturday = 1 << 6,
    
    ReminderRepeatDayNever = 0,
    ReminderRepeatDayEveryday = 0x7F
};

@interface Reminder : NSObject<NSCoding>

+ (NSString *)fullNameForRepeatDay:(ReminderRepeatDay)repeatDay;
+ (NSString *)shortNameForRepeatDay:(ReminderRepeatDay)repeatDay;
+ (NSInteger)calendarUnitForRepeatDay:(ReminderRepeatDay)repeatDay;

@property (nonatomic, strong) NSDate * localTime;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) int16_t weekdaysMask;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, readonly) NSDate *nextFireDate;

- (NSString *)labelText;
- (NSString *)detailLabelText;
- (NSString *)repeatLabelText;
- (NSDate *)fireDateForDate:(NSDate *)date;
- (void)toggleRepeatForDay:(ReminderRepeatDay)repeatDay;
- (BOOL)repeatDayIsOn:(ReminderRepeatDay)repeatDay;

- (void)toggleEnabled;

@end
