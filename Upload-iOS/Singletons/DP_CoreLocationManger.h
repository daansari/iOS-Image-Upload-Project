//
//  DP_CoreLocationManger.h
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 23/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol DP_CoreLocationMangerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation *)location; // Location updates are sent here
- (void)locationError:(NSError *)error; // Any errors are sent here
- (void)didChangeAuthorizationStatus;

@optional
- (void)locationManagerDidUpdateHeading:(CLLocationDirection)heading;

@end

@interface DP_CoreLocationManger : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *dp_locationManager;
@property (nonatomic, assign) id<DP_CoreLocationMangerDelegate> delegate;
@property (nonatomic, strong) CLHeading *currentHeading;
@property (nonatomic, strong) CLLocation *bestEffortAtLocation;

+(DP_CoreLocationManger *)sharedInstance;

@end
