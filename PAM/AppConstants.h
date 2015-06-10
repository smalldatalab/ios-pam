//
//  AppConstants.h
//  PAM
//
//  Created by Charles Forkish on 1/13/15.
//  Copyright (c) 2015 Charlie Forkish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMHDataPoint.h"

/**
 *  DSU Sign-in keys
 */
extern NSString * const kPAMDSUClientID;
extern NSString * const kPAMDSUClientSecret;

@interface AppConstants : NSObject

+ (OMHSchemaID *)pamSchemaID;
+ (OMHAcquisitionProvenance *)pamAcquisitionProvenance;

@end
