//
//  DP_CoreLocationManger.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 23/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_CoreLocationManger.h"

@implementation DP_CoreLocationManger

@synthesize bestEffortAtLocation;

+ (DP_CoreLocationManger *)sharedInstance {
    static DP_CoreLocationManger *__sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[DP_CoreLocationManger alloc] init];
    });
    
    return __sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _dp_locationManager = [[CLLocationManager alloc] init];
        _dp_locationManager.delegate = self;
        _dp_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _dp_locationManager.distanceFilter = kCLDistanceFilterNone;
        _dp_locationManager.pausesLocationUpdatesAutomatically = NO;
        _dp_locationManager.headingFilter = kCLHeadingFilterNone;
    }
    
    return self;
}

#pragma mark - CLLocationManger Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (locations) {
        
        CLLocation *newLocation = [locations lastObject];
        
        NSTimeInterval interval = [newLocation.timestamp timeIntervalSinceNow];
        
        if (newLocation.horizontalAccuracy < 0) {
            return;
        }
        
        if (abs(interval)>30) {
            return;
        }
        else {
            self.bestEffortAtLocation = newLocation;
        }
        
        [self.delegate locationUpdate:self.bestEffortAtLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    if (newHeading.headingAccuracy < 0) {
        return;
    }
    
    _currentHeading = newHeading;
    
    CLLocationDirection direction = 0;
    direction = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading;
    
    [self.delegate locationManagerDidUpdateHeading:direction];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.delegate locationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self.delegate didChangeAuthorizationStatus];
}

@end
