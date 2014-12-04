//
//  OMHClient.m
//  PAM
//
//  Created by Charles Forkish on 12/2/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "OMHClient.h"
#import "AFHTTPSessionManager.h"

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

NSString * const kDSUBaseURL = @"https://lifestreams.smalldata.io/dsu/";

@interface OMHClient () <GPPSignInDelegate>

@property (nonatomic, strong) GPPSignIn *gppSignIn;
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@property (nonatomic, strong) NSString *dsuAccessToken;
@property (nonatomic, strong) NSString *dsuRefreshToken;

@end

@implementation OMHClient

+ (instancetype)sharedClient
{
    static OMHClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedClient = [defaults objectForKey:@"OMHClient"];
        if (encodedClient != nil) {
            _sharedClient = (OMHClient *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedClient];
        } else {
            _sharedClient = [[self alloc] initPrivate];
        }
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[OMHClient sharedClient]"
                                 userInfo:nil];
    return nil;
}

- (void)commonInit
{
//    [self.gppSignIn signOut]; // TODO: remove
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self != nil) {
        _dsuAccessToken = [decoder decodeObjectForKey:@"client.dsuAccessToken"];
        _dsuRefreshToken = [decoder decodeObjectForKey:@"client.dsuRefreshToken"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.dsuAccessToken forKey:@"client.dsuAccessToken"];
    [encoder encodeObject:self.dsuRefreshToken forKey:@"client.dsuRefreshToken"];
}



- (void)saveClientState
{
    NSLog(@"saving client state");
    NSData *encodedClient = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedClient forKey:@"OMHClient"];
    [userDefaults synchronize];
}

- (NSString *)encodedClientIDAndSecret
{
    if (self.appDSUClientID == nil || self.appDSUClientSecret == nil) return nil;
    
    NSString *string = [NSString stringWithFormat:@"%@:%@",
                        self.appDSUClientID,
                        self.appDSUClientSecret];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"encoded cliend id and secret: %@", [data base64EncodedStringWithOptions:0]);
    return [data base64EncodedStringWithOptions:0];
    
}


#pragma mark - Property Accessors

- (void)setAppGoogleClientID:(NSString *)appGoogleClientID
{
    _appGoogleClientID = appGoogleClientID;
    self.gppSignIn.clientID = appGoogleClientID;
}

- (void)setServerGoogleClientID:(NSString *)serverGoogleClientID
{
    _serverGoogleClientID = serverGoogleClientID;
    self.gppSignIn.homeServerClientID = serverGoogleClientID;
}

- (BOOL)isSignedIn
{
    return (self.dsuAccessToken != nil && self.dsuRefreshToken != nil);
}


#pragma mark - HTTP Session Manager

- (AFHTTPSessionManager *)httpSessionManager
{
    if (_httpSessionManager == nil) {
        _httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kDSUBaseURL]];
    }
    return _httpSessionManager;
}

- (void)setDSUSignInHeader
{
    NSString *token = [self encodedClientIDAndSecret];
    if (token) {
        NSString *auth = [NSString stringWithFormat:@"Basic %@", token];
        [self.httpSessionManager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    }
}

- (void)setDSUUploadHeader
{
    if (self.dsuAccessToken) {
        NSString *auth = [NSString stringWithFormat:@"Bearer %@", self.dsuAccessToken];
        [self.httpSessionManager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    }
}

- (void)updateDataPoint:(NSDictionary *)dataPoint
{
    
}



#pragma mark - Google Login

+ (UIButton *)googleSignInButton
{
    GPPSignInButton *googleButton = [[GPPSignInButton alloc] init];
    googleButton.style = kGPPSignInButtonStyleWide;
    return googleButton;
}

- (GPPSignIn *)gppSignIn
{
    if (_gppSignIn == nil) {
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.shouldFetchGoogleUserEmail = YES;
//        signIn.attemptSSO = YES;
        
        signIn.scopes = @[ @"profile" ];
        _gppSignIn = signIn;
        _gppSignIn.delegate = self;
    }
    return _gppSignIn;
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Client received google error %@ and auth object %@",error, auth);
    if (error) {
        
    }
    else {
        NSString *serverCode = [GPPSignIn sharedInstance].homeServerAuthorizationCode;
        NSLog(@"serverCode: %@", serverCode);
        if (serverCode != nil) {
            [self signInToDSUWithServerCode:serverCode];
        }
        else {
            NSLog(@"failed to receive server code from google auth");
        }
    }
}

- (void)signInToDSUWithServerCode:(NSString *)serverCode
{
    [self setDSUSignInHeader];
    
    NSString *request =  @"google-signin";
    NSString *code = [NSString stringWithFormat:@"fromApp_%@", serverCode];
    NSDictionary *parameters = @{@"code": code, @"client_id" : self.appDSUClientID};
    
    [self.httpSessionManager GET:request parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"DSU login success, response object: %@", responseObject);
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        self.dsuAccessToken = responseDictionary[@"access_token"];
        self.dsuRefreshToken = responseDictionary[@"refresh_token"];
        [self saveClientState];
        
        if (self.signInDelegate != nil) {
            [self.signInDelegate OMHClientSignInFinishedWithError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"DSU login failure, error: %@", error);
        
        if (self.signInDelegate != nil) {
            [self.signInDelegate OMHClientSignInFinishedWithError:error];
        }
    }];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)signOut
{
    [self.gppSignIn signOut];
    self.dsuAccessToken = nil;
    self.dsuRefreshToken = nil;
}

@end
