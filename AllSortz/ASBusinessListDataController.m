//
//  ASBusinessDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/28/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessListDataController.h"

@interface ASBusinessListDataController ()

@property (strong, readwrite) ASBusinessList *businessList;
@property (strong) NSMutableData *receivedData;

@end


@implementation ASBusinessListDataController

- (BOOL)updateData
{
    static NSString *address = @"http://allsortz.com/api/businesses/";
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

- (BOOL)updateDataWithNewList:(ASBusinessList*)newList
{
    

    self.businessList = newList;
    self.receivedData = nil;
    return YES;
}


- (BOOL)updateWithQuery:(ASQuery*)query
{
    static NSString *address = @"http://allsortz.com/api/businesses/search/";
    
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
    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                        options:0
                                                                          error:NULL];
    
    self.businessList = [[ASBusinessList alloc] initWithJSONObject:JSONresponse];
        
    
    self.receivedData = nil;
}

@end
