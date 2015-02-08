//
//  PAMImageCell.h
//  PAM
//
//  Created by Charles Forkish on 11/22/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "PAMViewController.h"
#import "PAMImageCell.h"
#import "UIView+AutoLayoutHelpers.h"
#import "LoginViewController.h"
#import "ReminderViewController.h"
#import "OMHClient.h"
#import "AppConstants.h"

#define NUM_ROWS 4
#define NUM_COLS 4
#define NUM_CELLS (NUM_ROWS*NUM_COLS)

CGFloat const kGridMargin = 5.0;
NSString * const kLastSubmitDateKey = @"lastSubmitDate";

@interface PAMViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) UIImageView *checkMarkView;
@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) NSMutableArray *pamMeasures;

@property (nonatomic, strong) UIBarButtonItem *logoutButton;
@property (nonatomic, strong) UIBarButtonItem *reloadButton;
@property (nonatomic, strong) NSArray *imageCells;
@property (nonatomic, strong) PAMImageCell *selectedCell;
@property (nonatomic, strong) UILabel *lastSubmitLabel;

@end

@implementation PAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    self.title = @"PAM";
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout)];
    
    UIBarButtonItem *reminderButton = [[UIBarButtonItem alloc] initWithTitle:@"Reminder"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(presentReminderViewController)];
    self.logoutButton = logoutButton;
    
    self.navigationItem.leftBarButtonItem = logoutButton;
    self.navigationItem.rightBarButtonItem = reminderButton;
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                             action:nil];
    
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload Images"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(reloadImages)];
    self.reloadButton = reloadButton;
    
    self.toolbarItems = @[spacer1, reloadButton, spacer2];
    self.navigationController.toolbarHidden = NO;
    
    [self createPAMGrid];
    [self updateLastSubmitLabel];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // without this, the navigation bar waits until the view has appeared
    // to adjust for the status bar
    [self.navigationController.navigationBar.layer removeAllAnimations];
}

- (void)updateLastSubmitLabel
{
    UILabel *oldLabel = nil;
    if (self.lastSubmitLabel != nil) oldLabel = self.lastSubmitLabel;
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSubmitDateKey];
    if (date == nil) return;
    
    UILabel *newLabel = [[UILabel alloc] init];
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.font = [UIFont systemFontOfSize:12.0];
    newLabel.text = [NSString stringWithFormat:@"Last submission: %@", [self formattedDate:date]];
    newLabel.alpha = 0.0;
    self.lastSubmitLabel = newLabel;
    
    [self.view addSubview:newLabel];
    [self.view constrainChildToDefaultHorizontalInsets:newLabel];
    [newLabel positionBelowElementWithDefaultMargin:self.imageCells.lastObject];
    
    [UIView animateWithDuration:0.5 animations:^{
        newLabel.alpha = 1.0;
        if (oldLabel) oldLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (oldLabel) [oldLabel removeFromSuperview];
    }];
}

- (NSString *)formattedDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d h:m" options:0
                                                                  locale:[NSLocale currentLocale]];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
    }
    
    return [dateFormatter stringFromDate:date];
}

- (void)presentReminderViewController
{
    ReminderViewController *vc = [[ReminderViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

// Creates the PAM grid, randomizing the picture (but not its location)
// The buttons are created and added to self.buttonArray (for easier access to the buttons)
- (void)createPAMGrid
{
    UILabel *instructions = [[UILabel alloc] init];
    instructions.text = @"Select the photo that best captures how you feel right now:";
    instructions.numberOfLines = 0;
    [self.view addSubview:instructions];
    [self.view constrainChildToDefaultHorizontalInsets:instructions];
    [instructions positionBelowElementWithDefaultMargin:self.topLayoutGuide];
    [instructions sizeToFit];
    
    NSMutableArray *cells = [NSMutableArray arrayWithCapacity:NUM_ROWS*NUM_COLS];
    UIView *layoutAnchor = instructions;
    int index = 0;
    
    for (int y = 0; y < NUM_ROWS; y++) {
        
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:NUM_COLS];
        for (int x = 0; x < NUM_COLS; x++) {
            PAMImageCell *cell = [[PAMImageCell alloc] initWithIndex:index++];
            [cell addTarget:self action:@selector(imageCellPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:cell];
            [cell positionBelowElement:layoutAnchor margin:kGridMargin];
            [cell constrainEqualWidthAndHeight];
            
            [row addObject:cell];
            [cells addObject:cell];
        }
        
        [self.view constrainChildrenToEqualWidths:row];
        [self.view layoutChildren:row horizontal:YES margin:kGridMargin guides:nil];
        layoutAnchor = row[0];
    }
    
    self.imageCells = cells;
}

- (void)imageCellPressed:(PAMImageCell *)cell
{
    UIImage *image = [cell backgroundImageForState:UIControlStateNormal];
    [self presentSubmitAnimationWithImage:image frame:cell.frame];
    
    NSDictionary *dataPoint = [self createDataPointForIndex:cell.index];
    [[OMHClient sharedClient] submitDataPoint:dataPoint];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastSubmitDateKey];
    
}

- (void)presentSubmitAnimationWithImage:(UIImage *)image frame:(CGRect)frame
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Submitted";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    [view addSubview:imageView];
    [view addSubview:label];
    
    [view constrainChildToDefaultHorizontalInsets:imageView];
    [view constrainChild:imageView toHorizontalInsets:UIEdgeInsetsMake(0, 40, 0, 40)];
    [imageView constrainEqualWidthAndHeight];
    [imageView centerVerticallyInView:view];
    
    [label positionBelowElementWithDefaultMargin:imageView];
    [label centerHorizontallyInView:view];
    
    [self.view addSubview:view];
    [self.view constrainChild:view toMargins:UIEdgeInsetsZero];
    
    view.alpha = 0.0;
    self.reloadButton.enabled = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self reloadImages];
        [UIView animateWithDuration:0.25 delay:3.0 options:0 animations:^{
            view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            [self updateLastSubmitLabel];
            self.reloadButton.enabled = YES;
        }];
    }];
}

// Load new image in each unselected cell
-(void)reloadImages
{
    for (PAMImageCell *cell in self.imageCells) {
        if (!cell.selected) [cell shuffleImage];
    }
}

- (void)logout
{
    [[OMHClient sharedClient] signOut];
    [self presentViewController:[[LoginViewController alloc] init] animated:YES completion:nil];
}


#pragma mark - PAM Data Point

- (NSDictionary *)createDataPointForIndex:(int)index
{
    OMHDataPoint *dataPoint = [OMHDataPoint templateDataPoint];
    dataPoint.header.schemaID = [AppConstants pamSchemaID];
    dataPoint.header.acquisitionProvenance = [AppConstants pamAcquisitionProvenance];
    dataPoint.body = [self dataPointBodyForIndex:index];
    return dataPoint;
}

- (NSDictionary *)dataPointBodyForIndex:(int)index
{
    int av = [self affectValenceForIndex:index];
    int aa = [self affectArousalForIndex:index];
    int pa = [self positiveAffectForValence:av arousal:aa];
    int na = [self negativeAffectForValence:av arousal:aa];
    NSString *mood = [self moodForIndex:index];
    NSDictionary *timeframe = [self currentTimeFrame];
    
    return @{@"affect_valence" : @(av),
             @"affect_arousal" : @(aa),
             @"positive_affect" : @(pa),
             @"negative_affect" : @(na),
             @"mood" : mood,
             @"effective_time_frame" : timeframe};
}

- (int)affectValenceForIndex:(int)index
{
    return (index % NUM_COLS) + 1;
}

- (int)affectArousalForIndex:(int)index
{
    return NUM_ROWS - index / NUM_ROWS;
}

- (int)positiveAffectForValence:(int)valence arousal:(int)arousal
{
    return 4 * valence + arousal - 4;
}

- (int)negativeAffectForValence:(int)valence arousal:(int)arousal
{
    return 4 * (5 - valence) + arousal - 4;
}

- (NSString *)moodForIndex:(int)index
{
    static NSArray * sMoodArray = nil;
    if (sMoodArray == nil) {
        sMoodArray = @[@"afraid",
                       @"tense",
                       @"excited",
                       @"delighted",
                       @"frustrated",
                       @"angry",
                       @"happy",
                       @"glad",
                       @"miserable",
                       @"sad",
                       @"calm",
                       @"satisfied",
                       @"gloomy",
                       @"tired",
                       @"sleepy",
                       @"serene"];
    }
    return sMoodArray[index];
}

- (NSDictionary *)currentTimeFrame
{
    return @{@"date_time" : [OMHDataPoint stringFromDate:[NSDate date]]};
}


@end
