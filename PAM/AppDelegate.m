//
//  AppDelegate.m
//  PAM
//
//  Created by Charles Forkish on 10/21/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "AppDelegate.h"
#import "PAMViewController.h"
#import "LoginViewController.h"
#import "OMHClient.h"
#import "AppConstants.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [OMHClient setupClientWithAppGoogleClientID:kPAMGoogleClientID
                           serverGoogleClientID:kOMHServerGoogleClientID
                                 appDSUClientID:kPAMDSUClientID
                             appDSUClientSecret:kPAMDSUClientSecret];
    
    UIViewController *root = nil;
    if (![OMHClient sharedClient].isSignedIn) {
        self.loginViewController = [[LoginViewController alloc] init];
        root = self.loginViewController;
    }
    else {
        PAMViewController *pvc = [[PAMViewController alloc] init];
        UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:pvc];
        root = navcon;
    }
    
    self.window.rootViewController = root;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)userDidLogin
{
    PAMViewController *pvc = [[PAMViewController alloc] init];
    UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:pvc];
    [UIView transitionFromView:self.loginViewController.view toView:navcon.view duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.window.rootViewController = navcon;
        self.loginViewController = nil;
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self.window.rootViewController presentViewController:[[LoginViewController alloc] init]
//                                                 animated:NO
//                                               completion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    NSLog(@"openURL: %@, source: %@, annotation: %@", url, sourceApplication, annotation);
    return [[OMHClient sharedClient] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation];
}



@end
