//
//  ASAddBusinessDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusinessDataController.h"
#import "ASCLController.h"

static NSString * const BOUNDARY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"uploaded";

@interface ASAddBusinessDataController()

    @property (strong, readwrite) ASAddBusiness *business;
    @property (strong) NSMutableData *receivedData;
@property (strong, nonatomic) ASCLController *locationController;


@end

@implementation ASAddBusinessDataController

- (id)init {
    self = [super init];
    if (self) {
        self.locationController = [[ASCLController alloc] init];
    }
    return self;
}


- (BOOL)updateData
{
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/types/?uname=%@&password=%@&deviceID=%@",  [self.locationController getStoredUname], [self.locationController getStoredPassword],[self.locationController getDeviceUIUD]];

    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    NSLog(@"Running update data\n");
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


- (BOOL)uploadData
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/add/?uname=%@&password=%@&deviceID=%@",  [self.locationController getStoredUname], [self.locationController getStoredPassword],[self.locationController getDeviceUIUD]];

    NSString *str = [[self.business serializeToDictionary] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];

    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
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
    NSString *success = [JSONresponse valueForKey:@"success"];

    if (success == @"false")
    {
        return;
    }
    NSString *requestType = [JSONresponse valueForKey:@"requestType"];
    if ([requestType isEqualToString:@"type"])
    {
        self.business = [[ASAddBusiness alloc] initWithJSONObject:JSONresponse];
        self.receivedData = nil;
    }
    else //add a business
    {
        return;
    }
}

@end
