//
//  ASCLController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASDeviceInterface.h"

@implementation ASDeviceInterface

@synthesize locationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 1000;
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
        [defaults setObject:(__bridge_transfer NSString *)UUIDSRef forKey:@"UUID"];
        CFRelease(UUIDRef);
    }
    else {
        UUID = [defaults valueForKey:@"UUID"];
    }
    return UUID;
}

-(void)storeUnamePassword:(NSString*)uname :(NSString*)password
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uname forKey:@"ASusername"];
    [defaults setObject:password forKey:@"ASpassword"];
    return;
}

-(NSString*)getStoredUname
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"ASusername"])
    {
        [defaults setObject:@"none" forKey:@"ASusername"];
    }
    return [defaults valueForKey:@"ASusername"];
}

-(NSString*)getStoredPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"ASpassword"])
    {
        [defaults setObject:@"generated_password" forKey:@"ASpassword"];
    }
    return [defaults valueForKey:@"ASpassword"];

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