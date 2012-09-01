    //
//  ASBusinessDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/28/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessListDataController.h"
#import <MapKit/MapKit.h>
@interface ASBusinessListDataController ()

@property (strong, readwrite) ASBusinessList *businessList;
@property (strong, readwrite) ASBusinessList *businessMapList;

@property (strong) NSMutableData *receivedData;
 
@property(strong, atomic) NSLock* lock;


@end


@implementation ASBusinessListDataController

- (id)init {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc]init];
        
        self.deviceInterface = [[ASDeviceInterface alloc] init];
        [self.deviceInterface.locationManager startUpdatingLocation];
        self.deviceInterface.delegate = self;
        
        
    }
    return self;
}

- (BOOL)updateData
{
    [self.lock unlock];
    // will allow the update location thread to populate the list.
    // might need to redesign this
    return YES;
}

- (BOOL)updateWithRect
{
    [self.lock unlock];
    // will allow the update location thread to populate the list.
    // might need to redesign this
    return YES;
}

- (BOOL)updateDataWithNewList:(ASBusinessList*)newList
{

    self.businessList = newList;
    self.receivedData = nil;
    return YES;
}


- (BOOL)updateWithQuery:(ASQuery*)query
{
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/businesses/search/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
                         self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD]];
    
    NSLog(@"Query server with %@\n",address);
    
    NSString *str = [[query serializeToDictionary] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        NSLog(@"Error\n");
        return NO;
    }   
    NSLog(@"Running upload data\n");
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
    [self.lock unlock];
    NSLog(@"ERROR %@\n",error);
    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (self.receivedData)
    {
        NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                            options:0
                                                                              error:NULL];
        
        self.businessList = [[ASBusinessList alloc] initWithJSONObject:JSONresponse];
        //self.businessMapList =  [[ASBusinessList alloc] initWithJSONObject:JSONresponse];
        
        self.receivedData = nil;
    }
}

#pragma mark - Receive query info
-(void)newASSortViewController:(ASSortViewController *)nsvc didCreateNewSort:(ASBusinessList *)newList{
    // Update the data based on the new query
    //[self.listingsTableDataController.businessList.entries removeAllObjects];
    
    [self updateDataWithNewList:newList];
 ///   [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)cancelNewASSortViewController:(ASSortViewController *)nsvc{
  //  [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)waitOnQueryResponse:(ASQuery *)query{
    [self updateWithQuery:query];
    
}

#pragma mark - Receive Location info
- (void)locationUpdate:(CLLocation *)location
{
    self.currentLocation = [location copy];
    if ([self.lock tryLock])
    {
        
        NSString *address;
        
       // NSLog(@"Update the server with location %@\n", self.currentLocation);
        if (self.isListingView)
        {
            address = [NSString stringWithFormat:@"http://127.0.0.1:8000/api/businesses/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&bus_low=%d&bus_high=%d", [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
                                 self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD],self.bus_low,self.bus_high];
        }
        else
        {
            CLLocationCoordinate2D center = self.rect.center;
            float maxx = center.latitude  + (self.rect.span.latitudeDelta  / 2.0);
            float maxy = center.longitude  + (self.rect.span.longitudeDelta  / 2.0);
            float minx = center.latitude  - (self.rect.span.latitudeDelta  / 2.0);
            float miny = center.longitude  - (self.rect.span.longitudeDelta  / 2.0);


            address = [NSString stringWithFormat:@"http://127.0.0.1:8000/api/businesses/map/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&min_x=%f&min_y=%f&max_x=%f&max_y=%f", [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
                       self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD],minx,miny,maxx,maxy];
        }
        
        
        
        NSLog(@"Query server with %@\n",address);
        NSURL *url = [NSURL URLWithString:address];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        if (!connection) {
            // TODO: Some proper failure handling maybe
            return;
        }
        self.receivedData = [NSMutableData data];
        
        
        return;
        

    }
}

- (void)locationError:(NSError *)error
{
    
}


@end
