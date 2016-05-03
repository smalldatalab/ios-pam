//
//  Reminder.m
//  PAM
//
//  Created by Charlie Forkish on 4/16/16.
//  Copyright © 2016 Charlie Forkish. All rights reserved.
//

#import "Reminder.h"
#import "ReminderManager.h"
#import "NSDate+Additions.h"

@interface Reminder ()

@property (nonatomic, assign) NSInteger timeInMinutes;

@end

@implementation Reminder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.localTime = [NSDate date];
        self.weekdaysMask = ReminderRepeatDayEveryday;
        self.enabled = YES;
        self.isNew = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.timeInMinutes = [aDecoder decodeIntegerForKey:@"timeInMinutes"];
        self.enabled = [aDecoder decodeBoolForKey:@"enabled"];
        self.weekdaysMask = [aDecoder decodeIntForKey:@"weekdaysMask"];
        self.isNew = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"encoding reminder");
    [aCoder encodeInteger:self.timeInMinutes forKey:@"timeInMinutes"];
    [aCoder encodeBool:self.enabled forKey:@"enabled"];
    [aCoder encodeInt:self.weekdaysMask forKey:@"weekdaysMask"];
}

- (id)copyWithZone:(NSZone *)zone {
    Reminder *copy = [[Reminder alloc] init];
    copy.timeInMinutes = self.timeInMinutes;
    copy.weekdaysMask = self.weekdaysMask;
    copy.enabled = self.enabled;
    return copy;
}

- (void)toggleEnabled {
    self.enabled = !self.enabled;
    [[ReminderManager sharedReminderManager] saveReminder:self];
}

- (NSDate *)localTime
{
    return [[NSDate timeOfDayWithHours:0 minutes:0] dateByAddingTimeInterval:self.timeInMinutes * 60];
}

- (void)setLocalTime:(NSDate *)localTime
{
    NSDate *startOfDay = [NSDate timeOfDayWithHours:0 minutes:0];
    self.timeInMinutes = [localTime timeIntervalSinceDate:startOfDay] / 60.0;
}

- (NSDate *)nextFireDate {
    if (!self.enabled || (self.weekdaysMask == ReminderRepeatDayNever)) return nil;
    if ([self.localTime isBeforeDate:[NSDate date]]) {
        return [self.localTime dateByAddingDays:1];
    }
    return self.localTime;
}

- (NSDate *)fireDateForDate:(NSDate *)date {
    NSInteger weekday = [date weekdayComponent];
    ReminderRepeatDay repeatDay = [Reminder repeatDayForCalendarUnit:weekday];
    if (![self repeatDayIsOn:repeatDay]) return nil;
    
    NSDate *fireDate = [date dateWithTimeFromDate:self.localTime];
    if ([fireDate isBeforeDate:[NSDate date]]) {
        return [fireDate dateByAddingDays:7];
    }
    return fireDate;
}

- (NSString *)labelText
{
    return [Reminder formattedTime:self.localTime];
}

- (NSString *)detailLabelText
{
    if (self.weekdaysMask == ReminderRepeatDayNever) {
        return @"No repeat";
    }
    else {
        return [self repeatLabelText];
    }
}

- (NSString *)repeatLabelText
{
    if (self.weekdaysMask == ReminderRepeatDayEveryday || self.weekdaysMask == ReminderRepeatDayNever) {
        return [Reminder fullNameForRepeatDay:self.weekdaysMask];
    }
    
    NSArray *repeatDays = [self repeatDays];
    
//    if (repeatDays.count == 1) {
//        ReminderRepeatDay day = [(NSNumber *)repeatDays.firstObject unsignedIntegerValue];
//        return [Reminder fullNameForRepeatDay:day];
//    }
    
    NSMutableString * text = [NSMutableString string];
    NSString *comma = @"";
    
    for (NSNumber *day in repeatDays) {
        if (repeatDays.count < 3) {
            [text appendFormat:@"%@%@", comma, [Reminder fullNameForRepeatDay:day.unsignedIntegerValue]];
        }
        else {
            [text appendFormat:@"%@%@", comma, [Reminder mediumNameForRepeatDay:day.unsignedIntegerValue]];
        }
        comma = @", ";
    }
    
    return text;
}

- (NSArray *)repeatDays
{
    NSMutableArray *days = [NSMutableArray array];
    for (int16_t day = 1; day < ReminderRepeatDayEveryday; day <<= 1) {
        if ([self repeatDayIsOn:day]) {
            [days addObject:@(day)];
        }
    }
    return days;
}

- (void)toggleRepeatForDay:(ReminderRepeatDay)repeatDay
{
    self.weekdaysMask ^= repeatDay;
}

- (BOOL)repeatDayIsOn:(ReminderRepeatDay)repeatDay
{
    if (self.weekdaysMask == ReminderRepeatDayEveryday)
        return YES;
    else
        return (self.weekdaysMask & repeatDay);
}

#pragma mark - Class Methods

+ (NSString *)fullNameForRepeatDay:(ReminderRepeatDay)repeatDay
{
    switch (repeatDay) {
        case ReminderRepeatDaySunday:
            return @"Sunday";
        case ReminderRepeatDayMonday:
            return @"Monday";
        case ReminderRepeatDayTuesday:
            return @"Tuesday";
        case ReminderRepeatDayWednesday:
            return @"Wednesday";
        case ReminderRepeatDayThursday:
            return @"Thursday";
        case ReminderRepeatDayFriday:
            return @"Friday";
        case ReminderRepeatDaySaturday:
            return @"Saturday";
        case ReminderRepeatDayNever:
            return @"Never";
        case ReminderRepeatDayEveryday:
            return @"Everyday";
            
        default:
            return nil;
    }
}

+ (NSString *)mediumNameForRepeatDay:(ReminderRepeatDay)repeatDay
{
    switch (repeatDay) {
        case ReminderRepeatDaySunday:
            return @"Sun";
        case ReminderRepeatDayMonday:
            return @"Mon";
        case ReminderRepeatDayTuesday:
            return @"Tue";
        case ReminderRepeatDayWednesday:
            return @"Wed";
        case ReminderRepeatDayThursday:
            return @"Thu";
        case ReminderRepeatDayFriday:
            return @"Fri";
        case ReminderRepeatDaySaturday:
            return @"Sat";
            
        default:
            return nil;
    }
}

+ (NSString *)shortNameForRepeatDay:(ReminderRepeatDay)repeatDay
{
    switch (repeatDay) {
        case ReminderRepeatDaySunday:
            return @"Su";
        case ReminderRepeatDayMonday:
            return @"M";
        case ReminderRepeatDayTuesday:
            return @"T";
        case ReminderRepeatDayWednesday:
            return @"W";
        case ReminderRepeatDayThursday:
            return @"Th";
        case ReminderRepeatDayFriday:
            return @"F";
        case ReminderRepeatDaySaturday:
            return @"Sa";
            
        default:
            return nil;
    }
}

+ (NSInteger)calendarUnitForRepeatDay:(ReminderRepeatDay)repeatDay
{
    switch (repeatDay) {
        case ReminderRepeatDaySunday:
            return 1;
        case ReminderRepeatDayMonday:
            return 2;
        case ReminderRepeatDayTuesday:
            return 3;
        case ReminderRepeatDayWednesday:
            return 4;
        case ReminderRepeatDayThursday:
            return 5;
        case ReminderRepeatDayFriday:
            return 6;
        case ReminderRepeatDaySaturday:
            return 7;
            
        default:
            return 0;
    }
}

+ (ReminderRepeatDay)repeatDayForCalendarUnit:(NSInteger)calendarUnit
{
    switch (calendarUnit) {
        case 1:
            return ReminderRepeatDaySunday;
        case 2:
            return ReminderRepeatDayMonday;
        case 3:
            return ReminderRepeatDayTuesday;
        case 4:
            return ReminderRepeatDayWednesday;
        case 5:
            return ReminderRepeatDayThursday;
        case 6:
            return ReminderRepeatDayFriday;
        case 7:
            return ReminderRepeatDaySaturday;
            
        default:
            return 0;
    }
}

+ (NSString *)formattedTime:(NSDate *)time
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    return [dateFormatter stringFromDate:time];
}

@end
