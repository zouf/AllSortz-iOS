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

@implementation ASZQuery

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    NSDictionary * results = [aJSONObject objectForKey:@"result"];
    _allSorts = [results objectForKey:@"topics"];
    _allTypes = [results objectForKey:@"types"];
    return self;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    // Return the number of sections.
    
    // Use a third section for the 'topics' if you want to filter by topics that have given ratings
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else
    {
        int ct = [self.allTypes count];
        return ct;
    }
    // to include topics
    /* else
     {
     int ct = [self.allSorts count];
     return ct;
     
     }*/
    return 0;
}

- (NSDictionary *) serializeToDictionary
{
    NSError * error;
    NSString *typeString = @"";
    if (self.selectedTypes.count > 0)
    {
        NSData *typeData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
        typeString = [[NSString alloc] initWithData:typeData encoding:NSUTF8StringEncoding];
    }
    
    NSString *sortString = @"";
    if (self.selectedSorts.count > 0)
    {
        NSData *sortData =  [NSJSONSerialization dataWithJSONObject:self.selectedSorts options:NSJSONWritingPrettyPrinted error:&error];
        sortString = [[NSString alloc] initWithData:sortData encoding:NSUTF8StringEncoding];
        
    }
    
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.distanceWeight, @"dw",
                          typeString, @"selectedTypes",
                          sortString, @"selectedSorts",
                          self.searchText ,@"searchText",
                          self.searchLocation ,@"searchLocation",nil];
    
    return dict;
}

@end

@interface ASBusinessListDataController ()

@property (strong, readwrite) ASBusinessList *businessList;
@property (strong) NSMutableData *receivedData;
@property(strong, atomic) NSLock* updateAfterLocationChange;
@property(strong, atomic) NSLock* requestInProgress;



@end


@implementation ASBusinessListDataController

- (id)init {
    self = [super init];
    if (self) {
        self.updateAfterLocationChange = [[NSLock alloc]init];
        self.requestInProgress  = [[NSLock alloc]init];
        self.deviceInterface = [[ASDeviceInterfaceSingleton alloc] init];
        [self.deviceInterface.locationManager startUpdatingLocation];
        self.deviceInterface.delegate = self;
    }
    return self;
}

- (BOOL)updateData
{
    // pass to query update if necessary
    
    //TODO SEARCH QUERY REFACTOR
    if (self.searchQuery != nil)
        return [self updateWithQuery];
    
    // if we have a location, continue with the update
    if(self.currentLocation)
        return [self performUpdate];
        
    
    // unlock the update flag to allow the location updater to call update
    // this is in case the phone doesnt update location frequently enougb
    if ([self.updateAfterLocationChange tryLock])
        [self.updateAfterLocationChange  unlock];
    
    //unlocking here means we're giving the location updater the chance to get the lock (which will trigger an update)
    
    
    
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


- (BOOL)updateWithQuery
{
    
    // we're already doing an update, don't send 2 requests at once
    if (![self.requestInProgress tryLock])
        return NO;
    
    NSString *address = nil;
    
    // this is the first time we've seen this query (so, set pagination to 0)
    if (!self.searchQuery.goneToServer)
    {
        //self.businessList = nil;
        self.searchQuery.goneToServer = YES;
    }
    
            //self.businessList = nil;
        CLLocationCoordinate2D center = self.rect.center;
        float maxx = center.latitude  + (self.rect.span.latitudeDelta  / 2.0);
        float maxy = center.longitude  + (self.rect.span.longitudeDelta  / 2.0);
        float minx = center.latitude  - (self.rect.span.latitudeDelta  / 2.0);
        float miny = center.longitude  - (self.rect.span.longitudeDelta  / 2.0);
        
        
        //address = [NSString stringWithFormat:@"http://allsortz.com/api/businesses/map/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&min_x=%f&min_y=%f&max_x=%f&max_y=%f",/ [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
            //       self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD],minx,miny,maxx,maxy];
        
        address = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurants&bounds=%f,%f|%f,%f",minx,miny,maxx,maxy];
        NSURL *URL = [NSURL URLWithString:address];
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET] ;
        OAToken *token = [[OAToken alloc] initWithKey:TOKEN secret:TOKEN_SECRET] ;
        
        id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
        NSString *realm = nil;
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                       consumer:consumer
                                                                          token:token
                                                                          realm:realm
                                                              signatureProvider:provider];
    NSLog(@"%@\n",address);
        [request prepare];
        //NSData * data = [[NSMutableData alloc] init];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
       // NSLog(@"JSON: %@", [JSON yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"  "]);
        

   
    
    
    
    
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
    NSLog(@"%@\n", [data description]);
    [self.receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);

    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (self.receivedData)
    {
        NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                            options:0
                               
                                                                              error:NULL];
        
        
       // self.businessList = [[ASBusinessList alloc] initWithJSONObject:JSONresponse];
        self.businessList = [[ASBusinessList alloc] initWithJSONObjectYelp:JSONresponse];


        [self.requestInProgress unlock];
        
    }
}

#pragma mark - Receive query info


-(void)waitOnQueryResponse:(ASZQuery *)query{
    
    //TODO REFACTOR TO INCLUDE A NEW VERSION OF ASQUERY
    self.searchQuery = [[ASZQuery alloc]init];
    self.searchQuery.goneToServer = NO;
    self.searchQuery.searchLocation = [query.searchLocation copy];
    self.searchQuery.searchText = [query.searchText copy];
    self.searchQuery.selectedTypes = [query.selectedTypes copy];
    self.searchQuery.distanceWeight = [query.distanceWeight copy];
    [self setUpdateAList:YES];
    [self updateData];

}
 

-(BOOL)performUpdate
{
    if (![self.requestInProgress tryLock])
        return NO;
    NSString *address;
    CLLocationCoordinate2D center = self.rect.center;
    float maxx = center.latitude  + (self.rect.span.latitudeDelta  / 2.0);
    float maxy = center.longitude  + (self.rect.span.longitudeDelta  / 2.0);
    float minx = center.latitude  - (self.rect.span.latitudeDelta  / 2.0);
    float miny = center.longitude  - (self.rect.span.longitudeDelta  / 2.0);
    

    //address = [NSString stringWithFormat:@"http://allsortz.com/api/businesses/map/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&min_x=%f&min_y=%f&max_x=%f&max_y=%f",/ [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
    //       self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD],minx,miny,maxx,maxy];
    
    //address = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurants&bounds=%f,%f|%f,%f",miny,minx,maxy,maxx];
    address = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurants&location=%@",@"08540"];

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
    NSLog(@"%@\n",address);

    NSLog(@"%@\n",[oauthrequest URL]);
    self.receivedData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:oauthrequest delegate:self];
    // NSLog(@"JSON: %@", [JSON yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"  "]);
    NSLog(@"%@\n", [connection description]);
    
    
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
    
    
    
}


@end
