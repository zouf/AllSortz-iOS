//
//  ASAddBusinessDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusinessDataController.h"

@interface ASAddBusinessDataController()

    @property (strong, readwrite) ASAddBusiness *business;
    @property (strong) NSMutableData *receivedData;


@end

@implementation ASAddBusinessDataController

- (BOOL)updateData
{
    static NSString *address = @"http://allsortz.com/api/types/";
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        NSLog(@"Error in API!\n");
        return NO;
    }
    NSLog(@"Running update data\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
}

- (BOOL)uploadData
{
    static NSString *address = @"http://allsortz.com/api/types/";
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
   // NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
   // if (!connection) {
        // TODO: Some proper failure handling maybe
        //NSLog(@"Error in API!\n");
        //return NO;
    //}
    NSLog(@"Running upload data\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
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
    self.business = [[ASAddBusiness alloc] initWithJSONObject:JSONresponse];
    self.receivedData = nil;
}

@end
