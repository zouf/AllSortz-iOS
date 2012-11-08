//
//  ASAddBusinessDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusiness.h"
#import "ASGlobal.h"

@interface ASAddBusinessDataController : NSObject <NSURLConnectionDataDelegate>

@property (strong, readonly) ASAddBusiness *business;

- (BOOL)updateData;
- (BOOL)uploadData;


// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (NSURLRequest *)postRequestWithAddress:(NSString *)address data: (NSData *)data;      // IN


@end
