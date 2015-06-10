//
//  AppConstants.m
//  PAM
//
//  Created by Charles Forkish on 1/13/15.
//  Copyright (c) 2015 Charlie Forkish. All rights reserved.
//

#import "AppConstants.h"

NSString * const kPAMDSUClientID = @"org.openmhealth.ios.pam";
NSString * const kPAMDSUClientSecret = @"Rtg43jkLD7z76c";

@implementation AppConstants

+ (OMHSchemaID *)pamSchemaID
{
    static OMHSchemaID *sSchemaID = nil;
    if (!sSchemaID) {
        sSchemaID = [[OMHSchemaID alloc] init];
        sSchemaID.schemaNamespace = @"cornell";
        sSchemaID.name = @"photographic-affect-meter-scores";
        sSchemaID.version = @"1.0";
    }
    return sSchemaID;
}

+ (OMHAcquisitionProvenance *)pamAcquisitionProvenance
{
    static OMHAcquisitionProvenance *sProvenance = nil;
    if (!sProvenance) {
        sProvenance = [[OMHAcquisitionProvenance alloc] init];
        sProvenance.sourceName = @"PAM-iOS-1.0";
        sProvenance.modality = OMHAcquisitionProvenanceModalitySelfReported;
    }
    return sProvenance;
}

@end
