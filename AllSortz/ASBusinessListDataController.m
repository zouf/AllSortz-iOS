        //
//  ASBusinessDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/28/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessListDataController.h"
#import <MapKit/MapKit.h>
#import "OAuthConsumer.h"

@interface ASBusinessListDataController ()

@property (strong, readwrite) ASBusinessList *businessList;
@property (strong) NSMutableData *receivedData;
@property(strong, atomic) NSLock* updateAfterLocationChange;

@property (nonatomic,retain) NSOperationQueue *queue;

@end


@implementation ASBusinessListDataController
@synthesize searchTerm;
- (id)init {
    self = [super init];
    if (self) {
        self.updateAfterLocationChange = [[NSLock alloc]init];
        self.deviceInterface = [[ASDeviceInterfaceSingleton alloc] init];
        [self.deviceInterface.locationManager startUpdatingLocation];
        self.deviceInterface.delegate = self;
    }
    return self;
}



#pragma mark - Query for data


-(BOOL)performUpdate
{
    NSString *address;
    CLLocationCoordinate2D center = self.rect.center;
    if(self.rect.span.latitudeDelta == 0)
        return NO;
    float maxx = center.latitude  + (self.rect.span.latitudeDelta  / 2.0);
    float maxy = center.longitude  + (self.rect.span.longitudeDelta  / 2.0);
    float minx = center.latitude  - (self.rect.span.latitudeDelta  / 2.0);
    float miny = center.longitude  - (self.rect.span.longitudeDelta  / 2.0);

    float lat = (float)(maxx+minx)/2.0;
    float lng = (float)(miny+maxy)/2.0;

    if(self.searchTerm)
    {
        address = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f&altitude=500",self.searchTerm,lat,lng];

    }
    else
    {
        address = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=food&ll=%f,%f&altitude=500",lat,lng];

    }

    NSURL *URL = [NSURL URLWithString:address];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET] ;
    OAToken *token = [[OAToken alloc] initWithKey:TOKEN secret:TOKEN_SECRET] ;
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *oauthrequest = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [oauthrequest prepare];
    NSLog(@"%@\n", address);
    self.receivedData = [[NSMutableData alloc] init];
   
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error)
            NSLog(@"ERROR: %@\n", error);
        NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0  error:NULL];
        self.businessList = [[ASBusinessList alloc] initWithJSONObjectYelp:JSONresponse :self.currentLocation];
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:oauthrequest queue:self.queue completionHandler:handler];
    return YES;
}

#pragma mark - Receive Location info
- (void)locationUpdate:(CLLocation *)location
{
    self.currentLocation = [location copy];
    
    //if the lock can be acquired here, that means an updateThread allowed it. Thus, even if we're continually calling this function,
    // it will only call performUpdate as much as allowed
    if ([self.updateAfterLocationChange tryLock])
    {
        [self performUpdate];
    }
}

- (void)locationError:(NSError *)error
{
    NSLog(@"Error updating location!\n");
}

@end
