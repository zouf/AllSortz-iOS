//
//  ASCLController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASCLController.h"

@implementation ASCLController

@synthesize locationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

-(NSString *)getDeviceUIUD
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UUID = @"";
    
    if (![defaults valueForKey:@"UUID"])
    {
        CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
        UUID = [NSString stringWithFormat:@"%@", UUIDSRef];
        
        [defaults setObject:UUID forKey:@"UUID"];
    }
    else {
        UUID = [defaults valueForKey:@"UUID"];
    }
    return UUID;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    [self.delegate locationError:error];
}


@end