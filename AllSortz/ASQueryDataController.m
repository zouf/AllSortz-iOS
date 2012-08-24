//
//  ASQueryDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASQueryDataController.h"



@interface ASQueryDataController ()

@property (strong, readwrite) ASQuery *query;
@property (strong, readwrite) ASBusinessList *searchResults;
@property (strong) NSMutableData *receivedData;


@end



@implementation ASQueryDataController
- (BOOL)updateData
{
    static NSString *address = @"http://allsortz.com/api/query/base/";
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        NSLog(@"Error in API!\n");
        return NO;
    }
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
    
    if ( [[JSONresponse valueForKey:@"requestType"] isEqualToString:@"query"])
    {
        self.query = [[ASQuery alloc] initWithJSONObject:JSONresponse];
        self.receivedData = nil;
    }


}

@end
