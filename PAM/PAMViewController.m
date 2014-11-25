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

#define NUM_ROWS 4
#define NUM_COLS 4

CGFloat const kGridMargin = 5.0;

@interface PAMViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) UIImageView *checkMarkView;
@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) NSMutableArray *pamMeasures;

@property (nonatomic, strong) UIBarButtonItem *logoutButton;
@property (nonatomic, strong) UIBarButtonItem *submitButton;
@property (nonatomic, strong) NSArray *imageCells;
@property (nonatomic, strong) PAMImageCell *selectedCell;

@end

@implementation PAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern"]];
    [self.view setBackgroundColor:bgColor];
    
    self.title = @"PAM";
    
    [self createPAMGrid];
    
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
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload Images"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(reloadImages)];
    
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(submit)];
    submitButton.enabled = NO;
    self.submitButton = submitButton;
    
    self.toolbarItems = @[submitButton, spacer1, reloadButton];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // without this the navigation bar waits until the view has appeared
    // to adjust for the status bar
    [self.navigationController.navigationBar.layer removeAllAnimations];
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
    for (PAMImageCell *cell in self.imageCells) {
        cell.selected = NO;
    }
    cell.selected = YES;
    self.selectedCell = cell;
    self.submitButton.enabled = YES;
}

// If an image is selected, hilight it and set the self.selectedButton to that button. Also, unhilight all other buttons
-(void)imageSelected:(id)sender
{
    self.selectedButton.layer.borderWidth = 0.0;
    
    UIButton *button = (UIButton *)sender;
    self.selectedButton = button;
    
    CALayer *layer = [sender layer];
    layer.borderWidth = 37;
    layer.borderColor = [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:.4] CGColor];
    
    [self.checkMarkView removeFromSuperview];
    self.checkMarkView = [[UIImageView alloc] init];
    self.checkMarkView.image = [UIImage imageNamed:@"check.png"];
    self.checkMarkView.frame = CGRectMake(button.frame.origin.x + 48, button.frame.origin.y + 48, 23, 23);
    
    [self.submitDictionary setObject:self.selectedButton.titleLabel.text forKey:@"4"];
    
    [self.view addSubview:self.checkMarkView];
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
    [self presentViewController:[[LoginViewController alloc] init] animated:YES completion:nil];
}

// Checks the make sure that a PAM image was selected, if it is, send its ID to the server.
-(void)submit
{
    [self imageCellPressed:nil];
    self.submitButton.enabled = NO;
    [self reloadImages];
//    if(self.selectedButton == nil) {
//        [SVProgressHUD showErrorWithStatus:@"Select an Image"];
//        return;
//    } else {
//        [self uploadData];
//    }
}

// Converts the PAM image name to its ID and sends its ID to the server (along with user ID).
// Disables input so that multiple PAM images are not selected and sent at once.
-(void)uploadData
{
//    self.reloadButton.enabled = NO;
//    self.submitButton.enabled = NO;
//    [SVProgressHUD showWithStatus:@"Submitting"];
//    
//    NSString *imageName = self.selectedButton.titleLabel.text;
//    int location = [imageName rangeOfString:@"_"].location;
//    int cellNumber = [[imageName substringWithRange:NSMakeRange(0,location)] intValue];
//    int imageNumber = (cellNumber - 1) * 3 + [[imageName substringWithRange:NSMakeRange(location + 1,location)] intValue];
//    
//    NSURL *url = [NSURL URLWithString:@"http://api.cornellhci.org/idl-ema/measures/update"];
//    NSString *input = [NSString stringWithFormat:@"user_id=%@&pam_image_id=%d&visual_pain=%@&general_pain=%@&relation_pain=%@&sleep_pain=%@",
//                       [[NSUserDefaults standardUserDefaults] objectForKey:@"id"],
//                       imageNumber,
//                       [self.submitDictionary objectForKey:@"0"],
//                       [self.submitDictionary objectForKey:@"1"],
//                       [self.submitDictionary objectForKey:@"2"],
//                       [self.submitDictionary objectForKey:@"3"]];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[input dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    
//    [self toEnableInteraction:NO];
}

// Return the measures for mood name, valence, arousal, valence_pa, and valence_na
// The dictionary has the key set as the names of the values
-(NSDictionary *)getCellData
{
    NSString *imageName = self.selectedButton.titleLabel.text;
    int location = [imageName rangeOfString:@"_"].location;
    int cellNumber = [[imageName substringWithRange:NSMakeRange(0,location)] intValue];
    return [self.pamMeasures objectAtIndex:cellNumber];
}

//// Makes sure that the information is recieved and enable input.
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    self.selectedButton.layer.borderWidth = 0.0;
//    self.selectedButton = nil;
//    [self.checkMarkView removeFromSuperview];
//    [SVProgressHUD showSuccessWithStatus:@"Done!"];
//    [self toEnableInteraction:YES];
//    [self.submitDictionary removeAllObjects];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}
//
//// If there was an error, display a message and enable input again.
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//{
//    [SVProgressHUD showErrorWithStatus:@"Error. :["];
//    [self toEnableInteraction:YES];
//}

-(void)toEnableInteraction:(BOOL)toEnable
{
    self.view.userInteractionEnabled = toEnable;
    self.navigationController.navigationBar.userInteractionEnabled = toEnable;
}

// Creates the pamMeasures array (the dictionary containing the information will be at the index
// equal to the cell ID).
-(void)createPamMeasures
{
    self.pamMeasures = [[NSMutableArray alloc] init];
    NSMutableArray *measureArray = [[NSMutableArray alloc] initWithObjects:
                                    @"0",@"0",@"0",@"0",@"0",@"0",
                                    @"1",@"afraid",@"-2",@"4",@"1",@"4",
                                    @"2",@"tense",@"-1",@"4",@"2",@"3",
                                    @"3",@"excited",@"1",@"4",@"3",@"2",
                                    @"4",@"delighted",@"2",@"4",@"4",@"1",
                                    @"5",@"frustrated",@"-2",@"3",@"1",@"4",
                                    @"6",@"angry",@"-1",@"3",@"2",@"3",
                                    @"7",@"happy",@"1",@"3",@"3",@"2",
                                    @"8",@"glad",@"2",@"3",@"4",@"1",
                                    @"9",@"miserable",@"-2",@"2",@"1",@"4",
                                    @"10",@"sad",@"-1",@"2",@"2",@"3",
                                    @"11",@"calm",@"1",@"2",@"3",@"2",
                                    @"12",@"satisfied",@"2",@"2",@"4",@"1",
                                    @"13",@"gloomy",@"-2",@"1",@"1",@"4",
                                    @"14",@"tired",@"-1",@"1",@"2",@"3",
                                    @"15",@"sleepy",@"1",@"1",@"3",@"2",
                                    @"16",@"serene",@"2",@"1",@"4",@"1",
                                    nil];
    
    NSArray *keyArray = [[NSArray alloc] initWithObjects:
                         @"id",@"name",@"valence",@"arousal",@"valence_pa",@"valence_na",nil];
    for(int i = 0; i<[measureArray count] / 6; i++) {
        NSRange range = NSMakeRange(i * 6, 6);
        NSDictionary *pamCellMeasure = [[NSDictionary alloc] initWithObjects:[measureArray subarrayWithRange:range] forKeys:keyArray];
        [self.pamMeasures addObject:pamCellMeasure];
    }
}
@end
