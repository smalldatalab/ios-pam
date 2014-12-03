//
//  OMHClient.h
//  PAM
//
//  Created by Charles Forkish on 12/2/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OMHLoginDelegate;

@interface OMHClient : NSObject

+ (instancetype)sharedClient;

+ (UIButton *)googleSignInButton;

@property (nonatomic, weak) id<OMHLoginDelegate> loginDelegate;

@property (nonatomic, strong) NSString *appGoogleClientID;
@property (nonatomic, strong) NSString *serverGoogleClientID;
@property (nonatomic, strong) NSString *appDSUClientID;
@property (nonatomic, strong) NSString *appDSUClientSecret;


- (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;

@end


@protocol OMHLoginDelegate
@optional

- (void)OMHClientLoginFinishedWithError:(NSError *)error;

@end