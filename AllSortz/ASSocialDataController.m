//
//  ASSocialDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASSocialDataController.h"
#import "ASURLEncoding.h"
@interface ASSocialDataController ()

@property (strong, readwrite) ASUser *userProfile;

@property (strong) NSMutableData *receivedData;
@property(strong, atomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASCLController *locationController;

@end

@implementation ASSocialDataController


NSLock *lock;
BOOL updated;
- (id)init {
    self = [super init];
    if (self) {
        lock = [[NSLock alloc]init];
        updated = NO;
        
        self.locationController = [[ASCLController alloc] init];
        [self.locationController.locationManager startUpdatingLocation];
        self.locationController.delegate = self;
        
        
    }
    return self;
}

- (BOOL)updateData
{

    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/user/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.locationController getStoredUname], [self.locationController getStoredPassword],
        self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.locationController getDeviceUIUD]];
    

    NSLog(@"Get user profile data with %@\n",address);
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    self.receivedData = [NSMutableData data];
    
    return YES;
    
    
}

- (BOOL)updateUserData
{
    
    
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/user/update/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.locationController getStoredUname], [self.locationController getStoredPassword],
        self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.locationController getDeviceUIUD]];
    
    [self.locationController storeUnamePassword:self.userProfile.userName :self.userProfile.userPassword];
    
    NSLog(@"Update the user profile data with %@\n",address);

    NSString *str = [[self.userProfile serializeToDictionary] urlEncodedString];
    NSLog(@"POST STRING IS %@\n",str);
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    NSLog(@"Running update data in user profile\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
}


- (NSURLRequest *)postRequestWithAddress: (NSString *)address        // IN
                                    data: (NSData *)data      // IN
{
    NSURL *url = [NSURL URLWithString:address];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [data length]];
    [urlRequest setURL:[NSURL URLWithString:address]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:data];
    
    return urlRequest;
}


#pragma mark - Connection data delegate

// TODO: Handle server problems and non-200 responses

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Reset data store on new requests
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // TODO: Actual error handling
    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                        options:0
                                         
                                                                          error:NULL];
    
    self.userProfile = [[ASUser alloc] initWithJSONObject:JSONresponse];
    self.receivedData = nil;

    
}

#pragma mark - Receive Location info
- (void)locationUpdate:(CLLocation *)location
{
    self.currentLocation = [location copy];
}

- (void)locationError:(NSError *)error
{
    
}






@end