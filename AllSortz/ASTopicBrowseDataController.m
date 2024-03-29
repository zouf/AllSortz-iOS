//
//  ASUserProfileDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASTopicBrowseDataController.h"
@interface ASTopicBrowseDataController()

@property (strong, readwrite) ASUserTopicImportance *userProfile;
@property (strong) NSMutableData *receivedData;
@property (strong, nonatomic) ASDeviceInterfaceSingleton *deviceInterface;


@end

@implementation ASTopicBrowseDataController

- (id)init {
    self = [super init];
    if (self) {
        self.deviceInterface = [[ASDeviceInterfaceSingleton alloc] init];
    }
    return self;
}

- (BOOL)updateData:(NSInteger)parentTopicID;
{
    
    NSString * address;
    if (!parentTopicID)
        address = [NSString stringWithFormat:@"http://allsortz.com/api/topics/?uname=%@&password=%@&deviceID=%@&parent=",
                   [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],[self.deviceInterface getDeviceUIUD]];
    else
        address = [NSString stringWithFormat:@"http://allsortz.com/api/topics/?uname=%@&password=%@&deviceID=%@&parent=%d",
                   [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],[self.deviceInterface getDeviceUIUD],parentTopicID];

    NSLog(@"Get Topics Query: %@\n", address);
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

- (BOOL)updateImportance:(NSInteger)topicID  importanceValue:(float)importance
{

    NSString * address = [NSString stringWithFormat:@"http://allsortz.com/api/topic/subscribe/%d/?importance=%f&uname=%@&password=%@&deviceID=%@&parent=",
                   topicID,importance, [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],[self.deviceInterface getDeviceUIUD]];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"Query to update importance %@\n", address);
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    self.receivedData = [NSMutableData data];
    
    return YES;
}

- (IBAction)importanceSelected:(id)sender {
}

- (void)updateWithArray:(NSMutableArray*)newTopics
{
    self.userProfile = [[ASUserTopicImportance alloc] initWithArray:newTopics];
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

/*
- (BOOL)sendImportance
{
    static NSString *address = @"http://allsortz.com/api/topics/importance/";
    NSURL *url = [NSURL URLWithString:address];
    NSString *str = [[self.userProfile serializeToDictionary] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    self.receivedData = [NSMutableData data];
    
    return YES;
}*/


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
    NSString *success = [JSONresponse valueForKey:@"success"];
    NSString *requestType = [JSONresponse valueForKey:@"requestType"];

    if (success == @"false")
    {
        return;
    }
    if ([requestType isEqualToString:@"topic"])
    {
        self.userProfile = [[ASUserTopicImportance alloc] initWithJSONObject:JSONresponse];
        self.receivedData = nil;
    }
    

}




@end
