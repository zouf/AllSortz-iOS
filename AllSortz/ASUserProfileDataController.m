//
//  ASUserProfileDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfileDataController.h"
@interface ASUserProfileDataController()

@property (strong, readwrite) ASUserProfile *userProfile;
@property (strong) NSMutableData *receivedData;


@end

@implementation ASUserProfileDataController

- (BOOL)updateData:(NSInteger)parentTopicID;
{
    
   // NSLog(@"New topics are %@\n", newTopics);
    NSString * address;
    if (!parentTopicID)
        address = [NSString stringWithFormat:@"http://allsortz.com/api/topics/?parent="];
    else
        address = [NSString stringWithFormat:@"http://allsortz.com/api/topics/?parent=%d",parentTopicID];
    /*else
    {
        parentTopic = [parentTopic stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        address = [NSString stringWithFormat:@"http://allsortz.com/api/topics/?parent=%@",parentTopic];
    }*/

    NSLog(@"Sending query to server %@\n", address);
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    NSLog(@"Running update data in user profile\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
}

- (BOOL)updateImportance:(NSInteger)topicID  importanceValue:(float)importance
{
    
    // NSLog(@"New topics are %@\n", newTopics);
    
    NSString * address = [NSString stringWithFormat:@"http://allsortz.com/api/topic/subscribe/%d/?importance=%f",topicID, importance];

    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    NSLog(@"Running update data in user profile\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
}

- (void)updateWithArray:(NSMutableArray*)newTopics
{
    self.userProfile = [[ASUserProfile alloc] initWithArray:newTopics];

    //self.userProfile.topics = [NSMutableArray arrayWithArray:newTopics];
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
        self.userProfile = [[ASUserProfile alloc] initWithJSONObject:JSONresponse];
        self.receivedData = nil;
    }
    

}




@end
