//
//  AppConstants.m
//  PAM
//
//  Created by Charles Forkish on 1/13/15.
//  Copyright (c) 2015 Charlie Forkish. All rights reserved.
//

#import "AppConstants.h"

//NSString * const kPAMGoogleClientID = @"48636836762-ecjbb4s0sd9k7p4terdmbjo0o9kqa2q5.apps.googleusercontent.com"; // "-internal" bundle ID
//NSString * const kPAMGoogleClientID = @"48636836762-qoanqnl8p1f9kvng9ec7jbf4ui73ivak.apps.googleusercontent.com"; // plain bundle ID
NSString * const kOMHServerGoogleClientID = @"48636836762-mulldgpmet2r4s3f16s931ea9crcc64m.apps.googleusercontent.com";
NSString * const kPAMDSUClientID = @"org.openmhealth.ios.pam";
NSString * const kPAMDSUClientSecret = @"Rtg43jkLD7z76c";

@implementation AppConstants

+ (NSString *)PAMGoogleClientID
{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleID isEqualToString:@"io.smalldatalab.pam"]) {
        return @"48636836762-qoanqnl8p1f9kvng9ec7jbf4ui73ivak.apps.googleusercontent.com";
    }
    else if ([bundleID isEqualToString:@"io.smalldatalab.pam-internal"]) {
        return @"48636836762-ecjbb4s0sd9k7p4terdmbjo0o9kqa2q5.apps.googleusercontent.com";
    }
    
    return nil;
}

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
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        sProvenance = [[OMHAcquisitionProvenance alloc] init];
        sProvenance.sourceName = [NSString stringWithFormat:@"PAM-iOS-%@", version];
        sProvenance.modality = OMHAcquisitionProvenanceModalitySelfReported;
    }
    return sProvenance;
}

@end
