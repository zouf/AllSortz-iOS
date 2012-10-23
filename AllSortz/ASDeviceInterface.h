//
//  ASCLController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ASDeviceInterfaceDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


@interface ASDeviceInterface : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property(strong,nonatomic)id<ASDeviceInterfaceDelegate>delegate;


@property (nonatomic, retain) CLLocationManager *locationManager;

-(NSString *)getDeviceUIUD;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

-(void)storeUname:(NSString*)uname password:(NSString*)password;
-(NSString*)getStoredUname;
-(NSString*)getStoredPassword;

@end

