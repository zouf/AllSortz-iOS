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

@protocol ASCLControllerDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


@interface ASCLController : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property(strong,nonatomic)id<ASCLControllerDelegate>delegate;


@property (nonatomic, retain) CLLocationManager *locationManager;

-(NSString *)getDeviceUIUD;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;



@end

